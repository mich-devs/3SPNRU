class Misc_Player extends xPlayer;

//#exec AUDIO IMPORT FILE=Sounds\alone.wav     	    GROUP=Sounds
//#exec AUDIO IMPORT FILE=Sounds\hitsound.wav         GROUP=Sounds
#exec OBJ LOAD FILE=AnnouncerMain

/* Combo related */
var config bool bShowCombos;            // show combos on the HUD

var config bool bDisableSpeed;
var config bool bDisableInvis;
var config bool bDisableBooster;
var config bool bDisableBerserk;
var config bool bDisableNecro;
/* Combo related */

/* HUD related */
var config bool bShowTeamInfo;          // show teams info on the HUD
var config bool bExtendedInfo;          // show extra teammate info

var config bool bMatchHUDToSkins;       // sets HUD color to brightskins color

var config bool bTeamColoredDeathMessages;

var config enum EDamageIndicator
	{
		Disabled,
		Centered,
		Floating
	} DamageIndicator;
/* HUD related */

/* brightskins related */
var config bool bUseBrightskins;        // self-explanatory
var config bool bUseTeamColors;         // use red and blue for brightkins
var config Color RedOrEnemy;            // brightskin color for the red or enemy team
var config Color BlueOrAlly;            // brightskin color for the blue or own team
/* brightskins related */

/* model related */
var config bool bForceRedEnemyModel;    // force a model for the red/enemy team
var config bool bForceBlueAllyModel;    // force a model for the blue/ally team
var config bool bUseTeamModels;         // force models by team color (opposed to enemy/ally)
var config string RedEnemyModel;        // character name for the red team's model
var config string BlueAllyModel;        // character name for the blue team's model
/* model related */

var bool bUseOldStyle;

var int  Spree;                         // kill count at new round
var bool bFirstOpen;                    // used by the stat screen

var float NewFriendlyDamage;            // friendly damage done
var float NewEnemyDamage;               // enemy damage done

var int HitDamage;
var bool bHitContact;
var Pawn HitPawn;

var int LastDamage;

var int SumDamage;
var float SumDamageTime;

var bool bDisableAnnouncement;
var bool bAutoScreenShot;
var bool bShotTaken;

var bool bSeeInvis;

/* sounds */
var config bool  bAnnounceOverkill;
var config bool  bUseHitsounds;

var config Sound SoundHit;
var config Sound SoundHitFriendly;
var config float SoundHitVolume;

var config Sound SoundAlone;
var config float SoundAloneVolume;

var config Sound SoundTMDeath;

var config Sound SoundUnlock;
/* sounds */

/* menu3spn */
var bool bDelayedOpenMenu;
var bool bAutoOpenMenu;
var enum EMenu3SPNState
{
    M3SPN_Unloaded,
    M3SPN_WaitingForData,
    M3SPN_Loaded
} Menu3SPNState;
/* menu3spn */

var Misc_Console myConsole;
var string PlayerNameCopy;

var config bool bEnableEnhancedNetCode;

var int MaxPlayersForBoost;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientResetClock, ClientPlayAlone, ClientListBest,
        ClientLockWeapons, ClientKillBases, ClientSendAssaultStats,
        ClientSendBioStats, ClientSendShockStats, ClientSendLinkStats,
        ClientSendMiniStats, ClientSendFlakStats, ClientSendRocketStats,
        ClientSendSniperStats, ClientSendComboStats, ClientSendMiscStats,
        DeadClientSetViewTarget;

    reliable if(bNetDirty && Role == ROLE_Authority)
        HitDamage, bHitContact, HitPawn, bSeeInvis;

    reliable if(Role < ROLE_Authority)
        SetNetCodeDisabled, ServerSetMapString, ServerCallTimeout;
}

function ServerTaunt(name AnimName )
{
    if (!Level.Game.bGameEnded && (Misc_BaseGRI(Level.Game.GameReplicationInfo) == None || !Misc_BaseGRI(Level.Game.GameReplicationInfo).bEndOfRound) )
        return;

    Super.ServerTaunt(AnimName);
}

