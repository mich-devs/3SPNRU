class Team_GameBase extends TeamGame
    abstract
    Config;

//#exec OBJ LOAD FILE=TeamSymbols.utx

/* general and misc */
var config int      StartingHealth;
var config int      StartingArmor;
var config float    MaxHealth;

var float           AdrenalinePerDamage;    // adrenaline per 10 damage

var config bool     bDisableSpeed;
var config bool     bDisableBooster;
var config bool     bDisableInvis;
var config bool     bDisableBerserk;
var config bool     bDisableNecro;
var config int      MaxAdrenaline;
var array<string>   EnabledCombos;
var config bool     bSpectateAll;

var config bool     bForceRUP;              // force players to ready up after...
var config int      ForceSeconds;           // this many seconds

var Controller      DarkHorse;              // last player on a team when the other team has 3+
var string          NextMapString;          // used to save mid-game admin changes in the menu

var byte            Deaths[2];              // set to true if someone on a given team has died (not a flawless)

var bool            bDefaultsReset;
/* general and misc */

/* overtime related */
var config int      MinsPerRound;           // the number of minutes before a round goes into OT
var int             RoundTime;              // number of seconds remaining before round-OT
var bool            bRoundOT;               // true if we're in round-OT
var int             RoundOTTime;            // how long we've been in round-OT
var config int      OTDamage;               // the amount of damage players take in round-OT every...
var config int      OTInterval;             // <OTInterval> seconds
/* overtime related */

/* camping related */
var config float    CampThreshold;          // area a player must stay in to be considered camping
var int             CampInterval;           // time between flagging the same player
var config bool     bKickExcessiveCampers;  // kick players that camp 4 consecutive times
var config bool     bUseCamperIcon;         // reveal campers' location with icons
/* camping related */

/* timeout related */
var config int      Timeouts;               // number of timeouts per team

var byte            TimeOutTeam;            // team that called timeout
var int             TeamTimeOuts[2];        // number of timeouts remaining per team
var int             TimeOutCount;           // time remaining in timeout
var float           LastTimeOutUpdate;      // keep track of the last update so timeout requests aren't spammed
/* timeout related */

/* spawn related */
var bool            bFirstSpawn;            // first spawn of the round
/* spawn related */

/* round related */
var bool            bEndOfRound;            // true if a round has just ended
var bool            bRespawning;            // true if we're respawning players
var int             RespawnTime;            // time left to respawn
var int             LockTime;               // time left until weapons get unlocked
var int             NextRoundTime;          // time left until the next round starts
var int             NextRoundDelay;
var int             CurrentRound;           // the current round number (0 = game hasn't started)
/* round related */

var config bool     bSelfDamage;

/* weapon related */
struct WeaponData
{
    var string WeaponName;
    var int Ammo[2];                        // 0 = primary ammo, 1 = alt ammo
    var float MaxAmmo[2];                   // 1 is only used for WeaponDefaults
};

var WeaponData  WeaponInfo[10];
var WeaponData  WeaponDefaults[10];
var config bool	bModifyShieldGun;     // use the modified shield gun (higher shield jumps)

var config int  AssaultAmmo;
var config int  AssaultGrenades;
var config int  BioAmmo;
var config int  ShockAmmo;
var config int  LinkAmmo;
var config int  MiniAmmo;
var config int  FlakAmmo;
var config int  RocketAmmo;
var config int  LightningAmmo;

var bool        bWeaponsLocked;
/* weapon related */

var string GameName2;

var config bool EnableNewNet;
var TAM_Mutator MutTAM;

var config bool bDamageIndicator;

static function Texture ScanForLoadingScreens(coerce string PackageName, coerce string GroupName)
{
    local Object O;
    local int i;
    local array<Texture> Texs;

    O = DynamicLoadObject(PackageName $ "." $ GroupName, class'Object', true);

    if (O != None && O.Class.Name == 'Package')
        for (i = 0; i < 10; i++)
        {
            O = DynamicLoadObject(PackageName $ "." $ GroupName $ ".LoadingScreen" $ i, class'Object', true);
            if (Texture(O) != None)
                Texs[Texs.Length] = Texture(O);
        }

    if (Texs.Length > 0)
        return Texs[Rand(Texs.Length)];

    return None;
}

static function bool ReplaceLoadingScreen(PlayerController PlayerController, string MapName)
{
    local Object O;
    local UT2K4ServerLoading LoadingScreenObj;
    local Texture LoadingScreenTex;

    foreach PlayerController.AllObjects(class'Object', O)
    {
        if (LoadingScreenObj == None && O.Class == class'UT2K4ServerLoading')
            LoadingScreenObj = UT2K4ServerLoading(O);

        else if (LoadingScreenTex == None && O.Class.Name == 'Package' && O.Outer == None)
        {
            //LoadingScreenTex = ScanForLoadingScreens(O.Name, "3SPNv32AT");
            if (LoadingScreenTex == None)
                LoadingScreenTex = ScanForLoadingScreens(O.Name, "3SPNv3177AT");
        }

        if (LoadingScreenObj != None && LoadingScreenTex != None)
        {
            DrawOpImage(LoadingScreenObj.Operations[0]).Image = LoadingScreenTex;
            return true;
        }
    }

    return false;
}

static function string GetLoadingHint(PlayerController PlayerController, string MapName, Color ColorHint)
{
    if (ReplaceLoadingScreen(PlayerController, MapName) )
        return " ";
    else
        return Super.GetLoadingHint(PlayerController, MapName, ColorHint);
}

static function PrecacheGameTextures(LevelInfo MyLevel)
{
    class'xTeamGame'.static.PrecacheGameTextures(MyLevel);
}

static function PrecacheGameStaticMeshes(LevelInfo MyLevel)
{
	class'xDeathMatch'.static.PrecacheGameStaticMeshes(MyLevel);
}

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    if(Misc_BaseGRI(GameReplicationInfo) == None)
        return;

    Misc_BaseGRI(GameReplicationInfo).GameName = GameName2;

    Misc_BaseGRI(GameReplicationInfo).RoundTime = MinsPerRound * 60;

    Misc_BaseGRI(GameReplicationInfo).StartingHealth = StartingHealth;
    Misc_BaseGRI(GameReplicationInfo).StartingArmor = StartingArmor;
    Misc_BaseGRI(GameReplicationInfo).MaxHealth = MaxHealth;

    Misc_BaseGRI(GameReplicationInfo).MinsPerRound = MinsPerRound;
    Misc_BaseGRI(GameReplicationInfo).OTDamage = OTDamage;
    Misc_BaseGRI(GameReplicationInfo).OTInterval = OTInterval;

    Misc_BaseGRI(GameReplicationInfo).CampThreshold = CampThreshold;
    Misc_BaseGRI(GameReplicationInfo).bKickExcessiveCampers = bKickExcessiveCampers;

    Misc_BaseGRI(GameReplicationInfo).bDisableSpeed = bDisableSpeed;
    Misc_BaseGRI(GameReplicationInfo).bDisableInvis = bDisableInvis;
    Misc_BaseGRI(GameReplicationInfo).bDisableBooster = bDisableBooster;
    Misc_BaseGRI(GameReplicationInfo).bDisableBerserk = bDisableBerserk;
    TAM_GRI(GameReplicationInfo).bDisableNecro = bDisableNecro;
    Misc_BaseGRI(GameReplicationInfo).MaxAdrenaline = MaxAdrenaline;
    Misc_BaseGRI(GameReplicationInfo).bSpectateAll = bSpectateAll;

    Misc_BaseGRI(GameReplicationInfo).bForceRUP = bForceRUP;

    Misc_BaseGRI(GameReplicationInfo).Timeouts = Timeouts;
    
	Misc_BaseGRI(GameReplicationInfo).EnableNewNet = EnableNewNet;
	Misc_BaseGRI(GameReplicationInfo).bDamageIndicator = bDamageIndicator;

    bWeaponsLocked = true;
    Misc_BaseGRI(GameReplicationInfo).bWeaponsLocked = true;
}

function GetServerDetails(out ServerResponseLine ServerState)
{
    Super.GetServerDetails(ServerState);

    AddServerDetail(ServerState, "3SPN Version", class'Misc_BaseGRI'.default.Version);
}

function GetServerPlayers( out ServerResponseLine ServerState )
{
    local Mutator M;
	local Controller C;
	local Misc_PRI PRI;
	local int i, TeamFlag[2];

	i = ServerState.PlayerInfo.Length;
	TeamFlag[0] = 1 << 29;
	TeamFlag[1] = TeamFlag[0] << 1;

	for( C=Level.ControllerList;C!=None;C=C.NextController )
    {
        PRI = Misc_PRI(C.PlayerReplicationInfo);
        if( (PRI != None) && !PRI.bBot && MessagingSpectator(C) == None )
        {
            ServerState.PlayerInfo.Length = i+1;
            ServerState.PlayerInfo[i].PlayerNum  = C.PlayerNum;
            ServerState.PlayerInfo[i].PlayerName = PRI.GetColoredName();
            ServerState.PlayerInfo[i].Score		 = PRI.Score;
            ServerState.PlayerInfo[i].Ping		 = 4 * PRI.Ping;
            if (bTeamGame && PRI.Team != None)
                ServerState.PlayerInfo[i].StatsID = ServerState.PlayerInfo[i].StatsID | TeamFlag[PRI.Team.TeamIndex];
            i++;
        }
    }

	// Ask the mutators if they have anything to add.
	for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
		M.GetServerPlayers(ServerState);

    // Add team info
    if(Teams[0] == None || Teams[1] == None)
        return;

    /* i = ServerState.PlayerInfo.Length;
    ServerState.PlayerInfo.Length = i + 2;
    ServerState.PlayerInfo[i].PlayerName = "ýýý( ýRed Teamýýý )";
    ServerState.PlayerInfo[i].Score = Teams[0].Score;
    ServerState.PlayerInfo[i+1].PlayerName = "ýýý( €ýBlue Teamýýý )";
    ServerState.PlayerInfo[i+1].Score = Teams[1].Score; */
}

