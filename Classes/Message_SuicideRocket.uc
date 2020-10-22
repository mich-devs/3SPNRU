class Message_SuicideRocket extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\selfk.wav GROUP=Sounds

var Sound RocketSuicide;
var localized string YourAreAMertyr;
var localized string PlayerIsMertyr;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{

  if(SwitchNum == 1)
	    return default.YourAreAMertyr;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsMertyr;
 
 
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
    
	 Misc_Player(P).PlayCustomRewardAnnouncement(default.RocketSuicide, 1);
	
	
	if(SwitchNum==0 && RelatedPRI_2 == None)
		P.ClientPlaySound(default.RocketSuicide);
	
	if(SwitchNum==1)
		P.ClientPlaySound(default.RocketSuicide);
		
}

defaultproperties
{
     RocketSuicide=Sound'3SPHorstALPHA001.Sounds.selfk'
     YourAreAMertyr="YOU ARE A MARTYR!"
     PlayerIsMertyr="IS A MARTYR!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.100000
}
