class MapListAM extends MapList;

function string GetNextMap()
{
    return class'MapListTAM'.static.StaticGetNextMap(Level.Game.MaplistHandler);
}

defaultproperties
{
}