static function FillPlayInfo(PlayInfo PI)
{
    Super.FillPlayInfo(PI);

    PI.AddSetting("3SPN", "StartingHealth", "Starting Health", 0, 100, "Text", "3;0:999");
    PI.AddSetting("3SPN", "StartingArmor", "Starting Armor", 0, 101, "Text", "3;0:999");
    PI.AddSetting("3SPN", "MaxHealth", "Max Health", 0, 102, "Text", "8;1.0:2.0");

    PI.AddSetting("3SPN", "MinsPerRound", "Minutes per Round", 0, 120, "Text", "3;0:999");
    PI.AddSetting("3SPN", "OTDamage", "Overtime Damage", 0, 121, "Text", "3;0:999");
    PI.AddSetting("3SPN", "OTInterval", "Overtime Damage Interval", 0, 122, "Text", "3;0:999");

    PI.AddSetting("3SPN", "CampThreshold", "Camp Area", 0, 150, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "bKickExcessiveCampers", "Kick Excessive Campers", 0, 151, "Check",,, True);
    PI.AddSetting("3SPN", "bUseCamperIcon", "Camper Icons", 0, 152, "Check",,, True);
    PI.AddSetting("3SPN", "bSelfDamage", "Self Damage", 0, 153, "Check",,, True);

    PI.AddSetting("3SPN", "bForceRUP", "Force Ready", 0, 175, "Check",,, True);
    PI.AddSetting("3SPN", "ForceSeconds", "Force Time", 0, 176, "Text", "3;0:999",, True);

    PI.AddSetting("3SPN", "bDisableSpeed", "Disable Speed", 0, 200, "Check");
    PI.AddSetting("3SPN", "bDisableInvis", "Disable Invis", 0, 201, "Check");
    PI.AddSetting("3SPN", "bDisableBerserk", "Disable Berserk", 0, 202, "Check");
    PI.AddSetting("3SPN", "bDisableBooster", "Disable Booster", 0, 203, "Check");
    PI.AddSetting("3SPN", "MaxAdrenaline", "Maximum Adrenaline", 0, 210, "Text", "3;100:999",, True);

    PI.AddSetting("3SPN", "Timeouts", "TimeOuts Per Team", 0, 220, "Text", "3;0:999",, True);

    PI.AddSetting("3SPN", "bModifyShieldGun", "Use Modified Shield Gun", 0, 299, "Check",,, True);
    PI.AddSetting("3SPN", "AssaultAmmo", "Assault Ammunition", 0, 300, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "AssaultGrenades", "Assault Grenades", 0, 301, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "BioAmmo", "Bio Ammunition", 0, 302, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "ShockAmmo", "Shock Ammunition", 0, 303, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "LinkAmmo", "Link Ammunition", 0, 304, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "MiniAmmo", "Mini Ammunition", 0, 305, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "FlakAmmo", "Flak Ammunition", 0, 306, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "RocketAmmo", "Rocket Ammunition", 0, 307, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "LightningAmmo", "Lightning Ammunition", 0, 308, "Text", "3;0:999",, True);

    PI.AddSetting("3SPN", "EnableNewNet", "Enable Enhanced NetCode", 0, 400, "Check");
    PI.AddSetting("3SPN", "bDamageIndicator", "Enable Damage Indicator", 0, 401, "Check");    

    class'TAM_Mutator'.static.FillPlayInfo(PI);
    PI.PopClass();
}

static event string GetDescriptionText(string PropName)
{
    switch(PropName)
    {
        case "StartingHealth":      return "Base health at round start.";
        case "StartingArmor":       return "Base armor at round start.";

        case "MinsPerRound":        return "Round time-limit before overtime.";
        case "OTDamage":            return "The amount of damage all players while in OT.";
        case "OTInterval":          return "The interval at which OT damage is given.";

        case "MaxHealth":           return "The maximum amount of health and armor a player can have.";

        case "CampThreshold":       return "The area a player must stay in to be considered camping.";
        case "bKickExcessiveCampers": return "Kick players that camp 4 consecutive times.";
        case "bUseCamperIcon":      return "Enable to reveal campers with icons at their exact location.";
        case "bSelfDamage":         return "Allow players to damage theirselves.";

        case "bDisableSpeed":       return "Disable the Speed adrenaline combo.";
        case "bDisableInvis":       return "Disable the Invisibility adrenaline combo.";
        case "bDisableBooster":     return "Disable the Booster adrenaline combo.";
        case "bDisableBerserk":     return "Disable the Berserk adrenaline combo.";
        case "MaxAdrenaline":       return "Maximum amount of adrenaline a player can have.";

        case "bForceRUP":           return "Force players to ready up after a set amount of time";
        case "ForceSeconds":        return "The amount of time players have to ready up before the game starts automatically";

        case "Timeouts":            return "Number of Timeouts a team can call in one game.";

        case "bModifyShieldGun":    return "The Shield Gun will have more kick back for higher shield jumps";
        case "AssaultAmmo":         return "Amount of Assault Ammunition to give in a round.";
        case "AssaultGrenades":     return "Amount of Assault Grenades to give in a round.";
        case "BioAmmo":             return "Amount of Bio Rifle Ammunition to give in a round.";
        case "LinkAmmo":            return "Amount of Link Gun Ammunition to give in a round.";
        case "ShockAmmo":           return "Amount of Shock Ammunition to give in a round.";
        case "MiniAmmo":            return "Amount of Mini Ammunition to give in a round.";
        case "FlakAmmo":            return "Amount of Flak Ammunition to give in a round.";
        case "RocketAmmo":          return "Amount of Rocket Ammunition to give in a round.";
        case "LightningAmmo":       return "Amount of Lightning Ammunition to give in a round.";
        
        case "EnableNewNet":        return "Make enhanced netcode available for players.";
        case "bDamageIndicator":    return "Make the numeric damage indicator available for players.";
    }

    return Super.GetDescriptionText(PropName);
}

function ParseOptions(string Options)
{
    local string InOpt;

    InOpt = ParseOption(Options, "StartingHealth");
    if(InOpt != "")
        StartingHealth = int(InOpt);

    InOpt = ParseOption(Options, "StartingArmor");
    if(InOpt != "")
        StartingArmor = int(InOpt);

    InOpt = ParseOption(Options, "MaxHealth");
    if(InOpt != "")
        MaxHealth = float(InOpt);

    InOpt = ParseOption(Options, "MinsPerRound");
    if(InOpt != "")
        MinsPerRound = int(InOpt);

    InOpt = ParseOption(Options, "OTDamage");
    if(InOpt != "")
        OTDamage = int(InOpt);

    InOpt = ParseOption(Options, "OTInterval");
    if(InOpt != "")
        OTInterval = int(InOpt);

    InOpt = ParseOption(Options, "CampThreshold");
    if(InOpt != "")
        CampThreshold = float(InOpt);

    InOpt = ParseOption(Options, "ForceRUP");
    if(InOpt != "")
        bForceRUP = bool(InOpt);

    InOpt = ParseOption(Options, "KickExcessiveCampers");
    if(InOpt != "")
        bKickExcessiveCampers = bool(InOpt);

    InOpt = ParseOption(Options, "DisableSpeed");
    if(InOpt != "")
        bDisableSpeed = bool(InOpt);

    InOpt = ParseOption(Options, "DisableInvis");
    if(InOpt != "")
        bDisableInvis = bool(InOpt);

    InOpt = ParseOption(Options, "DisableBerserk");
    if(InOpt != "")
        bDisableBerserk = bool(InOpt);

    InOpt = ParseOption(Options, "DisableBooster");
    if(InOpt != "")
        bDisableBooster = bool(InOpt);

    InOpt = ParseOption(Options, "Timeouts");
    if(InOpt != "")
        Timeouts = int(InOpt);

    InOpt = ParseOption(Options, "MaxAdrenaline");
    if(InOpt != "")
        MaxAdrenaline = int(InOpt);

    InOpt = ParseOption(Options, "SelfDamage");
    if(InOpt != "")
        bSelfDamage = bool(InOpt);    
    
    InOpt = ParseOption(Options, "AssaultAmmo");
    if(InOpt != "")
        AssaultAmmo = int(InOpt);

    InOpt = ParseOption(Options, "AssaultGrenades");
    if(InOpt != "")
        AssaultGrenades = int(InOpt);

    InOpt = ParseOption(Options, "BioAmmo");
    if(InOpt != "")
        BioAmmo = int(InOpt);

    InOpt = ParseOption(Options, "ShockAmmo");
    if(InOpt != "")
        ShockAmmo = int(InOpt);

    InOpt = ParseOption(Options, "LinkAmmo");
    if(InOpt != "")
        LinkAmmo = int(InOpt);

    InOpt = ParseOption(Options, "MiniAmmo");
    if(InOpt != "")
        MiniAmmo = int(InOpt);

    InOpt = ParseOption(Options, "FlakAmmo");
    if(InOpt != "")
        FlakAmmo = int(InOpt);

    InOpt = ParseOption(Options, "RocketAmmo");
    if(InOpt != "")
        RocketAmmo = int(InOpt);

    InOpt = ParseOption(Options, "LightningAmmo");
    if(InOpt != "")
        LightningAmmo = int(InOpt);
}

