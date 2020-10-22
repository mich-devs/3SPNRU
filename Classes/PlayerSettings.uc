class PlayerSettings extends Object
    Config(User)
    PerObjectConfig;

struct TColoredName
{
    var string RealName;
    var string ColoredName;
};
var config array<TColoredName> ColoredNames;

struct TMiscSettings
{
    var config int    V;    // 3spn version who made this backup
    var config byte   DS;   // bDisableSpeed;
    var config byte   DI;   // bDisableInvis;
    var config byte   DD;   // bDisableBooster;
    var config byte   DB;   // bDisableBerserk;
    var config byte   DN;   // bDisableNecro;
    var config byte   SB;   // bUseBrightskins;
    var config byte   ST;   // bUseTeamColors;
    var config Color  CE;   // RedOrEnemy;
    var config Color  CA;   // BlueOrAlly;
    var config byte   FE;   // bForceRedEnemyModel;
    var config byte   FA;   // bForceBlueAllyModel;
    var config byte   FM;   // bUseTeamModels;
    var config string ME;   // RedEnemyModel;
    var config string MA;   // BlueAllyModel;
};
var config TMiscSettings MiscSettings;

var const string ModName;
var const int    ModVersion;

static function SaveMiscSettings(Misc_Player P)
{
    local PlayerSettings PS;

    PS = new(None, default.ModName) class'PlayerSettings';

    PS.MiscSettings.V = default.ModVersion;
    PS.MiscSettings.DS = byte(P.bDisableSpeed);
    PS.MiscSettings.DI = byte(P.bDisableInvis);
    PS.MiscSettings.DD = byte(P.bDisableBooster);
    PS.MiscSettings.DB = byte(P.bDisableBerserk);
    PS.MiscSettings.DN = byte(P.bDisableNecro);
    PS.MiscSettings.SB = byte(P.bUseBrightskins);
    PS.MiscSettings.ST = byte(P.bUseTeamColors);
    PS.MiscSettings.CE = P.RedOrEnemy;
    PS.MiscSettings.CA = P.BlueOrAlly;
    PS.MiscSettings.FE = byte(P.bForceRedEnemyModel);
    PS.MiscSettings.FA = byte(P.bForceBlueAllyModel);
    PS.MiscSettings.FM = byte(P.bUseTeamModels);
    PS.MiscSettings.ME = P.RedEnemyModel;
    PS.MiscSettings.MA = P.BlueAllyModel;
    PS.SaveConfig();

    PS = None;
}

static function RetrieveMiscSettings(Misc_Player P)
{
    local PlayerSettings PS;

    PS = new(None, default.ModName) class'PlayerSettings';

    if(PS.MiscSettings.V < default.ModVersion)
    {
        PS.MiscSettings.V = default.ModVersion;
        P.bDisableSpeed = bool(PS.MiscSettings.DS);
        P.bDisableInvis = bool(PS.MiscSettings.DI);
        P.bDisableBooster = bool(PS.MiscSettings.DD);
        P.bDisableBerserk = bool(PS.MiscSettings.DB);
        P.bDisableNecro = bool(PS.MiscSettings.DN);
        P.bUseBrightskins = bool(PS.MiscSettings.SB);
        P.bUseTeamColors = bool(PS.MiscSettings.ST);
        P.RedOrEnemy = PS.MiscSettings.CE;
        P.BlueOrAlly = PS.MiscSettings.CA;
        P.bForceRedEnemyModel = bool(PS.MiscSettings.FE);
        P.bForceBlueAllyModel = bool(PS.MiscSettings.FA);
        P.bUseTeamModels = bool(PS.MiscSettings.FM);
        P.RedEnemyModel = PS.MiscSettings.ME;
        P.BlueAllyModel = PS.MiscSettings.MA;
        P.SaveConfig();
        PS.SaveConfig();
    }

    PS = None;
}

static function SaveColoredName(PlayerReplicationInfo PRI, string ColoredName)
{
    local int i;
    local string PlayerName;
    local PlayerSettings PS;

    PlayerName = class'GUIComponent'.static.StripColorCodes(PRI.PlayerName);
    PS = new(None, default.ModName) class'PlayerSettings';

    for(i = 0; i < PS.ColoredNames.Length; i++)
        if(PS.ColoredNames[i].RealName ~= PlayerName)
        {
            PS.ColoredNames[i].ColoredName = ColoredName;
            PS.SaveConfig();
            PS = None;
            return;
        }

    PS.ColoredNames.Length = i + 1;
    PS.ColoredNames[i].RealName = PlayerName;
    PS.ColoredNames[i].ColoredName = ColoredName;
    PS.SaveConfig();
    PS = None;
}

static function string GetColoredName(PlayerReplicationInfo PRI)
{
    local int i, c, r;
    local string PlayerName;
    local PlayerSettings PS;

    PlayerName = class'GUIComponent'.static.StripColorCodes(PRI.PlayerName);
    PS = new(None, default.ModName) class'PlayerSettings';

    for(i = 0; i < PS.ColoredNames.Length; i++)
        if(PS.ColoredNames[i].RealName ~= PlayerName && class'GUIComponent'.static.StripColorCodes(PS.ColoredNames[i].ColoredName) ~= PlayerName)
        {
            if(class'GUIComponent'.static.StripColorCodes(PS.ColoredNames[i].ColoredName) != PlayerName)
            {
                // make name coloring case-insensitive
                c = 0;
                for(r = 0; r < Len(PlayerName); r++)
                {
                    while(c < Len(PS.ColoredNames[i].ColoredName) && Mid(PS.ColoredNames[i].ColoredName, c, 1) == Chr(27))
                        c += 4;
                    PS.ColoredNames[i].ColoredName = Left(PS.ColoredNames[i].ColoredName, c)
                                                   $ Mid(PlayerName, r, 1)
                                                   $ Mid(PS.ColoredNames[i].ColoredName, c + 1);
                    c++;
                }
            }

            if(class'GUIComponent'.static.StripColorCodes(PS.ColoredNames[i].ColoredName) ~= PlayerName)
                PlayerName = PS.ColoredNames[i].ColoredName;
            break;
        }

    PS = None;
    return PlayerName;
}

static function DeleteColoredName(PlayerReplicationInfo PRI)
{
    local int i;
    local string PlayerName;
    local PlayerSettings PS;

    PlayerName = class'GUIComponent'.static.StripColorCodes(PRI.PlayerName);
    PS = new(None, default.ModName) class'PlayerSettings';

    for(i = 0; i < PS.ColoredNames.Length; i++)
        if(PS.ColoredNames[i].RealName ~= PlayerName)
        {
            PS.ColoredNames.Remove(i, 1);
            PS.SaveConfig();
            break;
        }

    PS = None;
}

defaultproperties
{
     MiscSettings=(V=3177)
     ModName="3SPNxAT"
     ModVersion=3177
}
