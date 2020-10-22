class Misc_KillingSpreeMessage extends KillingSpreeMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_2 == None)
	{
		if (Misc_PRI(RelatedPRI_1) == None)
			return "";

		if (RelatedPRI_1.PlayerName != "")
			return Misc_PRI(RelatedPRI_1).GetColoredNameEx()@Default.SpreeNote[Switch];
	}
	else
	{
		if (RelatedPRI_1 == None)
		{
			if (RelatedPRI_2.PlayerName != "")
			{
				if ( RelatedPRI_2.bIsFemale )
					return Misc_PRI(RelatedPRI_2).GetColoredNameEx()@Default.EndFemaleSpree;
				else
					return Misc_PRI(RelatedPRI_2).GetColoredNameEx()@Default.EndSelfSpree;
			}
		}
		else
		{
			return Misc_PRI(RelatedPRI_1).GetColoredNameEx()$Default.EndSpreeNote@Misc_PRI(RelatedPRI_2).GetColoredNameEx()@Default.EndSpreeNoteTrailer;
		}
	}
	return "";
}

defaultproperties
{
}