event InitGame(string Options, out string Error)
{
    local int i;
    local class<Weapon> WeaponClass;
    
    Super.InitGame(Options, Error);
    ParseOptions(Options);
    
	class'TAM_Mutator'.default.EnableNewNet = EnableNewNet;
	foreach DynamicActors(class'TAM_Mutator', MutTAM)
		break;
	MutTAM.EnableNewNet = EnableNewNet;    
    
    MutTAM.InitWeapons(AssaultAmmo,AssaultGrenades,BioAmmo,ShockAmmo,LinkAmmo,MiniAmmo,FlakAmmo,RocketAmmo,LightningAmmo);

    class'xPawn'.Default.ControllerClass = class'Misc_Bot';

    MaxLives = 1;
    bForceRespawn = true;
    bAllowWeaponThrowing = true;
    SpawnProtectionTime = 0.000000;

    TimeOutCount = 0;
    TeamTimeOuts[0] = TimeOuts;
    TeamTimeOuts[1] = TimeOuts;

    /* weapon related */
    for(i = 0; i < ArrayCount(WeaponInfo); i++)
    {
        if(WeaponInfo[i].WeaponName ~= "")
            continue;

        if(WeaponInfo[i].WeaponName ~= "xWeapons.AssaultRifle")
        {
            WeaponInfo[i].Ammo[0] = AssaultAmmo;
            WeaponInfo[i].Ammo[1] = AssaultGrenades;
        }
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.BioRifle")
            WeaponInfo[i].Ammo[0] = BioAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.ShockRifle")
            WeaponInfo[i].Ammo[0] = ShockAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.LinkGun")
            WeaponInfo[i].Ammo[0] = LinkAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.MiniGun")
            WeaponInfo[i].Ammo[0] = MiniAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.FlakCannon")
            WeaponInfo[i].Ammo[0] = FlakAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.RocketLauncher")
            WeaponInfo[i].Ammo[0] = RocketAmmo;
        else if(WeaponInfo[i].WeaponName ~= "xWeapons.SniperRifle")
            WeaponInfo[i].Ammo[0] = LightningAmmo;

        WeaponClass = class<Weapon>(DynamicLoadObject(WeaponInfo[i].WeaponName, class'Class'));

        if(WeaponClass == None)
        {
            log("Could not find weapon:"@WeaponInfo[i].WeaponName, '3SPN');
            continue;
        }

        // remember defaults
        WeaponDefaults[i].WeaponName = WeaponInfo[i].WeaponName;

        if(class<Translauncher>(WeaponClass) != None && WeaponInfo[i].Ammo[0] > 0)
        {
            WeaponDefaults[i].MaxAmmo[0] = Class'XWeapons.Translauncher'.default.AmmoChargeRate;
            WeaponDefaults[i].MaxAmmo[1] = Class'XWeapons.Translauncher'.default.AmmoChargeF;
            WeaponDefaults[i].Ammo[0] = Class'XWeapons.Translauncher'.default.AmmoChargeMax;
            class'XWeapons.Translauncher'.default.AmmoChargeRate = 0.000000;
		    class'XWeapons.Translauncher'.default.AmmoChargeMax = WeaponInfo[i].Ammo[0];
		    class'XWeapons.Translauncher'.default.AmmoChargeF = WeaponInfo[i].Ammo[0];

            class'Misc_Pawn'.default.RequiredEquipment[i + 1] = WeaponInfo[i].WeaponName;

            continue;
        }

        if(WeaponClass.default.FireModeClass[0].default.AmmoClass != None)
        {
            WeaponDefaults[i].Ammo[0] = WeaponClass.default.FireModeClass[0].default.AmmoClass.default.InitialAmount;
            WeaponDefaults[i].MaxAmmo[0] = WeaponClass.default.FireModeClass[0].default.AmmoClass.default.MaxAmmo;
            WeaponClass.default.FireModeClass[0].default.AmmoClass.default.InitialAmount = Min(999, WeaponInfo[i].Ammo[0]);
            WeaponClass.default.FireModeClass[0].default.AmmoClass.default.MaxAmmo = Min(999, WeaponInfo[i].Ammo[0] * WeaponInfo[i].MaxAmmo[0]);
        }

        if(WeaponClass.default.FireModeClass[1].default.AmmoClass != None && (WeaponClass.default.FireModeClass[0].default.AmmoClass != WeaponClass.default.FireModeClass[1].default.AmmoClass))
        {
            WeaponDefaults[i].Ammo[1] = WeaponClass.default.FireModeClass[1].default.AmmoClass.default.InitialAmount;
            WeaponDefaults[i].MaxAmmo[1] = WeaponClass.default.FireModeClass[1].default.AmmoClass.default.MaxAmmo;
            WeaponClass.default.FireModeClass[1].default.AmmoClass.default.InitialAmount = Min(999, WeaponInfo[i].Ammo[1]);
            WeaponClass.default.FireModeClass[1].default.AmmoClass.default.MaxAmmo = Min(999, WeaponInfo[i].Ammo[1] * WeaponInfo[i].MaxAmmo[0]);
        }

        class'Misc_Pawn'.default.RequiredEquipment[i + 1] = WeaponInfo[i].WeaponName;
    }

    if(bModifyShieldGun)
	{
		class'XWeapons.ShieldFire'.default.SelfForceScale = 1.500000;
		class'XWeapons.ShieldFire'.default.SelfDamageScale = 0.100000;
		class'XWeapons.ShieldFire'.default.MinSelfDamage = 0.000000;
	}

    class'FlakChunk'.default.MyDamageType = class'DamType_FlakChunk';
    class'FlakShell'.default.MyDamageType = class'DamType_FlakShell';
    class'BioGlob'.default.MyDamageType = class'DamType_BioGlob';
    /* weapon related */

    /* combo related */
    if(!bDisableSpeed)
        EnabledCombos[EnabledCombos.Length] = "xGame.ComboSpeed";

    if(!bDisableBooster)
        EnabledCombos[EnabledCombos.Length] = "xGame.ComboDefensive";

    if(!bDisableBerserk)
        EnabledCombos[EnabledCombos.Length] = "xGame.ComboBerserk";

    if(!bDisableInvis)
        EnabledCombos[EnabledCombos.Length] = "xGame.ComboInvis";
    /* combo related */

    SaveConfig();
}

function AddDefaultInventory(Pawn P)
{
	Super.AddDefaultInventory(P);
    MutTAM.GiveAmmo(P);
}

static function bool AllowMutator(string MutatorClassName)
{
    if(MutatorClassName == "" || InStr(MutatorClassName, "UTComp") != -1)
        return false;

    return Super.AllowMutator(MutatorClassName);
}

auto state PendingMatch
{
    function Timer()
    {
        local Controller P;
        local bool bReady;

        Global.Timer();

        // first check if there are enough net players, and enough time has elapsed to give people
        // a chance to join
        if ( NumPlayers == 0 )
			bWaitForNetPlayers = true;

        if ( bWaitForNetPlayers && (Level.NetMode != NM_Standalone) )
        {
            if ( NumPlayers >= MinNetPlayers )
                ElapsedTime++;
            else
                ElapsedTime = 0;

            if ( (NumPlayers == MaxPlayers) || (ElapsedTime > NetWait) )
            {
                bWaitForNetPlayers = false;
                CountDown = Default.CountDown;
            }
        }
        else if(bForceRUP && bPlayersMustBeReady)
            ElapsedTime++;

        if ( (Level.NetMode != NM_Standalone) && (bWaitForNetPlayers || (bTournament && (NumPlayers < MaxPlayers))) )
        {
       		PlayStartupMessage();
            return;
		}

		// check if players are ready
        bReady = true;
        StartupStage = 1;
        if ( !bStartedCountDown && (bTournament || bPlayersMustBeReady || (Level.NetMode == NM_Standalone)) )
        {
            for (P=Level.ControllerList; P!=None; P=P.NextController )
                if ( P.IsA('PlayerController') && (P.PlayerReplicationInfo != None)
                    && P.bIsPlayer && P.PlayerReplicationInfo.bWaitingPlayer
                    && !P.PlayerReplicationInfo.bReadyToPlay )
                    bReady = false;
        }

        // force ready after 60-ish seconds
        if(!bReady && bForceRUP && bPlayersMustBeReady && (ElapsedTime >= ForceSeconds))
                bReady = true;

        if ( bReady && !bReviewingJumpspots )
        {
			bStartedCountDown = true;
            CountDown--;
            if ( CountDown <= 0 )
                StartMatch();
            else
                StartupStage = 5 - CountDown;
        }
		PlayStartupMessage();
    }
}

/* timeouts */
// get the state of timeouts (-1 = N/A, 0 = none pending, 1 = one pending on same team, 2 = one pending on other team, 3 = timeouts disabled, 4 = out of timeouts)
function int GetTimeoutState(PlayerController caller)
{
	if(bWaitingToStartMatch)
		return -1;

	if(caller == None || caller.PlayerReplicationInfo == None)
		return -1;

    if(caller.PlayerReplicationInfo.bAdmin) // admins can always call timeouts
        return 0;

    if(Level.TimeSeconds - LastTimeOutUpdate < 3.0)
        return -1;

    if(caller.PlayerReplicationInfo.Team == None)
        return -1;

	if(caller.PlayerReplicationInfo.bOnlySpectator)
		return -1;

	// check if timeouts are even enabled
	if(TimeOuts == 0)
		return 3;

	if(TimeOutTeam == caller.PlayerReplicationInfo.Team.TeamIndex)
		return 1;

    if(TimeOutCount > 0 || TimeOutTeam != 255)
		return 2;

	if(TeamTimeOuts[caller.PlayerReplicationInfo.Team.TeamIndex] <= 0)
		return 4;

    return 0;
}