function SetNetCodeDisabled()
{
    local inventory inv;

	class'Misc_Player'.default.bEnableEnhancedNetCode = false;
	
    if(Pawn == none)
       return;

	for(inv = Pawn.Inventory; inv!=None; inv=inv.inventory)
	{
		if(Weapon(inv)!=None)
		{
			  if(NewNet_AssaultRifle(Inv)!=None)
				  NewNet_AssaultRifle(Inv).DisableNet();
			   else if( NewNet_BioRifle(Inv)!=None)
				  NewNet_BioRifle(Inv).DisableNet();
			   else if(NewNet_ShockRifle(Inv)!=None)
				  NewNet_ShockRifle(Inv).DisableNet();
			   else if(NewNet_MiniGun(Inv)!=None)
				  NewNet_MiniGun(Inv).DisableNet();
			   else if(NewNet_LinkGun(Inv)!=None)
				  NewNet_LinkGun(Inv).DisableNet();
			   else if(NewNet_RocketLauncher(Inv)!=None)
				  NewNet_RocketLauncher(inv).DisableNet();
			   else if(NewNet_FlakCannon(inv)!=None)
				  NewNet_FlakCannon(inv).DisableNet();
			   else if(NewNet_SniperRifle(inv)!=None)
				  NewNet_SniperRifle(inv).DisableNet();
			   else if(NewNet_ClassicSniperRifle(inv)!=None)
				  NewNet_ClassicSniperRifle(inv).DisableNet();
		}
	}
}

simulated static function bool UseNewNet()
{
    return class'Misc_Player'.default.bEnableEnhancedNetCode;
}

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

    if(Level.NetMode != NM_DedicatedServer)
        class'PlayerSettings'.static.RetrieveMiscSettings(self);
}

function MenuGotData()
{
    if (Menu3SPNState == M3SPN_WaitingForData)
        Menu3SPNState = M3SPN_Loaded;
}

function DeadClientSetViewTarget(Actor A)
{
    // this against "can't see myself" bug
    if(Pawn == None)
        SetViewTarget(A);
    else
        SetViewTarget(Pawn);

    bBehindView = false;
    bFixedCamera = false;
}

// copied superclass' code here for stop messing client demoplay
simulated function ReceiveLocalizedMessage(class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;
    
    if(Message == class'FirstBloodMessage')
        Message = class'Misc_FirstBloodMessage';

    if(Message == class'KillingSpreeMessage')
        Message = class'Misc_KillingSpreeMessage';    

    Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	if ( Message.static.IsConsoleMessage(Switch) && (Player != None) && (Player.Console != None) )
		Player.Console.Message(Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject),0 );    
}

function PlayerTick(float DeltaTime)
{
    local int Damage;
    
    Super.PlayerTick(DeltaTime);

    if(Pawn != None && (Pawn.Health > 0) && !IsInState('GameEnded'))
    {
        // this against "can't see myself" bug
        if(ViewTarget != Pawn && (ViewTarget == None || ViewTarget.Instigator != Pawn))
        {
            SetViewTarget(Pawn);
            bBehindView = false;
            bFixedCamera = false;
        }

        // this against no-weapon bug
        if(Pawn.PendingWeapon != None && Pawn.PendingWeapon.Instigator == None)
        {
            Pawn.PendingWeapon.SetOwner(Pawn);
            Pawn.PendingWeapon.ClientWeaponSet(true);
        }

        if(Pawn.Weapon != None && Pawn.Weapon.Instigator == None)
        {
            Pawn.Weapon.SetOwner(Pawn);
            Pawn.Weapon.ClientWeaponSet(true);
        }

        // this against "forever locked" weapons
        if(xPawn(Pawn) != None && xPawn(Pawn).bNoWeaponFiring &&
           Misc_BaseGRI(GameReplicationInfo) != None && !Misc_BaseGRI(GameReplicationInfo).bWeaponsLocked)
            xPawn(Pawn).bNoWeaponFiring = false;
    }

    if(Misc_PRI(PlayerReplicationInfo) != None)
    {
        if(PlayerNameCopy != Misc_PRI(PlayerReplicationInfo).PlayerName)
        {
            PlayerNameCopy = Misc_PRI(PlayerReplicationInfo).PlayerName;
            Misc_PRI(PlayerReplicationInfo).ServerSetColoredName( class'PlayerSettings'.static.GetColoredName(PlayerReplicationInfo) );
        }

        if(myConsole == None)
            myConsole = Misc_Console(Player.InteractionMaster.AddInteraction("3SPNv3177AT.Misc_Console", Player) );

        if(bDelayedOpenMenu)
        {
            if(Menu3SPNState == M3SPN_Unloaded)
            {
                Menu3SPNState = M3SPN_WaitingForData;
                Misc_PRI(PlayerReplicationInfo).ServerSendNewsText(-1);
            }
            else if(Menu3SPNState == M3SPN_Loaded && (GUIController(Player.GUIController).Count() == 0) )
            {
                bDelayedOpenMenu = false;
                // do AutoOpen only when News Text is configured
                if (!bAutoOpenMenu || (class'Text_TabNews'.default.Text.Length > 0) )
                    Menu3SPN();
                bAutoOpenMenu = false;
            }
        }
    }

    if(Pawn == None || !bUseHitSounds || HitDamage == LastDamage)
    {
        LastDamage = HitDamage;
        return;
    }

    if(HitDamage != LastDamage)
    {
        Damage = HitDamage - LastDamage;
        
        if(bHitContact)
        {
            if(HitDamage < LastDamage)
                Pawn.PlaySound(soundHitFriendly,, soundHitVolume,,,(48 / (-Damage)), false);
            else
                Pawn.PlaySound(soundHit,, soundHitVolume,,,(48 / Damage), false);
        }
        
        if(HitPawn != None && Misc_BaseGRI(GameReplicationInfo).bDamageIndicator)
        {
            if (DamageIndicator == Centered)
            {
                if ( (Level.TimeSeconds - SumDamageTime > 1) || (SumDamage > 0 ^^ Damage > 0) )
                    SumDamage = 0;
                SumDamage += Damage;
                SumDamageTime = Level.TimeSeconds;
            }
            
            if(DamageIndicator == Floating)
                class'Emitter_Damage'.static.ShowDamage(HitPawn, HitPawn.Location, Damage);        
        }        
    }
    
    LastDamage = HitDamage;
}

