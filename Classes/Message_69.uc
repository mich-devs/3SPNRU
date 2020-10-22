class Message_69 extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\69.wav GROUP=Sounds

var Sound sndsound;
var localized string did69dmg;
var localized string youblow;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.did69dmg;
    else
        return RelatedPRI_1.PlayerName@default.youblow;
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
		P.ClientPlaySound(default.sndsound);
	
	if(SwitchNum==1)
		P.ClientPlaySound(default.sndsound);
}

defaultproperties
{
     sndsound=Sound'3SPHorstALPHA001.Sounds.69'
     did69dmg="69 D A M A G E"
     youblow="IS A 69 Actor"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=224,G=58,R=196)
     StackMode=SM_Down
     PosY=0.150000
}
