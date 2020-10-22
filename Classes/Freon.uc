class Freon extends TeamArenaMaster
    Config;

var float AutoThawTime;
var float ThawSpeed;
var bool  bTeamHeal;

var array<Freon_Pawn> FrozenPawns;

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    if(Freon_GRI(GameReplicationInfo) == None)
        return;

    Freon_GRI(GameReplicationInfo).AutoThawTime = AutoThawTime;
    Freon_GRI(GameReplicationInfo).ThawSpeed = ThawSpeed;
    Freon_GRI(GameReplicationInfo).bTeamHeal = bTeamHeal;
    Freon_GRI(GameReplicationInfo).bDisableNecro = true;
}

function StartNewRound()
{
    FrozenPawns.Remove(0, FrozenPawns.Length);

    Super.StartNewRound();
}

function ParseOptions(string Options)
{
    local string InOpt;

    Super.ParseOptions(Options);

    InOpt = ParseOption(Options, "AutoThawTime");
    if(InOpt != "")
        AutoThawTime = float(InOpt);

    InOpt = ParseOption(Options, "ThawSpeed");
    if(InOpt != "")
        ThawSpeed = float(InOpt);

    InOpt = ParseOption(Options, "TeamHeal");
    if(InOpt != "")
        bTeamHeal = bool(InOpt);
}

event InitGame(string options, out string error)
{
    Super.InitGame(Options, Error);

    class'xPawn'.Default.ControllerClass = class'Freon_Bot';
}

function string SwapDefaultCombo(string ComboName)
{
    if(ComboName ~= "xGame.ComboSpeed")
        return "3SPNv3177AT.Freon_ComboSpeed";
    else if(ComboName ~= "xGame.ComboBerserk")
        return "3SPNv3177AT.Misc_ComboBerserk";

    return ComboName;
}

function PawnFroze(Freon_Pawn Frozen)
{
    local int i;

    for(i = 0; i < FrozenPawns.Length; i++)
    {
        if(FrozenPawns[i] == Frozen)
            return;
    }

    FrozenPawns[FrozenPawns.Length] = Frozen;
    Frozen.Spree = 0;

    if(Misc_Player(Frozen.Controller) != None)
        Misc_Player(Frozen.Controller).Spree = 0;
}

//
// Restart a thawing player. Same as RestartPlayer() just sans the spawn effects
//
function RestartFrozenPlayer(Controller aPlayer, vector Loc, rotator Rot, NavigationPoint Anchor)
{
    local int TeamNum;
    local class<Pawn> DefaultPlayerClass;
	local Vehicle V, Best;
	local vector ViewDir;
	local float BestDist, Dist;
    local TeamInfo BotTeam, OtherTeam;

	if ( (!bPlayersVsBots || (Level.NetMode == NM_Standalone)) && bBalanceTeams && (Bot(aPlayer) != None) && (!bCustomBots || (Level.NetMode != NM_Standalone)) )
	{
		BotTeam = aPlayer.PlayerReplicationInfo.Team;
		if ( BotTeam == Teams[0] )
			OtherTeam = Teams[1];
		else
			OtherTeam = Teams[0];

		if ( OtherTeam.Size < BotTeam.Size - 1 )
		{
			aPlayer.Destroy();
			return;
		}
	}

    if ( bMustJoinBeforeStart && (UnrealPlayer(aPlayer) != None)
        && UnrealPlayer(aPlayer).bLatecomer )
        return;

    if ( aPlayer.PlayerReplicationInfo.bOutOfLives )
        return;

    if ( aPlayer.IsA('Bot') && TooManyBots(aPlayer) )
    {
        aPlayer.Destroy();
        return;
    }

    if( bRestartLevel && Level.NetMode != NM_DedicatedServer && Level.NetMode != NM_ListenServer )
        return;

    if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
        TeamNum = 255;
    else
        TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

    if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
        BaseMutator.PlayerChangedClass(aPlayer);

    if ( aPlayer.PawnClass != None )
        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,, Loc, Rot);

    if( aPlayer.Pawn==None )
    {
        DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
        aPlayer.Pawn = Spawn(DefaultPlayerClass,,, Loc, Rot);
    }
    if ( aPlayer.Pawn == None )
    {
        // log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$Location);
        aPlayer.GotoState('Dead');
        if ( PlayerController(aPlayer) != None )
			PlayerController(aPlayer).ClientGotoState('Dead','Begin');
        return;
    }
    if ( PlayerController(aPlayer) != None )
		PlayerController(aPlayer).TimeMargin = -0.1;
    if(Anchor != None)
        aPlayer.Pawn.Anchor = Anchor;
	aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;

    //aPlayer.Pawn.PlayTeleportEffect(true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
    AddDefaultInventory(aPlayer.Pawn);

    if ( bAllowVehicles && (Level.NetMode == NM_Standalone) && (PlayerController(aPlayer) != None) )
    {
		// tell bots not to get into nearby vehicles for a little while
		BestDist = 2000;
		ViewDir = vector(aPlayer.Pawn.Rotation);
		for ( V=VehicleList; V!=None; V=V.NextVehicle )
			if ( V.bTeamLocked && (aPlayer.GetTeamNum() == V.Team) )
			{
				Dist = VSize(V.Location - aPlayer.Pawn.Location);
				if ( (ViewDir Dot (V.Location - aPlayer.Pawn.Location)) < 0 )
					Dist *= 2;
				if ( Dist < BestDist )
				{
					Best = V;
					BestDist = Dist;
				}
			}

		if ( Best != None )
			Best.PlayerStartTime = Level.TimeSeconds + 8;
	}
}

