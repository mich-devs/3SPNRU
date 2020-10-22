class Freon_Scoreboard extends TAM_Scoreboard;

// #exec TEXTURE IMPORT NAME=FrostedScoreboard FILE=Textures\Scoreboard_Frost.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5

simulated function SetCustomBarColor(out Color C, PlayerReplicationInfo PRI, bool bOwner)
{
    if(!bOwner && Freon_PRI(PRI) != None && Freon_PawnReplicationInfo(Freon_PRI(PRI).PawnReplicationInfo) != None && Freon_PawnReplicationInfo(Freon_PRI(PRI).PawnReplicationInfo).bFrozen)
    {
        C.R = 180;
        C.G = 220;
        C.B = 255;
        C.A = BaseAlpha * 1.1;
    }
}

simulated function SetCustomLocationColor(out Color C, PlayerReplicationInfo PRI, bool bOwner)
{
    if(Freon_PRI(PRI) != None && Freon_PawnReplicationInfo(Freon_PRI(PRI).PawnReplicationInfo) != None && Freon_PawnReplicationInfo(Freon_PRI(PRI).PawnReplicationInfo).bFrozen)
        C = class'Freon_PRI'.default.FrozenColor;
}

defaultproperties
{
     BaseTex=Texture'3SPNv3177AT.textures.FrostedScoreboard'
     BaseAlpha=130
}