// check if a team has timeouts left, and if so, pause the game at the end of the current round
function CallTimeout(PlayerController caller)
{
	local Controller C;
	local int toState;

	toState = GetTimeoutState(caller);

	if(toState == -1)
		return;

    LastTimeOutUpdate = Level.TimeSeconds;

	if(caller.PlayerReplicationInfo == None || (caller.PlayerReplicationInfo.Team == None && !caller.PlayerReplicationInfo.bAdmin))
		return;
	else if(toState == 3)
	{
		caller.ClientMessage("Timeouts are disabled on this server");
		return;
	}
	else if(toState == 1)
	{
		if(TimeOutCount > 0)
		{
			caller.ClientMessage("You can not cancel a Timeout once it takes effect.");
		}
		else
		{
			EndTimeout();

			for(C = Level.ControllerList; C != None; C = C.NextController)
			{
				if(C != None && C.IsA('PlayerController'))
				{
					if(caller.PlayerReplicationInfo.Team.TeamIndex == 0)
						PlayerController(C).ClientMessage("Red Team canceled the Timeout");
					else
						PlayerController(C).ClientMessage("Blue Team canceled the Timeout");
				}
			}
		}

		return;
	}
	else if(toState == 2)
	{
		caller.ClientMessage("A Timeout is already pending");
		return;
	}
    else if(toState == 4)
    {
        caller.ClientMessage("Your team has no Timeouts remaining");
        return;
    }

    if(caller.PlayerReplicationInfo.bAdmin)
    {
        if(TimeOutCount > 0)
        {
            EndTimeout();

            for(C = Level.ControllerList; C != None; C = C.NextController)
			{
				if(C != None && C.IsA('PlayerController'))
				{
					PlayerController(C).ClientMessage("Admin canceled the Timeout");
				}
			}
        }
        else
        {
            //TimeOutCount = default.TimeOutCount;
            TimeOutTeam = 3;

            for(C = Level.ControllerList; C != None; C = C.NextController)
	        {
		        if(C != None && C.IsA('PlayerController'))
		        {
				    PlayerController(C).ClientMessage("Admin called a Timeout");
		        }
	        }
        }
    }
    else
    {
        //TimeOutCount = default.TimeOutCount;
		TimeOutTeam = caller.PlayerReplicationInfo.Team.TeamIndex;

	    for(C = Level.ControllerList; C != None; C = C.NextController)
	    {
		    if(C != None && C.IsA('PlayerController'))
		    {
			    if(TimeOutTeam == 0)
				    PlayerController(C).ClientMessage("Red Team called a Timeout");
			    else
				    PlayerController(C).ClientMessage("Blue Team called a Timeout");
		    }
	    }
    }
}

// end el timeouto
function EndTimeOut()
{
    TimeOutCount = 0;
    TimeOutTeam = default.TimeOutTeam;
}
/* timeouts */

