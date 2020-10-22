class NecromancyMessages extends LocalMessage;

var(Message) localized string PlayerRevived_part1;
var(Message) localized string PlayerRevived_part2;
var(Message) localized string ComboCancelled;


static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2,	optional Object OptionalObject)
{
	if(Switch == 0)
    {
		return Misc_PRI(RelatedPRI_2).GetColoredNameEx() @ default.PlayerRevived_part1 @ Misc_PRI(RelatedPRI_1).GetColoredNameEx() @ default.PlayerRevived_part2;
	}
    else if(Switch == 1)
    {
		  return default.ComboCancelled;
	}
}

defaultproperties
{
     PlayerRevived_part1="was resurrected by"
     ComboCancelled="Combo Cancelled - There is no one Out!"
     bIsUnique=True
     bIsPartiallyUnique=True
     bFadeMessage=True
     Lifetime=4
     DrawColor=(B=250,G=50,R=150)
     PosY=0.195000
}
