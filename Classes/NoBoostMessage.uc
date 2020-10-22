class NoBoostMessage extends LocalMessage;

var(Message) localized string BoostNotAvailablePart1;
var(Message) localized string BoostNotAvailablePart2;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2,	optional Object OptionalObject)
{
    return default.BoostNotAvailablePart1 $ class'Misc_Player'.default.MaxPlayersForBoost $ default.BoostNotAvailablePart2;
}

defaultproperties
{
     BoostNotAvailablePart1="Combo Cancelled - No Boost for more than "
     BoostNotAvailablePart2=" players!"
     bIsUnique=True
     bIsPartiallyUnique=True
     bFadeMessage=True
     Lifetime=4
     DrawColor=(B=32,G=230,R=32)
     PosY=0.180000
}