// if in health is 0, find the 'ambient' temperature of the map (the average of all player's health)
function PlayerThawed(Freon_Pawn Thawed, optional float Health, optional float Shield)
{
    local vector Pos;
    local vector Vel;
    local rotator Rot;
    local Controller C;
    // local array<WeaponData> WD;
    // local Inventory inv;
    local int i;
    local NavigationPoint N;
    local Controller LastHitBy;
    local int Team;

    if(bEndOfRound)
        return;

    if(Health == 0.0)
    {
        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(C.Pawn != None)
            {
                Health += C.Pawn.Health;
                i++;
            }
        }

        if(i > 0)
            Health /= i;
    }

    Pos = Thawed.Location;
    Rot = Thawed.Rotation;
    Vel = Thawed.Velocity;
    C = Thawed.Controller;
    N = Thawed.Anchor;
    LastHitBy = Thawed.LastHitBy;

    if(C.PlayerReplicationInfo == None)
        return;

    // store ammo amounts
    // WD = Thawed.MyWD;

    for(i = 0; i < FrozenPawns.Length; i++)
    {
        if(FrozenPawns[i] == Thawed)
            FrozenPawns.Remove(i, 1);
    }

    // Spawn(class'ThawEffect', , , Thawed.Location, Thawed.Rotation);
    Thawed.PlaySound(sound'WeaponSounds.BExplosion5', SLOT_None, 2 * Thawed.TransientSoundVolume);
    Thawed.Spawn(class'ThawEffect');
    Thawed.Destroy();

    C.PlayerReplicationInfo.bOutOfLives = false;
    C.PlayerReplicationInfo.NumLives = 1;

    if(Bot(C) != None)
        C.GotoState('Dead', 'MPStart');
    else
        C.GotoState('PlayerWaiting');

    /* if(PlayerController(C) != None)
        PlayerController(C).ClientReset();
    RestartFrozenPlayer(C, Pos, Rot, N);

    if(C.Pawn != None)
    {
        C.Pawn.SetLocation(Pos);
        C.Pawn.SetRotation(Rot);
        C.Pawn.AddVelocity(Vel);
        C.Pawn.LastHitBy = LastHitBy;

        // redistribute ammo
        for(inv = C.Pawn.Inventory; inv != None; inv = inv.Inventory)
        {
            if(Weapon(inv) == None)
                return;

            for(i = 0; i < WD.Length; i++)
            {
                if(WD[i].WeaponName ~= string(inv.Class))
                {
                    Weapon(inv).AmmoCharge[0] = WD[i].Ammo[0];
                    Weapon(inv).AmmoCharge[1] = WD[i].Ammo[1];
                    break;
                }
            }
        }

        if(Health != 0.0)
            C.Pawn.Health = Health;
        C.Pawn.ShieldStrength = Shield;
    }

    if(PlayerController(C) != None)
        PlayerController(C).ClientSetRotation(Rot); */

    Team = C.GetTeamNum();
    if(Team == 255)
        return;

    if(TAM_TeamInfo(Teams[Team]) != None && TAM_TeamInfo(Teams[Team]).ComboManager != None)
        TAM_TeamInfo(Teams[Team]).ComboManager.PlayerSpawned(C);
    else if(TAM_TeamInfoRed(Teams[Team]) != None && TAM_TeamInfoRed(Teams[Team]).ComboManager != None)
        TAM_TeamInfoRed(Teams[Team]).ComboManager.PlayerSpawned(C);
    else if(TAM_TeamInfoBlue(Teams[Team]) != None && TAM_TeamInfoBlue(Teams[Team]).ComboManager != None)
        TAM_TeamInfoBlue(Teams[Team]).ComboManager.PlayerSpawned(C);

    BroadcastLocalizedMessage(class'Freon_ThawMessage', 255, C.PlayerReplicationInfo);
}

