class WeaponFire_FlakAlt extends FlakAltFire;

event ModeDoFire()
{
    Misc_PRI(Misc_Pawn(Weapon.Owner).PlayerReplicationInfo).Flak.Secondary.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
    ProjectileClass=class'WormboFlakShell'
}
