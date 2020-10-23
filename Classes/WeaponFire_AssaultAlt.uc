class WeaponFire_AssaultAlt extends AssaultGrenade;

event ModeHoldFire()
{
    if (Weapon.Role == ROLE_Authority)
        Instigator.DeactivateSpawnProtection();
	Super.ModeHoldFire();
}

event ModeDoFire()
{
	Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo).Assault.Secondary.Fired += load;
    Super.ModeDoFire();
}

function Projectile SpawnProjectile(vector Start, rotator Dir)
{
    local Projectile g;
    local vector X, Y, Z;
    local float pawnSpeed;

    g = Weapon.Spawn(ProjectileClass, Instigator,, Start, Dir);
    if (g != None) {
        Weapon.GetViewAxes(X, Y, Z);
        pawnSpeed = X dot Instigator.Velocity;

        if ( Bot(Instigator.Controller) != None )
            g.Speed = mHoldSpeedMax;
        else
            g.Speed = mHoldSpeedMin + HoldTime * mHoldSpeedGainPerSec;
        g.Speed = FClamp(g.Speed, mHoldSpeedMin, mHoldSpeedMax);
        g.Speed = pawnSpeed + g.Speed;
        g.Velocity = g.Speed * vector(Dir);

        g.Damage *= DamageAtten;
    }
    return g;
}

defaultproperties
{
    ProjectileClass = Class'WormboGrenade'
}
