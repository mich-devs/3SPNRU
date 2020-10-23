//================================================================================
// Message_FinalKill.
//================================================================================

class Message_FinalKill extends LocalMessage;

var localized string FinalKillText;

static function string GetString (optional int SwitchNum, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
  return Default.FinalKillText;
}

defaultproperties
{
     FinalKillText="Final Kill"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=3
     DrawColor=(B=243,G=246,R=165)
     PosY=0.320000
}
