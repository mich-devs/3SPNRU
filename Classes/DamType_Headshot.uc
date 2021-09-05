class DamType_HeadShot extends DamTypeSniperHeadShot;

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
     DeathString="%o's cranium was made extra crispy by %k's lightning gun."
     AwardLevel=5
}
