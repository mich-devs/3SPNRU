class ColoredNameMessage extends PlayerNameMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return Misc_PRI(RelatedPRI_1).GetColoredName();
}

defaultproperties
{
}
