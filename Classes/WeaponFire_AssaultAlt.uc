class WeaponFire_AssaultAlt extends AssaultGrenade;

event ModeDoFire()
{
	Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Assault.Secondary.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
