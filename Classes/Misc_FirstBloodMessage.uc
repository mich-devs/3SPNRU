class Misc_FirstBloodMessage extends FirstBloodMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Misc_PRI(RelatedPRI_1) == None)
		return "";
	return Misc_PRI(RelatedPRI_1).GetColoredNameEx()@Default.FirstBloodString;
}

defaultproperties
{
}
