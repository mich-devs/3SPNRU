//================================================================================
// Message_HitDamage.
//================================================================================

class Message_HitDamage extends LocalMessage;

var(Message) Color TeamDamage;

static function Color GetColor (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
  if ( Switch > 0 )
  {
    return Default.DrawColor;
  }
  if ( Switch < 0 )
  {
    return Default.TeamDamage;
  }
}

defaultproperties
{
     TeamDamage=(R=255,A=255)
     DrawColor=(B=3,G=240,R=3)
     PosY=0.530000
}