function PlayerThawedByTouch(Freon_Pawn Thawed, array<Freon_Pawn> Thawers, optional float Health, optional float Shield)
{
    local Controller C;
    local int i;

    if(bEndOfRound)
        return;

    C = Thawed.Controller;
    PlayerThawed(Thawed, Health, Shield);

    if(PlayerController(C) != None)
        PlayerController(C).ReceiveLocalizedMessage(class'Freon_ThawMessage', 0, Thawers[0].PlayerReplicationInfo);

    if(C.PlayerReplicationInfo == None)
        return;

    for(i = 0; i < Thawers.Length; i++)
    {
        if(Thawers[i].PlayerReplicationInfo != None)
            Thawers[i].PlayerReplicationInfo.Score += 2.0;

        if(Thawers[i].Controller != None)
            Thawers[i].Controller.AwardAdrenaline(5.0);

        if(PlayerController(Thawers[i].Controller) != None)
            PlayerController(Thawers[i].Controller).ReceiveLocalizedMessage(class'Freon_ThawMessage', 1, C.PlayerReplicationInfo);
    }
}

function bool CanSpectate(PlayerController Viewer, bool bOnlySpectator, actor ViewTarget)
{
    if(xPawn(ViewTarget) == None && (Controller(ViewTarget) == None || xPawn(Controller(ViewTarget).Pawn) == None))
        return false;

    if(bOnlySpectator)
    {
        if(Controller(ViewTarget) != None)
            return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer);
        else
            return (xPawn(ViewTarget).IsPlayerPawn());
    }

    if(bRespawning || (NextRoundTime <= 1 && bEndOfRound))
        return false;

    if(Controller(ViewTarget) != None)
        return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer &&
                (bEndOfRound || (Controller(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
    else
    {
        return (xPawn(ViewTarget).IsPlayerPawn() && xPawn(ViewTarget).PlayerReplicationInfo != None &&
                (bEndOfRound || (xPawn(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
    }
}

function bool DestroyActor(Actor A)
{
    if(Freon_Pawn(A) != None && Freon_Pawn(A).bFrozen)
        return true;

    return Super.DestroyActor(A);
}

function EndRound(PlayerReplicationInfo Scorer)
{
    local Freon_Trigger FT;

    foreach DynamicActors(class'Freon_Trigger', FT)
        FT.Destroy();

    Super.EndRound(Scorer);
}

defaultproperties
{
     AutoThawTime=90.000000
     ThawSpeed=5.000000
     bTeamHeal=True
     GameName2="Freon"
     TeamAIType(0)=Class'3SPNv3177AT.Freon_TeamAI'
     TeamAIType(1)=Class'3SPNv3177AT.Freon_TeamAI'
     DefaultPlayerClassName="3SPNv3177AT.Freon_Pawn"
     ScoreBoardType="3SPNv3177AT.Freon_Scoreboard"
     HUDType="3SPNv3177AT.Freon_HUD"
     MapListType="3SPNv3177AT.MapListFreon"
     PlayerControllerClassName="3SPNv3177AT.Freon_Player"
     GameReplicationInfoClass=Class'3SPNv3177AT.Freon_GRI'
     GameName="Freon v3.177 AT"
     Description="Freeze the other team, score a point. Chill well and serve."
     Acronym="Freon"
}
