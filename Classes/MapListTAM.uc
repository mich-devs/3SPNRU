class MapListTAM extends MapList;

//var const config string ActiveMaplist;

static protected function string FindNextMap(MaplistManagerBase M, int GameIndex, int RecordIndex)
{
  	local int i;
	local array<string> Ar;
    local string CurrentMap;
    
	Ar = M.GetMaplist(GameIndex, RecordIndex);
    CurrentMap = M.GetURLMap(false);
    
    for (i = 0; i < Ar.Length; i++)
        if (Ar[i] ~= CurrentMap)
            break;

    if(++i >= Ar.Length)
        i = 0;
    
    return Ar[i];
}

static function string StaticGetNextMap(MaplistManagerBase M)
{
    local MaplistManager MP;
  	local int GameIndex, RecordIndex, MapIndex;
    local string NextMap;
    
	GameIndex = M.GetGameIndex(M.Level.Game.Class);
    //if(default.ActiveMaplist != "")
    //    RecordIndex = M.GetRecordIndex(GameIndex, default.ActiveMaplist);
    RecordIndex = M.GetActiveList(GameIndex);
    MapIndex = M.GetActiveMap(GameIndex, RecordIndex);
    MP = MaplistManager(M);
    
    if(MP == None)
        return FindNextMap(M, GameIndex, RecordIndex);

    NextMap = MP.GetActiveMapName(GameIndex, RecordIndex);
    
    if(NextMap == "")
    {
        MapIndex = 0;
        MP.SetActiveMap(GameIndex, RecordIndex, MapIndex);
        NextMap = MP.GetActiveMapName(GameIndex, RecordIndex);
    }

    if(MP.SetActiveMap(GameIndex, RecordIndex, ++MapIndex) < 0)
        MP.SetActiveMap(GameIndex, RecordIndex, 0);

    MP.SaveMapList(GameIndex, RecordIndex);

    return NextMap;
}

function string GetNextMap()
{
    return static.StaticGetNextMap(Level.Game.MaplistHandler);
}

defaultproperties
{
}
