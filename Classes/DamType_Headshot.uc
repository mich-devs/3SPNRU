class DamType_HeadShot extends IDDamTypeSniperHeadShot;

var int AwardLevel;

static function IncrementKills(Controller Killer)
{
	local xPlayerReplicationInfo xPRI;
	
	if ( PlayerController(Killer) == None )
		return;
		
	PlayerController(Killer).ReceiveLocalizedMessage( Default.KillerMessage, 0, Killer.PlayerReplicationInfo, None, None );
	xPRI = xPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if ( xPRI != None )
	{
		xPRI.HeadCount++;
		
			if ( (xPRI.HeadCount == Default.AwardLevel) && (Misc_Player(Killer) != None) )
			Misc_Player(Killer).BroadcastAnnouncement(Class'Message_HeadHunter');
			
	}
}

defaultproperties
{
     AwardLevel=5
     DeathString="%k ???| ???H E A D S H O T ???| %o"
     FemaleSuicide="%o ???Suicide H E A D S H O T"
     MaleSuicide="%o ???Suicide H E A D S H O T"
}