function ScoreKill(Controller Killer, Controller Other)
{
    Super.ScoreKill(Killer, Other);

    if(Other != None && Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.Score < 0)
        Other.PlayerReplicationInfo.Score = 0;
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation,
                          out vector Momentum, class<DamageType> DamageType)
{
    local Misc_PRI PRI;
    local int OldDamage;
    local int NewDamage;
    local int RealDamage;
    local int Result;
    local float Score;
    local float RFF;
    local float FF;

    local vector EyeHeight;
    
    if(bEndOfRound || LockTime > 0)
        return 0;

    if(injured != None && injured.SpawnTime > Level.TimeSeconds)
        return 0;
    
    if(!bSelfDamage && injured == instigatedBy)
        return 0;
    
    if(DamageType == Class'DamTypeSuperShockBeam')
        return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    if(Misc_Pawn(instigatedBy) != None && instigatedBy.Controller != None && injured.GetTeamNum() != 255 && instigatedBy.GetTeamNum() != 255)
    {
        PRI = Misc_PRI(instigatedBy.PlayerReplicationInfo);
        if(PRI == None)
            return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

        /* same teams */
        if(injured.GetTeamNum() == instigatedBy.GetTeamNum() && FriendlyFireScale > 0.0)
        {
            RFF = PRI.ReverseFF;

            if(RFF > 0.0 && injured != instigatedBy)
            {
                instigatedBy.TakeDamage(Damage * RFF * FriendlyFireScale, instigatedBy, HitLocation, Momentum, DamageType);
                Damage -= (Damage * RFF * FriendlyFireScale);
            }

            OldDamage = PRI.AllyDamage;

            RealDamage = OldDamage + Damage;
            if(injured == instigatedBy)
            {
                if(class<DamType_Camping>(DamageType) != None || class<DamType_Overtime>(DamageType) != None)
                    return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

                if(class<DamTypeShieldImpact>(DamageType) != None)
                    NewDamage = OldDamage;
                else
                    NewDamage = RealDamage;
            }
            else
                NewDamage = OldDamage + (Damage * (FriendlyFireScale - (FriendlyFireScale * RFF)));

            PRI.AllyDamage = NewDamage;

            Score = NewDamage - OldDamage;
            if(Score > 0.0)
            {
                if(injured != instigatedBy)
                {
                    if(RFF < 1.0)
                    {
                        RFF = FMin(RFF + (Damage * 0.0015), 1.0);
                        GameEvent("RFFChange", string(RFF - PRI.ReverseFF), PRI);
                        PRI.ReverseFF = RFF;
                    }

                    EyeHeight.z = instigatedBy.EyeHeight;
                    if(Misc_Player(instigatedBy.Controller) != None)
                    {
                        Misc_Player(instigatedBy.Controller).HitDamage -= Score;
                        Misc_Player(instigatedBy.Controller).bHitContact = FastTrace(injured.Location, instigatedBy.Location + EyeHeight);
                        Misc_Player(instigatedBy.Controller).HitPawn = injured;
                    }
                }

                if(Misc_Player(instigatedBy.Controller) != None)
                {
                    Misc_Player(instigatedBy.Controller).NewFriendlyDamage += Score * 0.01;

                    if(Misc_Player(instigatedBy.Controller).NewFriendlyDamage >= 1.0)
                    {
                        ScoreEvent(PRI, -int(Misc_Player(instigatedBy.Controller).NewFriendlyDamage), "FriendlyDamage");
                        Misc_Player(instigatedBy.Controller).NewFriendlyDamage -= int(Misc_Player(instigatedBy.Controller).NewFriendlyDamage);
                    }
                }
                PRI.Score = FMax(0, PRI.Score - Score * 0.01);
                instigatedBy.Controller.AwardAdrenaline((-Score * 0.10) * AdrenalinePerDamage);
            }

            FF = FriendlyFireScale;
            FriendlyFireScale -= (FriendlyFireScale * RFF);
            Result = Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
            FriendlyFireScale = FF;
            return Result;
        }
        else if(injured.GetTeamNum() != instigatedBy.GetTeamNum()) // different teams
        {
            OldDamage = PRI.EnemyDamage;
            NewDamage = OldDamage + Damage;
            PRI.EnemyDamage = NewDamage;

            Score = NewDamage - OldDamage;
            if(Score > 0.0)
            {
                if(Misc_Player(instigatedBy.Controller) != None)
                {
                    Misc_Player(instigatedBy.Controller).NewEnemyDamage += Score * 0.01;
                    if(Misc_Player(instigatedBy.Controller).NewEnemyDamage >= 1.0)
                    {
                        ScoreEvent(PRI, int(Misc_Player(instigatedBy.Controller).NewEnemyDamage), "EnemyDamage");
                        Misc_Player(instigatedBy.Controller).NewEnemyDamage -= int(Misc_Player(instigatedBy.Controller).NewEnemyDamage);
                    }

                    EyeHeight.z = instigatedBy.EyeHeight;
                    if(Misc_Player(instigatedBy.Controller) != None)
                    {
                        Misc_Player(instigatedBy.Controller).HitDamage += Score;
                        Misc_Player(instigatedBy.Controller).bHitContact = FastTrace(injured.Location, instigatedBy.Location + EyeHeight);
                        Misc_Player(instigatedBy.Controller).HitPawn = injured;
                    }
                }
                PRI.Score += Score * 0.01;
                instigatedBy.Controller.AwardAdrenaline((Score * 0.10) * AdrenalinePerDamage);
            }

            if(Damage > (injured.Health + injured.ShieldStrength + 50) &&
                Damage / (injured.Health + injured.ShieldStrength) > 2)
            {
                PRI.OverkillCount++;
                SpecialEvent(PRI, "Overkill");

                if(Misc_Player(instigatedBy.Controller) != None)
                    Misc_Player(instigatedBy.Controller).ReceiveLocalizedMessage(class'Message_Overkill');
                // overkill
            }

            /* hitstats */
            // in order of most common
            if(DamageType == class'DamType_FlakChunk')
            {
                PRI.Flak.Primary.Hit++;
                PRI.Flak.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamType_FlakShell')
            {
                PRI.Flak.Secondary.Hit++;
                PRI.Flak.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeRocket')
            {
                PRI.Rockets.Hit++;
                PRI.Rockets.Damage += Damage;
            }
            else if(DamageType == class'DamTypeSniperShot')
            {
                PRI.Sniper.Hit++;
                PRI.Sniper.Damage += Damage;
            }
            else if(DamageType == class'DamTypeShockBeam')
            {
                PRI.Shock.Primary.Hit++;
                PRI.Shock.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeShockBall')
            {
                PRI.Shock.Secondary.Hit++;
                PRI.Shock.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamType_ShockCombo')
            {
                PRI.Combo.Hit++;
                PRI.Combo.Damage += Damage;
            }
            else if(DamageType == class'DamTypeMinigunBullet')
            {
                PRI.Mini.Primary.Hit++;
                PRI.Mini.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeMinigunAlt')
            {
                PRI.Mini.Secondary.Hit++;
                PRI.Mini.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeLinkPlasma')
            {
                PRI.Link.Primary.Hit++;
                PRI.Link.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeLinkShaft')
            {
                PRI.Link.Secondary.Hit++;
                PRI.Link.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamType_HeadShot')
            {
                PRI.HeadShots++;
                PRI.Sniper.Hit++;
                PRI.Sniper.Damage += Damage;
            }
            else if(DamageType == class'DamType_BioGlob')
            {
                PRI.Bio.Hit++;
                PRI.Bio.Damage += Damage;
            }
            else if(DamageType == class'DamTypeAssaultBullet')
            {
                PRI.Assault.Primary.Hit++;
                PRI.Assault.Primary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeAssaultGrenade')
            {
                PRI.Assault.Secondary.Hit++;
                PRI.Assault.Secondary.Damage += Damage;
            }
            else if(DamageType == class'DamTypeRocketHoming')
            {
                PRI.Rockets.Hit++;
                PRI.Rockets.Damage += Damage;
            }
            else if(DamageType == class'DamTypeShieldImpact')
                PRI.SGDamage += Damage;
            /* hitstats */
        }
    }

    return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
}

/* Return the 'best' player start for this player to start from.
 */
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
    local NavigationPoint N, BestStart;
    // local Teleporter Tel;
    local float BestRating, NewRating;
    local byte Team;

	if((Player != None) && (Player.StartSpot != None))
		LastPlayerStartSpot = Player.StartSpot;

    // always pick StartSpot at start of match
    if(Level.NetMode == NM_Standalone && bWaitingToStartMatch && Player != None && Player.StartSpot != None)
    {
        return Player.StartSpot;
    }

    /* if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player, InTeam, incomingName);
        if ( N != None )
            return N;
    } */

    // if incoming start is specified, then just use it
    /* if( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if( string(Tel.Tag)~=incomingName )
                return Tel; */

    // use InTeam if player doesn't have a team yet
    if((Player != None) && (Player.PlayerReplicationInfo != None))
    {
        if(Player.PlayerReplicationInfo.Team != None)
            Team = Player.PlayerReplicationInfo.Team.TeamIndex;
        else
            Team = InTeam;
    }
    else
        Team = InTeam;

    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        if(N.IsA('PathNode') || N.IsA('PlayerStart') || N.IsA('JumpSpot'))
            NewRating = RatePlayerStart(N, Team, Player);
        else
            NewRating = 1;
        if ( NewRating > BestRating )
        {
            BestRating = NewRating;
            BestStart = N;
        }
    }

    if (BestStart == None)
    {
        // log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
		BestRating = -100000000;
        ForEach AllActors( class 'NavigationPoint', N )
        {
            NewRating = RatePlayerStart(N,0,Player);
            if ( InventorySpot(N) != None )
				NewRating -= 50;
			NewRating += 20 * FRand();
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = N;
            }
        }
    }

	LastStartSpot = BestStart;
    if(Player != None)
        Player.StartSpot = BestStart;

	if(!bWaitingToStartMatch)
		bFirstSpawn = false;

    if(Misc_Player(Player) != None)
        Misc_Player(Player).DeadClientSetViewTarget(BestStart);

    return BestStart;
} // FindPlayerStart()

// rate whether player should spawn at the chosen navigationPoint or not
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local NavigationPoint P;
    local float Score, NextDist;
    local Controller OtherPlayer;

    /* if (!TAM_Mutator(BaseMutator).AllowPlayerStart(N, Team) )
        return -10000000; */

    P = N;

    if ((P == None) || P.PhysicsVolume.bWaterVolume || Player == None)
        return -10000000;

    /*if(bFirstSpawn && Player != None && Player.bIsPlayer)
		return(FMax(4000000.0 * FRand(), 5));*/

    Score = 1000000.0;

    if(bFirstSpawn && LastPlayerStartSpot != None)
    {
        NextDist = VSize(N.Location - LastPlayerStartSpot.Location);
        Score += (NextDist * (0.25 + 0.75 * FRand()));

	    if(N == LastStartSpot || N == LastPlayerStartSpot)
            Score -= 100000000.0;
        else if(FastTrace(N.Location, LastPlayerStartSpot.Location))
            Score -= 1000000.0;
    }

    //Score += (N.Location.Z * 10) * FRand();

    for(OtherPlayer = Level.ControllerList; OtherPlayer != None; OtherPlayer = OtherPlayer.NextController)
    {
        if(OtherPlayer != None && OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None))
        {
		    NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);

		    if(NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight)
                return 0.0;
            else
		    {
                // same team
			    if(OtherPlayer.GetTeamNum() == Player.GetTeamNum() && OtherPlayer != Player)
                {
                    if(FastTrace(OtherPlayer.Pawn.Location, N.Location))
                        Score += 10000.0;

                    if(NextDist > 1500)
				        Score -= (NextDist * 10);
                    else if (NextDist < 1000)
                        Score += (NextDist * 10);
                    else
                        Score += (NextDist * 20);
                }
                // different team
			    else if(OtherPlayer.GetTeamNum() != Player.GetTeamNum())
                {
                    if(FastTrace(OtherPlayer.Pawn.Location, N.Location))
                        Score -= 20000.0;       // strongly discourage spawning in line-of-sight of an enemy

                    Score += (NextDist * 10);
                }
		    }
        }
    }

	return FMax(Score, 5);
} // RatePlayerStart()

function SetAdren(bool bEnable)
{
    local Controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController)
        C.bAdrenalineEnabled = bEnable;
}

function StartMatch()
{
    Super.StartMatch();

    CurrentRound = 1;
    Misc_BaseGRI(GameReplicationInfo).CurrentRound = 1;
    GameEvent("NewRound", string(CurrentRound), none);

    RoundTime = 60 * MinsPerRound;
    Misc_BaseGRI(GameReplicationInfo).RoundTime = RoundTime;
    RespawnTime = 2;
    LockTime = default.LockTime;
}

function StartNewRound()
{
    RespawnTime = 4;
    LockTime = default.LockTime;

    bRoundOT = false;
    RoundOTTime = 0;
    RoundTime = 60 * MinsPerRound;
    bFirstSpawn = true;

    Deaths[0] = 0;
    Deaths[1] = 0;

    bWeaponsLocked = true;
    Misc_BaseGRI(GameReplicationInfo).bWeaponsLocked = true;

    CurrentRound++;
    Misc_BaseGRI(GameReplicationInfo).CurrentRound = CurrentRound;
    bEndOfRound = false;
    Misc_BaseGRI(GameReplicationInfo).bEndOfRound = false;
    SetAdren(true);	

    DarkHorse = none;

    Misc_BaseGRI(GameReplicationInfo).RoundTime = RoundTime;
    Misc_BaseGRI(GameReplicationInfo).RoundMinute = RoundTime;
    Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;

    GameEvent("NewRound", string(CurrentRound), none);
}

function RespawnPlayers(optional bool bMoveAlive)
{
    local Controller C;

    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(c == None || c.PlayerReplicationInfo == None || c.PlayerReplicationInfo.bOnlySpectator)
            continue;

        if((c.Pawn == None) && PlayerController(c) != None)
        {
            c.PlayerReplicationInfo.bOutOfLives = false;
            c.PlayerReplicationInfo.NumLives = 1;
            // PlayerController(c).ClientReset();
            RestartPlayer(c);
        }

        if(Bot(c) != None && bMoveAlive)
        {
            if(c.Pawn != None)
                c.Pawn.Destroy();

            c.PlayerReplicationInfo.bOutOfLives = false;
            c.PlayerReplicationInfo.NumLives = 1;
            RestartPlayer(c);
        }
    }
}

function PlayerController Login(string Portal, string Options, out string Error)
{
    local PlayerController NewPlayer;
    local string LoginName;

    NewPlayer = Super.Login(Portal, Options, Error);
    LoginName = Left(ParseOption ( Options, "Name"), 20);
    LoginName = class'GUIComponent'.static.StripColorCodes(LoginName);

    if(NewPlayer != None && Misc_PRI(NewPlayer.PlayerReplicationInfo) != None)
    {
        Misc_PRI(NewPlayer.PlayerReplicationInfo).LoginName = LoginName;
        if(LoginName ~= "WebAdmin" || LoginName ~= "DemoRecSpectator" || Left(LoginName, 6) ~= "Player")
            NewPlayer.PlayerReplicationInfo.bWelcomed = true;
    }

    return NewPlayer;
}

function PostLogin(PlayerController NewPlayer)
{
	Super.PostLogin(NewPlayer);

    if(!bRespawning && CurrentRound > 0)
    {
        NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
        NewPlayer.PlayerReplicationInfo.NumLives = 0;
        NewPlayer.GotoState('Spectating');
    }
    else if(CurrentRound > 0)
        RestartPlayer(NewPlayer);

    if(Misc_PRI(NewPlayer.PlayerReplicationInfo) != None)
        Misc_PRI(NewPlayer.PlayerReplicationInfo).JoinRound = CurrentRound;
    if(Misc_Player(NewPlayer) != None)
        Misc_Player(NewPlayer).ClientKillBases();

    if(Misc_PRI(NewPlayer.PlayerReplicationInfo) != None)
    {
        Misc_PRI(NewPlayer.PlayerReplicationInfo).LoginGUID = NewPlayer.GetPlayerIDHash();
        Misc_PRI(NewPlayer.PlayerReplicationInfo).RestoreStats();
    }

    CheckMaxLives(None);
}

function Logout(Controller Exiting)
{
    Super.Logout(Exiting);
    CheckMaxLives(none);

    if(NumPlayers <= 0 && !bWaitingToStartMatch && !bGameEnded && !bGameRestarted)
        RestartGame();
}

function bool AllowBecomeActivePlayer(PlayerController P)
{
    local bool b;

    b = true;
    if(P.PlayerReplicationInfo == None || (NumPlayers >= MaxPlayers) || P.IsInState('GameEnded'))
    {
        P.ReceiveLocalizedMessage(GameMessageClass, 13);
        b = false;
    }

    if(b && Level.NetMode == NM_Standalone && NumBots > InitialBots)
    {
        RemainingBots--;
        bPlayerBecameActive = true;

        if(Misc_PRI(P.PlayerReplicationInfo) != None && P.PlayerReplicationInfo.Score == 0)
            Misc_PRI(P.PlayerReplicationInfo).JoinRound = CurrentRound;
    }

    return b;
}

// add bot to the game
function bool AddBot(optional string botName)
{
	local Bot NewBot;

    NewBot = SpawnBot(botName);
	if ( NewBot == None )
	{
        warn("Failed to spawn bot.");
        return false;
    }

    // broadcast a welcome message.
    BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);

    NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
    NumBots++;

	if(!bRespawning && CurrentRound > 0)
	{
		NewBot.PlayerReplicationInfo.bOutOfLives = true;
		NewBot.PlayerReplicationInfo.numLives = 0;

		if ( Level.NetMode == NM_Standalone )
			RestartPlayer(NewBot);
		else
			NewBot.GotoState('Dead','MPStart');
	}
	else
		RestartPlayer(NewBot);

    CheckMaxLives(none);

	return true;
} // AddBot()

