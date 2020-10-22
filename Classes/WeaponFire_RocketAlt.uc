class WeaponFire_RocketAlt extends RocketMultiFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Rockets.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
}