// colored names related ->
event ClientMessage( coerce string S, optional Name Type )
{
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

    if (Type == '')
        Type = 'Event';

	TeamMessageEx(PlayerReplicationInfo, S, Type);
}

function TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type)
{
	if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
		return;

	TeamMessageEx(PRI, S, Type);
}

// ClientMessage and TeamMessage is replicated, this one not, for stop messing client demoplay
function TeamMessageEx(PlayerReplicationInfo PRI, coerce string S, name Type)
{
	if( AllowTextToSpeech(PRI, Type) )
		TextToSpeech(S, TextToSpeechVoiceVolume );
	if ( Type == 'TeamSayQuiet' )
		Type = 'TeamSay';

	if ( myHUD != None )
		myHUD.Message(PRI, S, Type );

	if ( (Player != None) && (Player.Console != None) )
	{
        if(Team_HUDBase(myHUD) != None)
            S = Team_HUDBase(myHUD).GetColoredMessage(PRI, S, Type);
        else if(AM_HUD(myHUD) != None)
            S = AM_HUD(myHUD).GetColoredMessage(PRI, S, Type);
        else if(PRI != None)
			S = PRI.PlayerName$": "$S;

		Player.Console.Chat(S, 6.0, PRI);    
	}
}
// <- colored names related

function PawnDied(Pawn P)
{
    local float A;

    A = Adrenaline;
    Super.PawnDied(P);
    Adrenaline = A;
}

function ClientListBest(string acc, string dam, string hs)
{
    if(bDisableAnnouncement)
        return;
    
    if(acc != "")
        TeamMessageEx(PlayerReplicationInfo, acc, 'Event');
    if(dam != "")
        TeamMessageEx(PlayerReplicationInfo, dam, 'Event');
    if(hs != "")
        TeamMessageEx(PlayerReplicationInfo, hs, 'Event');
}

function ServerSetMapString(string s)
{
    if(TeamArenaMaster(Level.Game) != None)
        TeamArenaMaster(Level.Game).SetMapString(self, s);
    else if(ArenaMaster(Level.Game) != None)
        ArenaMaster(Level.Game).SetMapString(self, s);
}

function ServerThrowWeapon()
{
    local int ammo[2];
    local Inventory inv;
    local class<Weapon> WeaponClass;

    if(Misc_Pawn(Pawn) == None || Pawn.Weapon == None)
        return;

    ammo[0] = Pawn.Weapon.AmmoCharge[0];
    ammo[1] = Pawn.Weapon.AmmoCharge[1];
    WeaponClass = Pawn.Weapon.Class;

    Super.ServerThrowWeapon();

    Misc_Pawn(Pawn).GiveWeaponClass(WeaponClass);

    for(inv = Pawn.Inventory; inv != None; inv = inv.Inventory)
    {
        if(inv.Class == WeaponClass)
        {
            Weapon(inv).AmmoCharge[0] = ammo[0];
            Weapon(inv).AmmoCharge[1] = ammo[1];
            break;
        }
    }
}

function AwardAdrenaline(float amount)
{
    if(bAdrenalineEnabled)
    {
        if((TAM_GRI(GameReplicationInfo) == None || TAM_GRI(GameReplicationInfo).bDisableTeamCombos) && (Pawn != None && Pawn.InCurrentCombo()))
            return;

        if((Adrenaline < 100) && (Adrenaline + amount >= 100))
            ClientDelayedAnnouncement(sound'AnnouncerMain.Adrenalin', 15);

        if((Adrenaline < AdrenalineMax) && (Adrenaline + amount >= AdrenalineMax))
            ClientDelayedAnnouncementNamed('Adrenalin', 15);

        Adrenaline = FClamp(Adrenaline + amount, 0.1, AdrenalineMax);
    }
}