function AddGameSpecificInventory(Pawn P)
{
    Super.AddGameSpecificInventory(P);

    if(p == None || p.Controller == None || p.Controller.PlayerReplicationInfo == None)
        return;

    SetupPlayer(P);
    //GiveWeapons(P);
    //GiveAmmo(P);

    // sort-of hackfix to reduce the chances of the dreaded 'no-weapon bug'...only slightly works
    /* if(Misc_Player(P.Controller) != None)
        Misc_Player(P.Controller).ServerThrowWeapon(); */
}

function SetupPlayer(Pawn P)
{
    p.Health = StartingHealth;
    p.HealthMax = StartingHealth;
    p.SuperHealthMax = StartingHealth * MaxHealth;
    xPawn(p).ShieldStrengthMax = StartingArmor * MaxHealth;

    if(Misc_Player(p.Controller) != None)
        xPawn(p).Spree = Misc_Player(p.Controller).Spree;

    if(!bWeaponsLocked)
        LockWeaponsFor(P.Controller, false);
}

function GiveWeapons(Pawn P)
{
    local int i;

    for(i = 0; i < ArrayCount(WeaponInfo); i++)
    {
        if(WeaponInfo[i].WeaponName == "" || WeaponInfo[i].Ammo[0] <= 0)
            continue;

        P.GiveWeapon(WeaponInfo[i].WeaponName);
    }
}

function GiveAmmo(Pawn P)
{
    local Inventory inv;
    local int i;

    for(inv = P.Inventory; inv != None; inv = inv.Inventory)
    {
        if(Weapon(inv) == None)
            continue;

        for(i = 0; i < ArrayCount(WeaponInfo); i++)
        {
            if(WeaponInfo[i].WeaponName == "" || (WeaponInfo[i].Ammo[0] <= 0 && WeaponInfo[i].Ammo[1] <= 0))
                continue;

            if(string(inv.Class) ~= WeaponInfo[i].WeaponName)
            {
                if(WeaponInfo[i].Ammo[0] > 0)
                    Weapon(inv).AmmoCharge[0] = WeaponInfo[i].Ammo[0];

                if(WeaponInfo[i].Ammo[1] > 0)
                    Weapon(inv).AmmoCharge[1] = WeaponInfo[i].Ammo[1];

                break;
            }
        }
    }
}

function SendCountdownMessage(int time)
{
    local Controller c;

    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(PlayerController(c) != None)
            PlayerController(c).ReceiveLocalizedMessage(class'Message_WeaponsLocked', time);
    }
}

function LockWeapons(bool bLock)
{
    local Controller c;

    if(bWeaponsLocked != bLock)
    {
        bWeaponsLocked = bLock;
        Misc_BaseGRI(GameReplicationInfo).bWeaponsLocked = bLock;
        Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
    }

    for(c = Level.ControllerList; c != None; c = c.NextController)
        LockWeaponsFor(c, bLock);
}

function LockWeaponsFor(Controller c, bool bLock)
{
    if(xPawn(c.Pawn) != None)
    {
        xPawn(c.Pawn).bNoWeaponFiring = bLock;

        if(Misc_Player(c) != None)
            Misc_Player(c).ClientLockWeapons(bLock);
    }
}

state MatchInProgress
{
    function Timer()
    {
        local Controller c;

        if(TimeOutCount > 0)
        {
            TimeOutCount--;

            SendTimeOutCountText();

            if(TimeOutCount <= 0)
                EndTimeOut();

            Super.Timer();

            return;
        }
        else if(NextRoundTime > 0)
        {
            GameReplicationInfo.bStopCountDown = true;
            NextRoundTime--;

            if(TimeOutTeam != default.TimeOutTeam)
            {
                if(TimeOutTeam != 3)
                    TeamTimeOuts[TimeOutTeam]--;
                TimeOutCount = default.TimeOutCount;
            }

            if(NextRoundTime == 0)
                StartNewRound();
            else
            {
                if(NextRoundTime == 5)
                    AnnounceBest();

                Super.Timer();
                return;
            }
        }
        else if(bRoundOT)
        {
            RoundOTTime++;

            if(RoundOTTime % OTInterval == 0)
            {
                for(c = Level.ControllerList; c != None; c = c.NextController)
                {
                    if(c.Pawn == None)
                        continue;

                    if(c.Pawn.Health <= OTDamage && c.Pawn.ShieldStrength <= 0)
                        c.Pawn.TakeDamage(1000, c.Pawn, Vect(0,0,0), Vect(0,0,0), class'DamType_Overtime');
                    else
                    {
                        if(int(c.Pawn.ShieldStrength) > 0)
                            c.Pawn.ShieldStrength = int(c.Pawn.ShieldStrength) - Min(c.Pawn.ShieldStrength, OTDamage);
                        else
                            c.Pawn.Health -= OTDamage;
                        c.Pawn.TakeDamage(0.01, c.Pawn, Vect(0,0,0), Vect(0,0,0), class'DamType_Overtime');
                    }
                }
            }
        }
        else if(LockTime > 0)
        {
            LockTime--;
            SendCountdownMessage(LockTime);

            if(LockTime == 0)
            {
                LockWeapons(false);
                GameReplicationInfo.bStopCountdown = false;
            }
        }
        else if(RoundTime > 0)
        {
            RoundTime--;
            Misc_BaseGRI(GameReplicationInfo).RoundTime = RoundTime;
            if(RoundTime % 60 == 0)
                Misc_BaseGRI(GameReplicationInfo).RoundMinute = RoundTime;

            if(RoundTime == 0)
                bRoundOT = true;
        }

        if(RespawnTime > 0)
            RespawnTimer();

        CheckForCampers();

        Super.Timer();
    }
}

function RespawnTimer()
{
    local Actor Reset;
    local Controller c;

    RespawnTime--;
    bRespawning = RespawnTime > 0;

    if(RespawnTime == 3)
    {
        for(c = Level.ControllerList; c != None; c = c.NextController)
        {
            if(Misc_Player(c) != None)
            {
                Misc_Player(c).Spree = 0;
                //Misc_Player(c).ClientEnhancedTrackAllPlayers(false, true, false);
                Misc_Player(c).ClientResetClock(MinsPerRound * 60);
            }

            if(c.PlayerReplicationInfo == None || c.PlayerReplicationInfo.bOnlySpectator)
                continue;

            if(xPawn(c.Pawn) != None)
            {
                c.Pawn.RemovePowerups();

                if(Misc_Player(c) != None)
                    Misc_Player(c).Spree = xPawn(c.Pawn).Spree;

                c.Pawn.Destroy();
            }

            c.PlayerReplicationInfo.bOutOfLives = false;
            c.PlayerReplicationInfo.NumLives = 1;

            if(PlayerController(c) != None)
                PlayerController(c).ClientReset();
            c.Reset();
            if(PlayerController(c) != None)
                PlayerController(c).GotoState('Spectating');
        }

        ForEach AllActors(class'Actor', Reset)
        {
            if(DestroyActor(Reset))
                Reset.Destroy();
            else if(ResetActor(Reset))
                Reset.Reset();
        }
    }

    if(RespawnTime <= 3)
        RespawnPlayers(false);
}

function bool DestroyActor(Actor A)
{
    if(Projectile(A) != None)
        return true;
    else if(xPawn(A) != None && xPawn(A).Health > 0 && (xPawn(A).Controller == None || xPawn(A).PlayerReplicationInfo == None))
        return true;

    return false;
}

function bool ResetActor(Actor A)
{
    if(Mover(A) != None || DECO_ExplodingBarrel(A) != None)
        return true;

    return false;
}

function CheckForCampers()
{
    local Controller c;
    local Misc_Pawn p;
    local Misc_PRI pri;
    local Box HistoryBox;
    local float MaxDim;
    local int i;
    
    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(Misc_PRI(c.PlayerReplicationInfo) == None || Misc_Pawn(c.Pawn) == None ||
            c.PlayerReplicationInfo.bOnlySpectator || c.PlayerReplicationInfo.bOutOfLives)
            continue;

        P = Misc_Pawn(c.Pawn);
        pri = Misc_PRI(c.PlayerReplicationInfo);

        p.LocationHistory[p.NextLocHistSlot] = p.Location;
        p.NextLocHistSlot++;

        if(p.NextLocHistSlot == 10)
        {
            p.NextLocHistSlot = 0;
            p.bWarmedUp = true;
        }

        if(p.bWarmedUp)
        {
            HistoryBox.Min.X = p.LocationHistory[0].X;
            HistoryBox.Min.Y = p.LocationHistory[0].Y;
            HistoryBox.Min.Z = p.LocationHistory[0].Z;

            HistoryBox.Max.X = p.LocationHistory[0].X;
            HistoryBox.Max.Y = p.LocationHistory[0].Y;
            HistoryBox.Max.Z = p.LocationHistory[0].Z;

            for(i = 1; i < 10; i++)
            {
                HistoryBox.Min.X = FMin(HistoryBox.Min.X, p.LocationHistory[i].X);
				HistoryBox.Min.Y = FMin(HistoryBox.Min.Y, p.LocationHistory[i].Y);
				HistoryBox.Min.Z = FMin(HistoryBox.Min.Z, p.LocationHistory[i].Z);

				HistoryBox.Max.X = FMax(HistoryBox.Max.X, p.LocationHistory[i].X);
				HistoryBox.Max.Y = FMax(HistoryBox.Max.Y, p.LocationHistory[i].Y);
				HistoryBox.Max.Z = FMax(HistoryBox.Max.Z, p.LocationHistory[i].Z);
            }

            MaxDim = FMax(FMax(HistoryBox.Max.X - HistoryBox.Min.X, HistoryBox.Max.Y - HistoryBox.Min.Y), HistoryBox.Max.Z - HistoryBox.Min.Z);

            if(MaxDim < CampThreshold && p.ReWarnTime == 0)
            {
                PunishCamper(c, p, pri);
                p.ReWarnTime = CampInterval;
            }
            else if(MaxDim > CampThreshold)
            {
                pri.bWarned = false;
                pri.ConsecutiveCampCount = 0;
            }
            else if(p.ReWarnTime > 0)
                p.ReWarnTime--;
        }
    }
}

