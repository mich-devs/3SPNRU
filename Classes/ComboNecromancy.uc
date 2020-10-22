class ComboNecromancy extends Combo
    Config(3SPNv3177AT);
    
#exec OBJ LOAD FILE=GeneralAmbience.uax

var xEmitter EffectA_Pawn;
var xEmitter EffectB_Pawn;
var xEmitter EffectA_LuckyOne;
var xEmitter EffectB_LuckyOne;

var const Sound ResSound[2];

var() config bool  bSelectRandom;
var() config Range SelectMostAdren;

function float RatePlayerRez(Controller C)
{
    if(C.PlayerReplicationInfo == None)
        return -1;

    if(C.PlayerReplicationInfo.bBot)
        return C.Adrenaline;
    
    if(C.Adrenaline < SelectMostAdren.Min)              // finally, with Adren < 75: player with least score comes
        return 1000 - C.PlayerReplicationInfo.Score;
    
    if(C.Adrenaline < SelectMostAdren.Max)              // second, players with Adren 75 to 100 (they near to be able to res): player with most adren comes
        return 2000 + C.Adrenaline;
    
    return 4000 - C.PlayerReplicationInfo.Score;        // first, players with Adren > 100: player with least score comes
}

function Controller PickTheOne()
{
	local Controller P, POwner;
    local float CurR, BestR;
    local Controller TheLucky;
    
	POwner = Pawn(Owner).Controller;
    
	if(POwner == None || POwner.PlayerReplicationInfo == None)
		return None;
    
	for (P = Level.ControllerList; P != None; P = P.nextController)
	{
		if (P.PlayerReplicationInfo != None && P.bIsPlayer &&
		    P.PlayerReplicationInfo.Team == POwner.PlayerReplicationInfo.Team &&
		    P != POwner && P.PlayerReplicationInfo.bOutOfLives &&
		    !P.PlayerReplicationInfo.bOnlySpectator)
		{
            CurR = RatePlayerRez(P);
            if(BestR < CurR)
            {
                BestR = CurR;
                TheLucky = P;
            }
		}
	}

    return TheLucky;
}

function Controller PickTheOneOldStyle()
{
  local array<Controller> CList;
	local Controller P,POwner;
	local int c;
	POwner = Pawn(Owner).Controller;
	if( POwner==None || POwner.PlayerReplicationInfo==None )
		Return None;
	for ( P = Level.ControllerList; P != None; P = P.nextController )
	{
		if( P.PlayerReplicationInfo!=None && P.bIsPlayer
		 && P.PlayerReplicationInfo.Team==POwner.PlayerReplicationInfo.Team
		 && P!=POwner && P.PlayerReplicationInfo.bOutOfLives
		 && !P.PlayerReplicationInfo.bOnlySpectator )
		{
			CList.Length = c+1;
			CList[c] = P;
			c++;
		}
	}
    if (CList.Length > 0)
        return CList[Rand(c)];
    return None;
}

function StartEffect(xPawn P)
{
  local Controller theLuckyOne;

  if(bSelectRandom)
      theLuckyOne = PickTheOneOldStyle();
  else
      theLuckyOne = PickTheOne();
  
  if (theLuckyOne != None)
  {
    P.Controller.Adrenaline -= AdrenalineCost;
    //P.PlaySound(sound'tortureloop2', SLOT_None, 500.0);
    P.PlaySound(ResSound[Rand(2)], SLOT_None, 500.0);
    BroadcastLocalizedMessage(class'NecromancyMessages', 0, P.PlayerReplicationInfo, theLuckyOne.PlayerReplicationInfo);
    theLuckyOne.PlayerReplicationInfo.bOutOfLives = false;
    theLuckyOne.PlayerReplicationInfo.NumLives = 1;
    Level.Game.RestartPlayer(theLuckyOne);
    if(Misc_PRI(P.PlayerReplicationInfo) != None)
        Misc_PRI(P.PlayerReplicationInfo).Score += Clamp(Misc_PRI(P.PlayerReplicationInfo).NecroUseScoreAward, 0, 100);

    //Spawn effects on adren-player
    EffectA_Pawn = Spawn(class'NecromancyEffectA', P,, P.Location, P.Rotation);
    EffectB_Pawn = Spawn(class'NecromancyEffectB', P,, P.Location, P.Rotation);
  }
  else
  {
    ///// not player found. cancelling combo...
    TeamPlayerReplicationInfo(P.PlayerReplicationInfo).Combos[4]--;
    P.ReceiveLocalizedMessage(class'NecromancyMessages', 1);
    P.PlaySound(sound'electricalfx20', SLOT_None, 300.0);
  }
  Destroy();
}

function Tick(float DeltaTime)
{
}

defaultproperties
{
     ResSound(0)=Sound'3SPNv3177AT.Sounds.NecroChantA'
     ResSound(1)=Sound'3SPNv3177AT.Sounds.NecroChantB'
     SelectMostAdren=(Min=75.000000,Max=100.000000)
     ExecMessage="Necromancy!"
     Duration=0.000000
     keys(0)=1
     keys(1)=1
     keys(2)=2
     keys(3)=2
}
