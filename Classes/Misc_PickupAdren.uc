class Misc_PickupAdren extends AdrenalinePickup
    notplaceable;

//#exec NEW STATICMESH NAME=Question FILE=Meshes\questionmark.ase
#exec OBJ LOAD FILE=../3SPNv3177AT/Media/StaticMesh1.usx PACKAGE=3SPNv3177AT

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheStaticMesh(StaticMesh'Question');
}

simulated function UpdatePrecacheStaticMeshes()
{
    Level.AddPrecacheStaticMesh(StaticMesh'Question');
    Super.UpdatePrecacheStaticMeshes();
}

defaultproperties
{
     AdrenalineAmount=10.000000
     MaxDesireability=1.000000
     RespawnTime=33.000000
     PickupForce="HealthPack"
     StaticMesh=StaticMesh'3SPNv3177AT.Question'
     CullDistance=6500.000000
     DrawScale=1.000000
     TransientSoundVolume=0.350000
     RotationRate=(Yaw=35000)
}