// dish out the appropriate punishment to a camper
function PunishCamper(Controller C, Misc_Pawn P, Misc_PRI PRI)
{
    SendCamperWarning(C);

    if(c.Pawn.Health <= (10 * (pri.CampCount + 1)) && c.Pawn.ShieldStrength <= 0)
        c.Pawn.TakeDamage(1000, c.Pawn, Vect(0,0,0), Vect(0,0,0), class'DamType_Camping');
    else
    {
        if(int(c.Pawn.ShieldStrength) > 0)
            c.Pawn.ShieldStrength = Max(0, P.ShieldStrength - (10 * (pri.CampCount + 1)));
        else
            c.Pawn.Health -= 10 * (pri.CampCount + 1);
        c.Pawn.TakeDamage(0.01, c.Pawn, Vect(0,0,0), Vect(0,0,0), class'DamType_Camping');
    }

    if(!pri.bWarned)
    {
        pri.bWarned = true;
        return;
    }

    if(Level.NetMode == NM_DedicatedServer && pri.Ping * 4 < 999)
    {
        pri.CampCount++;
        pri.ConsecutiveCampCount++;

        if(bKickExcessiveCampers && pri.ConsecutiveCampCount >= 4)
        {
            //log("Kicking Camper (Possibly Idle): "$c.PlayerReplicationInfo.PlayerName);
	        AccessControl.DefaultKickReason = AccessControl.IdleKickReason;
	        AccessControl.KickPlayer(PlayerController(c));
	        AccessControl.DefaultKickReason = AccessControl.Default.DefaultKickReason;
        }
    }
}

// tell players about the camper
function SendCamperWarning(Controller Camper)
{
	local Controller c;

	for(c = Level.ControllerList; c != None; c = c.NextController)
	{
		if(Misc_Player(c) == None)
			continue;

        if(bUseCamperIcon)
            Misc_Player(c).ReceiveLocalizedMessage(class'Message_CamperX', int(c != Camper), Camper.PlayerReplicationInfo);
        else
            Misc_Player(c).ReceiveLocalizedMessage(class'Message_Camper', int(c != Camper), Camper.PlayerReplicationInfo);
	}
} // SendCamperWarning()

function SendTimeoutCountText()
{
	local Controller C;

	for(C = Level.ControllerList; C != None; C = C.nextController)
		if(PlayerController(C) != None)
			PlayerController(C).ReceiveLocalizedMessage(class'Message_Timeout', TimeOutCount);
} // SendTimeoutCountText()

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    Super.Killed(Killer, Killed, KilledPawn, DamageType);

    if(Killed != None && Killed.PlayerReplicationInfo != None)
    {
        if(bRespawning)
        {
            Killed.PlayerReplicationInfo.bOutOfLives = false;
            Killed.PlayerReplicationInfo.NumLives = 1;

            return;
        }
        else
        {
            Killed.PlayerReplicationInfo.bOutOfLives = true;
            Killed.PlayerReplicationInfo.NumLives = 0;
        }

        if(Killed.GetTeamNum() != 255)
        {
            Deaths[Killed.GetTeamNum()]++;
            CheckForAlone(Killed, Killed.GetTeamNum());
        }
    }
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
    if ( (Killer == Other) || (Killer == None) )
        BroadcastLocalized(self, class'Message_PlayerKilled', 1, None, Other.PlayerReplicationInfo, damageType);
    else
        BroadcastLocalized(self, class'Message_PlayerKilled', 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
    /* if ( (Killer == Other) || (Killer == None) )
        BroadcastLocalized(self, DeathMessageClass, 1, None, Other.PlayerReplicationInfo, damageType);
    else
        BroadcastLocalized(self, DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType); */
}

// check if a team only has one player left
function CheckForAlone(Controller Died, int TeamIndex)
{
    local Controller c;
    local Controller last;
    local int alive[2];

    if(DarkHorse == Died)
    {
        DarkHorse = None;
        return;
    }

    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(c == Died || c.Pawn == None || c.GetTeamNum() == 255)
            continue;

        alive[c.GetTeamNum()]++;
        if(alive[TeamIndex] > 1)
            return;

        if(c.GetTeamNum() == TeamIndex)
        {
            if(alive[TeamIndex] != 1)
                last = None;
            else
                last = c;
        }
    }

    if(alive[TeamIndex] != 1 || last == None)
        return;

    if(Misc_Player(last) != None)
        Misc_Player(last).ClientPlayAlone();

    if(DarkHorse == None && (alive[int(!bool(TeamIndex))] >= 3 && NumPlayers + NumBots >= 4))
        DarkHorse = last;
}

/*
// used to show 'player is out' message
function NotifyKilled(Controller Killer, Controller Other, Pawn OtherPawn)
{
	Super.NotifyKilled(Killer, Other, OtherPawn);
	SendPlayerIsOutText(Other);
} // NotifyKilled()

// shows 'player is out' message
function SendPlayerIsOutText(Controller Out)
{
	local Controller c;

	if(Out == None)
		return;

	for(c = Level.ControllerList; c != None; c = c.nextController)
        if(PlayerController(c) != None)
            PlayerController(c).ReceiveLocalizedMessage(class'Message_PlayerIsOut', int(PlayerController(c) != PlayerController(Out)), Out.PlayerReplicationInfo);
} // SendPlayerIsOutText()
*/

