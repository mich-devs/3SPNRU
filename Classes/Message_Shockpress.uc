class Message_Shockpress extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\impressive.wav GROUP=Sounds

var Sound impressive;
var localized string impressivetex;
var localized string youblow;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.impressivetex;
    
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
		P.ClientPlaySound(default.impressive);
	
	if(SwitchNum==1)
		P.ClientPlaySound(default.impressive);
}

defaultproperties
{
     impressive=Sound'3SPHorstALPHA001.Sounds.impressive'
     impressivetex="I M P R E S S I V E"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=224,G=58,R=196)
     StackMode=SM_Down
     PosY=0.150000
}