function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if(Level.GRI != None)
        Level.GRI.MaxLives = 0;

    if(Misc_BaseGRI(Level.GRI) != None)
        AdrenalineMax = Clamp(Misc_BaseGRI(Level.GRI).MaxAdrenaline, 100, 999);
    else
        AdrenalineMax = 100;

    if(Level.NetMode == NM_DedicatedServer)
        return;

    // display settings menu only once per session
    Menu3SPNState = M3SPN_Unloaded;
    bDelayedOpenMenu = (int(GetURLOption("NoMenu3SPN")) == 0);
    bAutoOpenMenu = bDelayedOpenMenu;
    if (bDelayedOpenMenu)
        UpdateURL("NoMenu3SPN", "1", false);
}

function ClientKillBases()
{
    local xPickupBase p;

    ForEach AllActors(class'xPickupBase', p)
    {
        if(P.IsA('Misc_PickupBase'))
            continue;

        p.bHidden = true;
        if(p.myEmitter != None)
            p.myEmitter.Destroy();
    }
}

function Reset()
{
    local NavigationPoint P;
    local float Adren;

    Adren = Adrenaline;

    P = StartSpot;
    Super.Reset();
    StartSpot = P;

    if(Pawn == None || !Pawn.InCurrentCombo())
        Adrenaline = Adren;
    else
        Adrenaline = 0.1;

    WaitDelay = 0;
}

function ClientLockWeapons(bool bLock)
{
    if(xPawn(Pawn) != None)
        xPawn(Pawn).bNoWeaponFiring = bLock;
}

function ClientPlayAlone()
{
    ClientPlaySound(SoundAlone, true, SoundAloneVolume);
}

simulated function PlayCustomRewardAnnouncement(sound ASound, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;

	// Wait for player to be up to date with replication when joining a server, before stacking up messages
	if(Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None)
		return;

	if((AnnouncementLevel > AnnouncerLevel) || (RewardAnnouncer == None))
		return;
	if(!bForce && (Level.TimeSeconds - LastPlaySound < 1))
		return;
    LastPlaySound = Level.TimeSeconds;  // so voice messages won't overlap
	LastPlaySpeech = Level.TimeSeconds;	// don't want chatter to overlap announcements

	Atten = 2.0 * FClamp(0.1 + float(AnnouncerVolume) * 0.225, 0.2, 1.0);
	if(ASound != None)
		ClientPlaySound(ASound, true, Atten, SLOT_Talk);
}

function ClientResetClock(int seconds)
{
    Misc_BaseGRI(GameReplicationInfo).RoundTime = seconds;
}

function AcknowledgePossession(Pawn P)
{
    Super.AcknowledgePossession(P);

    if(xPawn(P) != None && TAM_GRI(GameReplicationInfo) != None)
        xPawn(P).bNoWeaponFiring = TAM_GRI(GameReplicationInfo).bWeaponsLocked;
}

function ServerViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;
	local TeamInfo RealTeam;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;
    RealTeam = PlayerReplicationInfo.Team;

    // view next player
    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
		if ( bRealSpec && (C.PlayerReplicationInfo != None) ) // hack fix for invasion spectating
			PlayerReplicationInfo.Team = C.PlayerReplicationInfo.Team;
        if ( Misc_BaseGRI(Level.GRI).bSpectateAll || Level.Game.CanSpectate(self,bRealSpec,C) )
        {
            if ( Pick == None )
                Pick = C;
            if ( bFound )
            {
                Pick = C;
                break;
            }
            else
                bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
        }
    }
    PlayerReplicationInfo.Team = RealTeam;
    SetViewTarget(Pick);
    ClientSetViewTarget(Pick);

    if(!bWasSpec)
        bBehindView = false;

    ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}

state Spectating
{
    ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
     ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

    exec function Fire( optional float F )
    {
    	if(bFrozen)
	    {
		    if((TimerRate <= 0.0) || (TimerRate > 1.0))
			    bFrozen = false;
		    return;
	    }

        ServerViewNextPlayer();
    }

    // Return to spectator's own camera.
    exec function AltFire( optional float F )
    {
	    if(!PlayerReplicationInfo.bOnlySpectator && !PlayerReplicationInfo.bAdmin && Level.NetMode != NM_Standalone && GameReplicationInfo.bTeamGame)
        {
            if(ViewTarget == None)
                Fire();
            else
		        ToggleBehindView();
        }
	    else
	    {
        	bBehindView = false;
        	ServerViewSelf();
	    }
    }

    function Timer()
    {
    	bFrozen = false;
    }

    function BeginState()
    {
        if ( Pawn != None )
        {
            SetLocation(Pawn.Location);
            UnPossess();
        }

	    bCollideWorld = true;
	    CameraDist = Default.CameraDist;
    }

    function EndState()
    {
        PlayerReplicationInfo.bIsSpectator = false;
        bCollideWorld = false;
    }
}

