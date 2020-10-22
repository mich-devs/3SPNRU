class Misc_PawnReplicationInfo extends ReplicationInfo;

var vector Position;

var byte Health;
var byte Shield;
var int Adrenaline;

var bool bInvis;

var xPawn MyPawn;

replication
{
    unreliable if(bNetDirty && Role == ROLE_Authority)
        Position, Health, Shield, Adrenaline, bInvis;
}

function SetMyPawn(xPawn P)
{
    if(P == None)
    {
        Health = 0;
        Shield = 0;
        Position = vect(0,0,0);
        bInvis = false;

        NetUpdateFrequency = default.NetUpdateFrequency * 0.1;
        NetPriority = default.NetPriority * 0.1;

        MyPawn = None;
        SetTimer(0.0, false);
    }
    else
    {
        MyPawn = P;

        if (Health != MyPawn.Health)
            Health = MyPawn.Health;
        if (Shield != MyPawn.ShieldStrength)
            Shield = MyPawn.ShieldStrength;
        if (Adrenaline != MyPawn.Controller.Adrenaline)
            Adrenaline = MyPawn.Controller.Adrenaline;
        if (Position != MyPawn.Location)
            Position = MyPawn.Location;
        if (bInvis != MyPawn.bInvis)
            bInvis = MyPawn.bInvis;

        NetUpdateFrequency = default.NetUpdateFrequency;
        NetPriority = default.NetPriority;

        NetUpdateTime = Level.TimeSeconds - 5;

        SetTimer(0.2, true);
    }
}

function Timer()
{
    if(MyPawn == None)
    {
        SetMyPawn(None);
        return;
    }

    if (Health != MyPawn.Health)
        Health = MyPawn.Health;
    if (Shield != MyPawn.ShieldStrength)
        Shield = MyPawn.ShieldStrength;
    if (Adrenaline != MyPawn.Controller.Adrenaline)
        Adrenaline = MyPawn.Controller.Adrenaline;
    if (Position != MyPawn.Location)
        Position = MyPawn.Location;
    if (bInvis != MyPawn.bInvis)
        bInvis = MyPawn.bInvis;
}

defaultproperties
{
     NetUpdateFrequency=5.000000
     NetPriority=0.500000
}
