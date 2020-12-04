class Message_FlakFuck extends LocalMessage;
/*#exec AUDIO IMPORT FILE=Sounds\finishmc.wav GROUP=Sounds
var Sound flack;
var(Message) localized string FlagFuck;
var(Message) localized string Roxx;
var(Message) localized string Lamer;

static function string GetString (optional int SwitchNum, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
  if ( SwitchNum == 1 )
  {
    return Default.FlagFuck;
  }
  if ( SwitchNum == 2 )
  {
    return Default.Roxx;
  }
  if ( SwitchNum == 3 )
  {
    return Default.Lamer;
  }
  else {return Default.Lamer;}
}


static simulated function ClientReceive(
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    
	 Misc_Player(P).PlayCustomRewardAnnouncement(default.flack, 1);
	
	
	if(SwitchNum==1 && RelatedPRI_2 == None)
		P.ClientPlaySound(default.flack);
	
	if(SwitchNum==1)
		P.ClientPlaySound(default.flack);
}

defaultproperties
{
     flack=Sound'3SPNRU-B2.Sounds.finishmc'
     FlagFuck="Flak Fuck"
     Roxx="Air Rocket"
     Lamer="Lamer"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=4
     DrawColor=(B=80,G=80,R=0)
     PosY=0.320000
}
*/