function ServerChangeTeam(int Team)
{
    local float A;

    A = Adrenaline;
    Super.ServerChangeTeam(Team);
    Adrenaline = A;

    if(Team_GameBase(Level.Game) != None && Team_GameBase(Level.Game).bRespawning)
    {
        PlayerReplicationInfo.bOutOfLives = false;
        PlayerReplicationInfo.NumLives = 1;
    }
}

function BecomeSpectator()
{
	if (Role < ROLE_Authority)
		return;

	if ( !Level.Game.BecomeSpectator(self) )
		return;

	if ( Pawn != None )
		Pawn.Died(self, class'DamageType', Pawn.Location);

	if ( PlayerReplicationInfo.Team != None )
		PlayerReplicationInfo.Team.RemoveFromTeam(self);
	PlayerReplicationInfo.Team = None;
	ServerSpectate();
	BroadcastLocalizedMessage(Level.Game.GameMessageClass, 14, PlayerReplicationInfo);

	ClientBecameSpectator();
}

function BecomeActivePlayer()
{
    local bool bRespawning;
    local float A;

    A = Adrenaline;
    Super.BecomeActivePlayer();
    Adrenaline = A;

    if(Role == Role_Authority)
    {
        if(Team_GameBase(Level.Game) != None)
            bRespawning = Team_GameBase(Level.Game).bRespawning;
        else if(ArenaMaster(Level.Game) != None)
            bRespawning = ArenaMaster(Level.Game).bRespawning || !ArenaMaster(Level.Game).bRoundBased;
        else
            return;

        PlayerReplicationInfo.bOutOfLives = !bRespawning;
        PlayerReplicationInfo.NumLives = int(bRespawning);
        if(!bRespawning)
            GotoState('Spectating');
        else
            GotoState('PlayerWaiting');
    }
}

function DoCombo(class<Combo> ComboClass)
{
    if(!CanDoCombo(ComboClass) )
        return;

    if(TAM_GRI(GameReplicationInfo) == None || TAM_GRI(Level.GRI).bDisableTeamCombos)
    {
        Super.DoCombo(ComboClass);
        return;
    }

    ServerDoCombo(ComboClass);
}

function int CountActivePlayers()
{
	local Controller P;
	local int c;

	for ( P = Level.ControllerList; P != None; P = P.nextController )
	{
		if( P.PlayerReplicationInfo != None && P.bIsPlayer
		 && P.PlayerReplicationInfo.Team != None
		 && !P.PlayerReplicationInfo.bOnlySpectator )
		{
			c++;
		}
	}
    return c;
}

function bool CanDoCombo(class<Combo> ComboClass)
{
    if(TAM_GRI(GameReplicationInfo) == None)
        return false;

    if(class<ComboNecromancy>(ComboClass) != None)
        return !(bDisableNecro || TAM_GRI(GameReplicationInfo).bDisableNecro);

    if(xPawn(Pawn) != None && xPawn(Pawn).CurrentCombo != None)
        return false;

    if(class<ComboSpeed>(ComboClass) != None)
        return !(bDisableSpeed || TAM_GRI(GameReplicationInfo).bDisableSpeed);

    if(class<ComboDefensive>(ComboClass) != None)
    {
        if(Role == ROLE_Authority && default.MaxPlayersForBoost > 0 &&
           default.MaxPlayersForBoost < CountActivePlayers() )
        {
            if (xPawn(Pawn) != None) 
            {
                ReceiveLocalizedMessage(class'NoBoostMessage');
                Pawn.PlaySound(sound'electricalfx20', SLOT_None, 300.0);
                Pawn.PlaySound(class'Combo'.default.ActivateSound, SLOT_None, 1.0);                
            }
            return false;
        }        
        return !(bDisableBooster || TAM_GRI(GameReplicationInfo).bDisableBooster);        
    }

    if(class<ComboInvis>(ComboClass) != None)
        return !(bDisableInvis || TAM_GRI(GameReplicationInfo).bDisableInvis);

    if(class<ComboBerserk>(ComboClass) != None)
        return !(bDisableBerserk || TAM_GRI(GameReplicationInfo).bDisableBerserk);

    return true;
}

