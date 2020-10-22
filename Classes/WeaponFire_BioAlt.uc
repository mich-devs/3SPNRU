class WeaponFire_BioAlt extends BioChargedFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Bio.Fired += 1;
    Super.ModeDoFire();
}

defaultproperties
{
}
