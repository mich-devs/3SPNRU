class Misc_DeathMessage extends xDeathMessage;

var color TextColor;

var string Red;
var string Blue;
var string Text;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string KillerName, VictimName;

    if(class<DamageType>(OptionalObject) == None)
        return "";

    if(default.Red == "")
    {
        default.Red = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.RedTeamColor);
        default.Blue = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.BlueTeamColor);
        default.Text = class'DMStatsScreen'.static.MakeColorCode(default.TextColor);
    }

    if(RelatedPRI_2 == None)
        VictimName = default.Text $ default.SomeoneString $ default.Text;
    else
    {
        if(!class'Misc_Player'.default.bTeamColoredDeathMessages || RelatedPRI_2.Team == None)
            VictimName = default.Text $ Misc_PRI(RelatedPRI_2).GetColoredName() $ default.Text;
        else if(RelatedPRI_2.Team.TeamIndex == 0)
            VictimName = default.Red $ RelatedPRI_2.PlayerName $ default.Text;
        else
            VictimName = default.Blue $ RelatedPRI_2.PlayerName $ default.Text;
    }

    if(Switch == 1)
        return class'GameInfo'.static.ParseKillMessage(KillerName, VictimName, class<DamageType>(OptionalObject).static.SuicideMessage(RelatedPRI_2));

    if(RelatedPRI_1 == None)
        KillerName = default.Text $ default.SomeoneString $ default.Text;
    else
    {
        if(!class'Misc_Player'.default.bTeamColoredDeathMessages || RelatedPRI_2.Team == None)
            KillerName = default.Text $ Misc_PRI(RelatedPRI_1).GetColoredName() $ default.Text;
        else if(RelatedPRI_1.Team.TeamIndex == 0)
            KillerName = default.Red $ RelatedPRI_1.PlayerName $ default.Text;
        else
            KillerName = default.Blue $ RelatedPRI_1.PlayerName $ default.Text;
    }

    return class'GameInfo'.static.ParseKillMessage(KillerName, VictimName, class<DamageType>(OptionalObject).static.DeathMessage(RelatedPRI_1, RelatedPRI_2));
}

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 1 )
	{
		if ( !class'xDeathMessage'.default.bNoConsoleDeathMessages )
			Super(LocalMessage).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		return;
	}
	if ( (RelatedPRI_1 == P.PlayerReplicationInfo)
		|| (P.PlayerReplicationInfo.bOnlySpectator && (Pawn(P.ViewTarget) != None) && (Pawn(P.ViewTarget).PlayerReplicationInfo == RelatedPRI_1)) )
	{
		P.myHUD.LocalizedMessage(class'Misc_KillerMessage', Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		if ( !class'xDeathMessage'.default.bNoConsoleDeathMessages )
			P.myHUD.LocalizedMessage(default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

        if ( P.Role == ROLE_Authority )
        {
			if ( UnrealPlayer(P).MultiKillLevel > 0 )
				P.ReceiveLocalizedMessage( class'MultiKillMessage', UnrealPlayer(P).MultiKillLevel );
		}
        else
        {
			if ( ( RelatedPRI_1 != RelatedPRI_2 ) && ( RelatedPRI_2 != None)
				&& ((RelatedPRI_2.Team == None) || (RelatedPRI_1.Team != RelatedPRI_2.Team)) )
			{
				if ( (P.Level.TimeSeconds - UnrealPlayer(P).LastKillTime < 4) && (Switch != 1) )
				{
					UnrealPlayer(P).MultiKillLevel++;
					P.ReceiveLocalizedMessage( class'MultiKillMessage', xPlayer(P).MultiKillLevel );
				}
				else
					UnrealPlayer(P).MultiKillLevel = 0;
				UnrealPlayer(P).LastKillTime = P.Level.TimeSeconds;
			}
			else
				UnrealPlayer(P).MultiKillLevel = 0;
		}
	}
	else if (RelatedPRI_2 == P.PlayerReplicationInfo)
	{
		P.ReceiveLocalizedMessage(class'Misc_VictimMessage', 0, RelatedPRI_1 );
		if ( !class'xDeathMessage'.default.bNoConsoleDeathMessages )
			Super(LocalMessage).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	else if ( !class'xDeathMessage'.default.bNoConsoleDeathMessages )
		Super(LocalMessage).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     TextColor=(B=210,G=210,R=210,A=255)
}
