class Freon_Player extends Misc_Player;

var Freon_Pawn FrozenPawn;

function AwardAdrenaline(float amount)
{
    amount *= 0.8;
    Super.AwardAdrenaline(amount);
}

simulated event Destroyed()
{
    if(FrozenPawn != None)
        FrozenPawn.Died(self, class'Suicided', FrozenPawn.Location);

    Super.Destroyed();
}

function BecomeSpectator()
{
    if(FrozenPawn != None)
        FrozenPawn.Died(self, class'DamageType', FrozenPawn.Location);

    Super.BecomeSpectator();
}

function ServerDoCombo(class<Combo> ComboClass)
{
    if(class<ComboSpeed>(ComboClass) != None)
        ComboClass = class<Combo>(DynamicLoadObject("3SPNv3177AT.Freon_ComboSpeed", class'Class'));

    Super.ServerDoCombo(ComboClass);
}

function Reset()
{
    Super.Reset();
    FrozenPawn = None;
}

function Freeze()
{
    if(Pawn == None)
        return;

    FrozenPawn = Freon_Pawn(Pawn);

    bBehindView = true;
    LastKillTime = -5.0;
    EndZoom();

    Pawn.RemoteRole = ROLE_SimulatedProxy;

    Pawn = None;
    PendingMover = None;

    if(!IsInState('GameEnded') && !IsInState('RoundEnded'))
    {
        ServerViewSelf();
        GotoState('Frozen');
    }
}

function ServerViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;
	local TeamInfo RealTeam;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = (ViewTarget != FrozenPawn) && (ViewTarget != Pawn) && (ViewTarget != self);
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

function ServerViewSelf()
{
    if(PlayerReplicationInfo != None)
    {
        if(PlayerReplicationInfo.bOnlySpectator)
            Super.ServerViewSelf();
        else if(FrozenPawn != None)
        {
            SetViewTarget(FrozenPawn);
            ClientSetViewTarget(FrozenPawn);
            bBehindView = true;
            ClientSetBehindView(true);
            ClientMessage(OwnCamera, 'Event');
        }
        else
        {
            if(ViewTarget == None)
                Fire();
            else
            {
                bBehindView = !bBehindView;
                ClientSetBehindView(bBehindView);
            }
        }
    }
}

state Frozen extends Spectating
{
    exec function AltFire(optional float f)
    {
        ServerViewSelf();
    }
}

function TakeShot()
{
    ConsoleCommand("shot Freon-"$Left(string(Level), InStr(string(Level), "."))$"-"$Level.Month$"-"$Level.Day$"-"$Level.Hour$"-"$Level.Minute);
    bShotTaken = true;
}

defaultproperties
{
     PlayerReplicationInfoClass=Class'3SPNv3177AT.Freon_PRI'
}