function bool CanBeTeamCombo(class<Combo> ComboClass)
{
    if(class<ComboSpeed>(ComboClass) != None)
        return true;
    if(class<ComboDefensive>(ComboClass) != None)
        return true;
    if(class<ComboInvis>(ComboClass) != None)
        return true;
    if(class<ComboBerserk>(ComboClass) != None)
        return true;

    return false;
}

function ServerDoCombo(class<Combo> ComboClass)
{
    if(Level.Game.bGameEnded)
        return;
	if( (ComboClass == None) || (xPawn(Pawn) == None) )
		return;
    if(Adrenaline < ComboClass.default.AdrenalineCost)
        return;
    
    if(class<ComboBerserk>(ComboClass) != None)
        ComboClass = class<Combo>(DynamicLoadObject("3SPNv3177AT.Misc_ComboBerserk", class'Class'));
    else if(class<ComboSpeed>(ComboClass) != None && class<Misc_ComboSpeed>(ComboClass) == None)
        ComboClass = class<Combo>(DynamicLoadObject("3SPNv3177AT.Misc_ComboSpeed", class'Class'));

    if(!CanDoCombo(ComboClass))
        return;

    /* if(Misc_PRI(PlayerReplicationInfo) != None
       && ((TAM_GRI(GameReplicationInfo) != None && !TAM_GRI(Level.GRI).bDisableTeamCombos)
           || (class<ComboNecromancy>(ComboClass) != None)) )
        PlayerReplicationInfo.Score += Clamp(Misc_PRI(PlayerReplicationInfo).NecroUseScoreAward, 0, 100); */
    // necro combo gives score by itself
    if(Misc_PRI(PlayerReplicationInfo) != None && class<ComboNecromancy>(ComboClass) == None
       && TAM_GRI(GameReplicationInfo) != None && !TAM_GRI(Level.GRI).bDisableTeamCombos)
        PlayerReplicationInfo.Score += Clamp(Misc_PRI(PlayerReplicationInfo).NecroUseScoreAward, 0, 100);

    if (class<ComboNecromancy>(ComboClass) != None)
    {
        if (ComboClass.default.ExecMessage != "")
            ReceiveLocalizedMessage(class'ComboMessage', , , , ComboClass);
        Spawn(ComboClass, Pawn, , Pawn.Location, Pawn.Rotation);
        TeamPlayerReplicationInfo(PlayerReplicationInfo).Combos[4] += 1;
        return;
    }

    if(TAM_GRI(GameReplicationInfo) == None || TAM_GRI(Level.GRI).bDisableTeamCombos || !CanBeTeamCombo(ComboClass) )
    {
        Super.ServerDoCombo(ComboClass);
        return;
    }

    if(xPawn(Pawn) != None)
    {
        if(TAM_TeamInfo(PlayerReplicationInfo.Team) != None)
            TAM_TeamInfo(PlayerReplicationInfo.Team).PlayerUsedCombo(self, ComboClass);
        else if(TAM_TeamInfoRed(PlayerReplicationInfo.Team) != None)
            TAM_TeamInfoRed(PlayerReplicationInfo.Team).PlayerUsedCombo(self, ComboClass);
        else if(TAM_TeamInfoBlue(PlayerReplicationInfo.Team) != None)
            TAM_TeamInfoBlue(PlayerReplicationInfo.Team).PlayerUsedCombo(self, ComboClass);
        else
            log("Could not get TeamInfo for player:"@PlayerReplicationInfo.PlayerName, '3SPN');
    }
}

function ServerUpdateStatArrays(TeamPlayerReplicationInfo PRI)
{
    local Misc_PRI P;

    P = Misc_PRI(PRI);
    if(P == None)
        return;

    Super.ServerUpdateStatArrays(PRI);

    ClientSendAssaultStats(P, P.Assault);
    ClientSendBioStats(P, P.Bio);
    ClientSendShockStats(P, P.Shock);
    ClientSendLinkStats(P, P.Link);
    ClientSendMiniStats(P, P.Mini);
    ClientSendFlakStats(P, P.Flak);
    ClientSendRocketStats(P, P.Rockets);
    ClientSendSniperStats(P, P.Sniper);
    ClientSendComboStats(P, P.Combo);
    ClientSendMiscStats(P, P.HeadShots, P.EnemyDamage, P.ReverseFF, P.AveragePercent,
        P.FlawlessCount, P.OverkillCount, P.DarkHorseCount, P.SGDamage);
}

function ClientSendMiscStats(Misc_PRI P, int HS, int ED, float RFF, float AP, int FC, int OC, int DHC, int SGD)
{
    P.HeadShots = HS; P.EnemyDamage = ED; P.ReverseFF = RFF; P.AveragePercent = AP;
    P.FlawlessCount = FC; P.OverkillCount = OC; P.DarkHorseCount = DHC; P.SGDamage = SGD;
}

