class Message_RocketKill extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\RocketSound.wav GROUP=Sounds

var Sound RocketSound;
var localized string RocketKill;
var localized string Secondmessa;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.RocketKill;
    else
        return RelatedPRI_1.PlayerName@default.Secondmessa;
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
    
	if(SwitchNum==0 && RelatedPRI_2 == None)
		P.ClientPlaySound(default.RocketSound);
	
	if(SwitchNum==1)
		P.ClientPlaySound(default.RocketSound);
}

defaultproperties
{
     RocketSound=Sound'3SPHorstALPHA001.Sounds.RocketSound'
     RocketKill="F A T A L I T Y"
     Secondmessa="DID A FATALITY"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.100000
}
