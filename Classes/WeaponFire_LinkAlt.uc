class WeaponFire_LinkAlt extends LinkAltFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Link.Secondary.Fired++;
    Super.ModeDoFire();
}

defaultproperties
{
}