function ClientSendAssaultStats(Misc_PRI P, Misc_PRI.HitStats Assault)
{
    P.Assault.Primary.Fired     = Assault.Primary.Fired;
    P.Assault.Primary.Hit       = Assault.Primary.Hit;
    P.Assault.Primary.Damage    = Assault.Primary.Damage;
    P.Assault.Secondary.Fired   = Assault.Secondary.Fired;
    P.Assault.Secondary.Hit     = Assault.Secondary.Hit;
    P.Assault.Secondary.Damage  = Assault.Secondary.Damage;
}

function ClientSendShockStats(Misc_PRI P, Misc_PRI.HitStats Shock)
{
    P.Shock.Primary.Fired     = Shock.Primary.Fired;
    P.Shock.Primary.Hit       = Shock.Primary.Hit;
    P.Shock.Primary.Damage    = Shock.Primary.Damage;
    P.Shock.Secondary.Fired   = Shock.Secondary.Fired;
    P.Shock.Secondary.Hit     = Shock.Secondary.Hit;
    P.Shock.Secondary.Damage  = Shock.Secondary.Damage;
}

function ClientSendLinkStats(Misc_PRI P, Misc_PRI.HitStats Link)
{
    P.Link.Primary.Fired     = Link.Primary.Fired;
    P.Link.Primary.Hit       = Link.Primary.Hit;
    P.Link.Primary.Damage    = Link.Primary.Damage;
    P.Link.Secondary.Fired   = Link.Secondary.Fired;
    P.Link.Secondary.Hit     = Link.Secondary.Hit;
    P.Link.Secondary.Damage  = Link.Secondary.Damage;
}

function ClientSendMiniStats(Misc_PRI P, Misc_PRI.HitStats Mini)
{
    P.Mini.Primary.Fired     = Mini.Primary.Fired;
    P.Mini.Primary.Hit       = Mini.Primary.Hit;
    P.Mini.Primary.Damage    = Mini.Primary.Damage;
    P.Mini.Secondary.Fired   = Mini.Secondary.Fired;
    P.Mini.Secondary.Hit     = Mini.Secondary.Hit;
    P.Mini.Secondary.Damage  = Mini.Secondary.Damage;
}

function ClientSendFlakStats(Misc_PRI P, Misc_PRI.HitStats Flak)
{
    P.Flak.Primary.Fired     = Flak.Primary.Fired;
    P.Flak.Primary.Hit       = Flak.Primary.Hit;
    P.Flak.Primary.Damage    = Flak.Primary.Damage;
    P.Flak.Secondary.Fired   = Flak.Secondary.Fired;
    P.Flak.Secondary.Hit     = Flak.Secondary.Hit;
    P.Flak.Secondary.Damage  = Flak.Secondary.Damage;
}

function ClientSendRocketStats(Misc_PRI P, Misc_PRI.HitStat Rockets)
{
    P.Rockets.Fired = Rockets.Fired;
    P.Rockets.Hit = Rockets.Hit;
    P.Rockets.Damage = Rockets.Damage;
}

function ClientSendSniperStats(Misc_PRI P, Misc_PRI.HitStat Sniper)
{
    P.Sniper.Fired = Sniper.Fired;
    P.Sniper.Hit = Sniper.Hit;
    P.Sniper.Damage = Sniper.Damage;
}

function ClientSendBioStats(Misc_PRI P, Misc_PRI.HitStat Bio)
{
    P.Bio.Fired = Bio.Fired;
    P.Bio.Hit = Bio.Hit;
    P.Bio.Damage = Bio.Damage;
}

function ClientSendComboStats(Misc_PRI P, Misc_PRI.HitStat Combo)
{
    P.Combo.Fired = Combo.Fired;
    P.Combo.Hit = Combo.Hit;
    P.Combo.Damage = Combo.Damage;
}

state GameEnded
{
    function BeginState()
    {
        Super.BeginState();

        if(Level.NetMode == NM_DedicatedServer)
            return;

        if(MyHUD != None)
        {
            MyHUD.bShowScoreBoard = true;
            MyHUD.bShowLocalStats = false;
        }

        SetTimer(1.0, false);
    }

    function Timer()
    {
        if(bAutoScreenShot && !bShotTaken)
            TakeShot();

        Super.Timer();
    }
}

/* exec functions */
exec function Suicide()
{
    if(Pawn != None)
        Pawn.Suicide();
}