function bool CanSpectate(PlayerController Viewer, bool bOnlySpectator, actor ViewTarget)
{
    if(xPawn(ViewTarget) == None && (Controller(ViewTarget) == None || xPawn(Controller(ViewTarget).Pawn) == None))
        return false;

    if(bOnlySpectator)
    {
        if(Controller(ViewTarget) != None)
            return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer);
        else
            return (xPawn(ViewTarget).IsPlayerPawn());
    }

    if(bRespawning || (NextRoundTime <= 1 && bEndOfRound))
        return false;

    if(Misc_BaseGRI(GameReplicationInfo) != None && Misc_BaseGRI(GameReplicationInfo).bSpectateAll)
    {
        if(Controller(ViewTarget) != None)
            return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer);
        else
            return (xPawn(ViewTarget).IsPlayerPawn() && xPawn(ViewTarget).PlayerReplicationInfo != None);
    }

    if(Controller(ViewTarget) != None)
        return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer &&
                (bEndOfRound || (Controller(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
    else
        return (xPawn(ViewTarget).IsPlayerPawn() && xPawn(ViewTarget).PlayerReplicationInfo != None &&
                (bEndOfRound || (xPawn(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if(bWaitingToStartMatch || bEndOfRound || bWeaponsLocked)
        return false;

	if((Scorer != None) && !Scorer.bOutOfLives)
		Living = Scorer;

    bNoneLeft = true;
    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if((C.PlayerReplicationInfo != None) && C.bIsPlayer
            && (!C.PlayerReplicationInfo.bOutOfLives)
            && !C.PlayerReplicationInfo.bOnlySpectator)
        {
			if(Living == None)
				Living = C.PlayerReplicationInfo;
			else if((C.PlayerReplicationInfo != Living) && (C.PlayerReplicationInfo.Team != Living.Team))
			{
    	        bNoneLeft = false;
	            break;
			}
        }
    }

    if(bNoneLeft)
    {
		if(Living != None)
			EndRound(Living);
		else
			EndRound(Scorer);
		return true;
	}

    return false;
}

function EndRound(PlayerReplicationInfo Scorer)
{
    local Controller c;

    bEndOfRound = true;
    Misc_BaseGRI(GameReplicationInfo).bEndOfRound = true;
    Misc_BaseGRI(GameReplicationInfo).bWeaponsLocked = true;
    Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
	SetAdren(false);

    if(Scorer == None)
    {
        NextRoundTime = NextRoundDelay;
        return;
    }

    IncrementGoalsScored(Scorer);
    ScoreEvent(Scorer, 0, "ObjectiveScore");
    TeamScoreEvent(Scorer.Team.TeamIndex, 1, "tdm_frag");
    Teams[Scorer.Team.TeamIndex].Score += 1;
    AnnounceScore(Scorer.Team.TeamIndex);

    // check for darkhorse
    if(DarkHorse != None && DarkHorse.PlayerReplicationInfo != None && DarkHorse.PlayerReplicationInfo == Scorer)
    {
        for(c = Level.ControllerList; c != None; c = c.NextController)
            if(PlayerController(c) != None)
                PlayerController(c).ReceiveLocalizedMessage(class'Message_DarkHorse', int(DarkHorse == c), DarkHorse.PlayerReplicationInfo);

        DarkHorse.AwardAdrenaline(10);
        Misc_PRI(DarkHorse.PlayerReplicationInfo).DarkhorseCount++;
        SpecialEvent(DarkHorse.PlayerReplicationInfo, "DarkHorse");
    }
    // check for flawless victory
    else if(Scorer.Team.Score < GoalScore && (NumPlayers + NumBots) >= 4)
    {
        if(Deaths[Scorer.Team.TeamIndex] == 0)
        {
            for(c = Level.ControllerList; c != None; c = c.NextController)
            {
                if(c.PlayerReplicationInfo != None && (c.PlayerReplicationInfo.bOnlySpectator || (c.GetTeamNum() != 255 && c.GetTeamNum() == Scorer.Team.TeamIndex)))
                {
                    if(UnrealPlayer(C) != None)
                        UnrealPlayer(C).ClientDelayedAnnouncementNamed('Flawless_victory', 18);

                    if(!c.PlayerReplicationInfo.bOnlySpectator)
                    {
                        Misc_PRI(C.PlayerReplicationInfo).FlawlessCount++;
                        SpecialEvent(C.PlayerReplicationInfo, "Flawless");
                        C.AwardAdrenaline(5);
                    }
                }
                else
                {
                    if(UnrealPlayer(C) != None)
                        UnrealPlayer(C).ClientDelayedAnnouncementNamed('Humiliating_defeat', 18);
                }
            }
        }
    }

    if(Scorer.Team.Score == GoalScore)
    {
        AnnounceBest();
        EndGame(Scorer, "teamscorelimit");
    }
    else
        NextRoundTime = NextRoundDelay;
}

function AnnounceBest()
{
    local Controller C;

    local string acc;
    local string dam;
    local string hs;

    local Misc_PRI PRI;
    local Misc_PRI accuracy;
    local Misc_PRI damage;
    local Misc_PRI headshots;

    local string Red;
    local string Blue;
    local string Text;
    local Color  color;

    Red = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.RedTeamColor);
    Blue = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.BlueTeamColor);

    color = class'Canvas'.static.MakeColor(210, 210, 210);
    Text = class'DMStatsScreen'.static.MakeColorCode(color);

    for(C = Level.ControllerList; C != None; C = C.NextController)
	{
		PRI = Misc_PRI(C.PlayerReplicationInfo);

		if(PRI == None || PRI.Team == None || PRI.bOnlySpectator)
			continue;

		PRI.ProcessHitStats();

		if(accuracy == None || (accuracy.AveragePercent < PRI.AveragePercent))
			accuracy = PRI;

		if(damage == None || (damage.EnemyDamage < PRI.EnemyDamage))
			damage = PRI;

		if(headshots == None || (headshots.Headshots < PRI.Headshots))
			headshots = PRI;
	}

    if(accuracy != None && accuracy.AveragePercent > 0.0)
    {
        if(accuracy.Team.TeamIndex == 0)
            acc = Text$"Most Accurate:"@Red$accuracy.PlayerName$Text$";"@accuracy.AveragePercent$"%";
        else
            acc = Text$"Most Accurate:"@Blue$accuracy.PlayerName$Text$";"@accuracy.AveragePercent$"%";
    }

    if(damage != None && damage.EnemyDamage > 0)
    {
        if(damage.Team.TeamIndex == 0)
            dam = Text$"Most Damage:"@Red$damage.PlayerName$Text$";"@damage.EnemyDamage;
        else
            dam = Text$"Most Damage:"@Blue$damage.PlayerName$Text$";"@damage.EnemyDamage;
    }

    if(headshots != None && headshots.Headshots > 0)
    {
        if(headshots.Team.TeamIndex == 0)
            hs =  Text$"Most Headshots:"@Red$headshots.PlayerName$Text$";"@headshots.Headshots;
        else
            hs =  Text$"Most Headshots:"@Blue$headshots.PlayerName$Text$";"@headshots.Headshots;
    }

	for(C = Level.ControllerList; C != None; C = C.NextController)
		if(Misc_Player(c) != None)
			Misc_Player(c).ClientListBest(acc, dam, hs);
}

function SetMapString(Misc_Player Sender, string s)
{
    if(Level.NetMode == NM_Standalone || Sender.PlayerReplicationInfo.bAdmin)
        NextMapString = s;
    Log("SetMapString: " $ s, '3SPN');
}

function EndGame(PlayerReplicationInfo PRI, string Reason)
{
    Super.EndGame(PRI, Reason);
    ResetDefaults();
}

function RestartGame()
{
    ResetDefaults();
    Super.RestartGame();
}

function ProcessServerTravel(string URL, bool bItems)
{
    ResetDefaults();
    Super.ProcessServerTravel(URL, bItems);
}

function ResetDefaults()
{
    local int i;
    local class<Weapon> WeaponClass;

    if(bDefaultsReset)
        return;
    bDefaultsReset = true;

    // set all defaults back to their original values
    Class'xPawn'.Default.ControllerClass = class'XGame.xBot';
    
    MutTAM.ResetWeaponsToDefaults(bModifyShieldGun);

    for(i = 0; i < ArrayCount(WeaponDefaults); i++)
    {
        if(WeaponDefaults[i].WeaponName ~= "")
            continue;

        WeaponClass = class<Weapon>(DynamicLoadObject(WeaponDefaults[i].WeaponName, class'Class'));

        if(WeaponClass == None)
            continue;

        // reset defaults
        if(class<Translauncher>(WeaponClass) != None && WeaponDefaults[i].Ammo[0] > 0)
        {
            Class'XWeapons.Translauncher'.default.AmmoChargeRate = WeaponDefaults[i].MaxAmmo[0];
		    Class'XWeapons.Translauncher'.default.AmmoChargeMax = WeaponDefaults[i].Ammo[0];
		    Class'XWeapons.Translauncher'.default.AmmoChargeF = WeaponDefaults[i].MaxAmmo[1];

            continue;
        }

        if(WeaponClass.default.FireModeClass[0].default.AmmoClass != None)
        {
            WeaponClass.default.FireModeClass[0].default.AmmoClass.default.InitialAmount = WeaponDefaults[i].Ammo[0];
            WeaponClass.default.FireModeClass[0].default.AmmoClass.default.MaxAmmo = WeaponDefaults[i].MaxAmmo[0];
        }

        if(WeaponClass.default.FireModeClass[1].default.AmmoClass != None && (WeaponClass.default.FireModeClass[0].default.AmmoClass != WeaponClass.default.FireModeClass[1].default.AmmoClass))
        {
            WeaponClass.default.FireModeClass[1].default.AmmoClass.default.InitialAmount = WeaponDefaults[i].Ammo[1];
            WeaponClass.default.FireModeClass[1].default.AmmoClass.default.MaxAmmo = WeaponDefaults[i].MaxAmmo[1];
        }
    }

    if(bModifyShieldGun)
	{
		Class'XWeapons.ShieldFire'.default.SelfForceScale = 1.000000;
		Class'XWeapons.ShieldFire'.default.SelfDamageScale = 0.300000;
		Class'XWeapons.ShieldFire'.default.MinSelfDamage = 8.000000;
	}

    class'FlakChunk'.default.MyDamageType = class'DamTypeFlakChunk';
    class'FlakShell'.default.MyDamageType = class'DamTypeFlakShell';
    class'BioGlob'.default.MyDamageType = class'DamTypeBioGlob';

    // apply changes made by an admin
    if(NextMapString != "")
    {
        ParseOptions(NextMapString);
        saveconfig();
        NextMapString = "";
    }
}

function bool AllowTransloc()
{
    return false;
}

static function bool NeverAllowTransloc()
{
    return true;
}

defaultproperties
{
     StartingHealth=100
     MaxHealth=1.000000
     AdrenalinePerDamage=1.000000
     bDisableSpeed=True
     bDisableInvis=True
     bDisableBerserk=True
     MaxAdrenaline=200
     bForceRUP=True
     ForceSeconds=60
     MinsPerRound=2
     OTDamage=5
     OTInterval=3
     CampThreshold=400.000000
     CampInterval=5
     bKickExcessiveCampers=True
     bUseCamperIcon=True
     TimeOutTeam=255
     TimeOutCount=30
     bFirstSpawn=True
     LockTime=4
     NextRoundDelay=7
     bSelfDamage=True
     WeaponInfo(0)=(WeaponName="xWeapons.AssaultRifle",Ammo[0]=999,Ammo[1]=5,MaxAmmo[0]=1.500000)
     WeaponInfo(1)=(WeaponName="xWeapons.BioRifle",Ammo[0]=20,MaxAmmo[0]=1.500000)
     WeaponInfo(2)=(WeaponName="xWeapons.ShockRifle",Ammo[0]=20,MaxAmmo[0]=1.500000)
     WeaponInfo(3)=(WeaponName="xWeapons.LinkGun",Ammo[0]=100,MaxAmmo[0]=1.500000)
     WeaponInfo(4)=(WeaponName="xWeapons.MiniGun",Ammo[0]=75,MaxAmmo[0]=1.500000)
     WeaponInfo(5)=(WeaponName="xWeapons.FlakCannon",Ammo[0]=12,MaxAmmo[0]=1.500000)
     WeaponInfo(6)=(WeaponName="xWeapons.RocketLauncher",Ammo[0]=12,MaxAmmo[0]=1.500000)
     WeaponInfo(7)=(WeaponName="xWeapons.SniperRifle",Ammo[0]=10,MaxAmmo[0]=1.500000)
     AssaultAmmo=999
     AssaultGrenades=5
     BioAmmo=30
     ShockAmmo=30
     LinkAmmo=150
     MiniAmmo=150
     FlakAmmo=20
     RocketAmmo=20
     LightningAmmo=20
     bWeaponsLocked=True
     GameName2="BASE"
     bDamageIndicator=True
     bScoreTeamKills=False
     FriendlyFireScale=0.500000
     bPlayersMustBeReady=True
     DefaultEnemyRosterClass="3SPNv3177AT.TAM_TeamInfo"
     ADR_MinorError=-5.000000
     LocalStatsScreenClass=Class'3SPNv3177AT.Misc_StatBoard'
     DefaultPlayerClassName="3SPNv3177AT.Misc_Pawn"
     ScoreBoardType="3SPNv3177AT.TAM_Scoreboard"
     HUDType="3SPNv3177AT.TAM_HUD"
     GoalScore=10
     TimeLimit=0
     DeathMessageClass=Class'3SPNv3177AT.Misc_DeathMessage'
     MutatorClass="3SPNv3177AT.TAM_Mutator"
     PlayerControllerClassName="3SPNv3177AT.Misc_Player"
     GameReplicationInfoClass=Class'3SPNv3177AT.Misc_BaseGRI'
     GameName="BASE"
     Description="One life per round. Don't waste it."
     ScreenShotName="UT2004Thumbnails.TDMShots"
     DecoTextName="XGame.TeamGame"
     Acronym="BASE"
}
