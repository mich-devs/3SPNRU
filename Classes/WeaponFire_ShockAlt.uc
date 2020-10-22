class WeaponFire_ShockAlt extends ShockProjFire;

event ModeDoFire()
{
    Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Shock.Secondary.Fired += load;
    Super.ModeDoFire();
}

defaultproperties
{
     ProjectileClass=Class'3SPNRU-B1.WeaponFire_ShockCombo'
}