function TakeShot()
{
    if(GameReplicationInfo.bTeamGame)
        ConsoleCommand("shot TAM-"$Left(string(Level), InStr(string(Level), "."))$"-"$Level.Month$"-"$Level.Day$"-"$Level.Hour$"-"$Level.Minute);
    else
        ConsoleCommand("shot AM-"$Left(string(Level), InStr(string(Level), "."))$"-"$Level.Month$"-"$Level.Day$"-"$Level.Hour$"-"$Level.Minute);
    bShotTaken = true;
}

exec function SetSkins(byte r1, byte g1, byte b1, byte r2, byte g2, byte b2)
{
    RedOrEnemy.R = Clamp(r1, 0, 100);
    RedOrEnemy.G = Clamp(g1, 0, 100);
    RedOrEnemy.B = Clamp(b1, 0, 100);

    BlueOrAlly.R = Clamp(r2, 0, 100);
    BlueOrAlly.G = Clamp(g2, 0, 100);
    BlueOrAlly.B = Clamp(b2, 0, 100);

    saveconfig();
}

exec function Menu3SPN()
{
	local Rotator r;

    if (Menu3SPNState != M3SPN_Loaded)
    {
        if (!bDelayedOpenMenu)
        {
            bDelayedOpenMenu = true;
            ClientMessage("< Please wait >");
        }
        return;
    }

	r = GetViewRotation();
	r.Pitch = 0;
	SetRotation(r);

	ClientOpenMenu("3SPNv3177AT.Menu_Menu3SPN");
}

exec function ToggleTeamInfo()
{
    bShowTeamInfo = !bShowTeamInfo;
    saveconfig();
}

exec function BehindView(bool b)
{
	if(PlayerReplicationInfo.bOnlySpectator || (Pawn == None && !Misc_BaseGRI(GameReplicationInfo).bEndOfRound)
        || PlayerReplicationInfo.bAdmin || Level.NetMode == NM_Standalone)
		Super.BehindView(b);
	else
		Super.BehindView(false);
}

exec function ToggleBehindView()
{
	if(PlayerReplicationInfo.bOnlySpectator || (Pawn == None && !Misc_BaseGRI(GameReplicationInfo).bEndOfRound)
        || PlayerReplicationInfo.bAdmin || Level.NetMode == NM_Standalone)
		Super.ToggleBehindView();
	else
		Super.BehindView(false);
}

exec function UseSpeed()
{
    if( !bAdrenalineEnabled || (Adrenaline < class'ComboSpeed'.default.AdrenalineCost) )
        return;

    DoCombo(class'ComboSpeed');
}

exec function UseBooster()
{
    if( !bAdrenalineEnabled || (Adrenaline < class'ComboDefensive'.default.AdrenalineCost) )
        return;

    DoCombo(class'ComboDefensive');
}

exec function UseInvis()
{
    if( !bAdrenalineEnabled || (Adrenaline < class'ComboInvis'.default.AdrenalineCost) )
        return;

    DoCombo(class'ComboInvis');
}

exec function UseBerserk()
{
    if( !bAdrenalineEnabled || (Adrenaline < class'ComboBerserk'.default.AdrenalineCost) )
        return;

    DoCombo(class'ComboBerserk');
}

exec function UseNecro()
{
    if( !bAdrenalineEnabled || (Adrenaline < class'ComboNecromancy'.default.AdrenalineCost) )
        return;

    DoCombo(class'ComboNecromancy');
}

exec function CallTimeout()
{
    ServerCallTimeout();
}

function ServerCallTimeout()
{
    if(Team_GameBase(Level.Game) != None)
        Team_GameBase(Level.Game).CallTimeout(self);
}
/* exec functions */

defaultproperties
{
     bShowCombos=True
     bShowTeamInfo=True
     bExtendedInfo=True
     bTeamColoredDeathMessages=True
     DamageIndicator=Floating
     bUseBrightskins=True
     bUseTeamColors=True
     RedOrEnemy=(R=100,A=128)
     BlueOrAlly=(B=100,G=25,A=128)
     RedEnemyModel="Gorge"
     BlueAllyModel="Jakob"
     bAnnounceOverkill=True
     bUseHitsounds=True
     SoundHit=Sound'3SPNv3177AT.Sounds.HitSound'
     SoundHitFriendly=Sound'MenuSounds.denied1'
     SoundHitVolume=0.600000
     SoundAlone=Sound'3SPNv3177AT.Sounds.alone'
     SoundAloneVolume=1.000000
     SoundUnlock=Sound'NewWeaponSounds.Newclickgrenade'
     ComboNameList(4)="3SPNv3177AT.ComboNecromancy"
     PlayerReplicationInfoClass=Class'3SPNv3177AT.Misc_PRI'
     Adrenaline=0.100000
}
