class ArenaMaster extends xDeathmatch
    Config;

/* general and misc */
var config int      StartingHealth;
var config int      StartingArmor;
var config float    MaxHealth;

var float           AdrenalinePerDamage;    // adrenaline per 10 damage

var config bool     bDisableSpeed;
var config bool     bDisableBooster;
var config bool     bDisableInvis;
var config bool     bDisableBerserk;
var config int      MaxAdrenaline;
var array<string>   EnabledCombos;
var config bool     bSpectateAll;

var config bool     bChallengeMode;
var config bool     bForceRUP;

var config bool     bRandomPickups;
var Misc_PickupBase Bases[3];               // random pickup bases

var string          NextMapString;          // used to save mid-game admin changes in the menu

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

/* round related */
var bool            bEndOfRound;            // true if a round has just ended
var bool            bRespawning;            // true if we're respawning players
var int             RespawnTime;            // time left to respawn
var int             LockTime;               // time left until weapons get unlocked
var int             NextRoundTime;          // time left until the next round starts
var int             CurrentRound;           // the current round number (0 = game hasn't started)

var int             RoundsToWin;            // rounds needed to win
var bool            bRoundBased;
/* round related */

var config bool     bSelfDamage;

/* weapon related */
struct WeaponData
{
    var string WeaponName;
    var int Ammo[2];                        // 0 = primary ammo, 1 = alt ammo
    var float MaxAmmo[2];                   // 1 is only used for WeaponDefaults
};

var        WeaponData WeaponInfo[10];
var        WeaponData WeaponDefaults[10];
var config bool	      bModifyShieldGun;     // use the modified shield gun (higher shield jumps)

var config int AssaultAmmo;
var config int AssaultGrenades;
var config int BioAmmo;
var config int ShockAmmo;
var config int LinkAmmo;
var config int MiniAmmo;
var config int FlakAmmo;
var config int RocketAmmo;
var config int LightningAmmo;

var bool              bWeaponsLocked;
/* weapon related */

/* newnet */
var config bool EnableNewNet;
var TAM_Mutator MutTAM;
/* newnet */
var config bool bDamageIndicator;

var string GameName2;

static function string GetLoadingHint(PlayerController PlayerController, string MapName, Color ColorHint)
{
    if (class'Team_GameBase'.static.ReplaceLoadingScreen(PlayerController, MapName) )
        return " ";
    else
        return Super.GetLoadingHint(PlayerController, MapName, ColorHint);
}

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    if(TAM_GRI(GameReplicationInfo) == None)
        return;

    Misc_BaseGRI(GameReplicationInfo).bRoundBased = bRoundBased;
    if(!bRoundBased)
    {
        Misc_BaseGRI(GameReplicationInfo).GameName = "DeathMatch";
        MinsPerRound = 0;
    }
    else
    {
        Misc_BaseGRI(GameReplicationInfo).GameName = GameName2;
        Misc_BaseGRI(GameReplicationInfo).RoundTime = MinsPerRound * 60;
    }

    TAM_GRI(GameReplicationInfo).StartingHealth = StartingHealth;
    TAM_GRI(GameReplicationInfo).StartingArmor = StartingArmor;
    TAM_GRI(GameReplicationInfo).bChallengeMode = bChallengeMode;
    TAM_GRI(GameReplicationInfo).MaxHealth = MaxHealth;

    TAM_GRI(GameReplicationInfo).MinsPerRound = MinsPerRound;
    TAM_GRI(GameReplicationInfo).OTDamage = OTDamage;
    TAM_GRI(GameReplicationInfo).OTInterval = OTInterval;

    TAM_GRI(GameReplicationInfo).CampThreshold = CampThreshold;
    TAM_GRI(GameReplicationInfo).bKickExcessiveCampers = bKickExcessiveCampers;

    TAM_GRI(GameReplicationInfo).bDisableTeamCombos = true;
    TAM_GRI(GameReplicationInfo).bDisableSpeed = bDisableSpeed;
    TAM_GRI(GameReplicationInfo).bDisableInvis = bDisableInvis;
    TAM_GRI(GameReplicationInfo).bDisableBooster = bDisableBooster;
    TAM_GRI(GameReplicationInfo).bDisableBerserk = bDisableBerserk;
    TAM_GRI(GameReplicationInfo).bDisableNecro = true;
    TAM_GRI(GameReplicationInfo).MaxAdrenaline = MaxAdrenaline;
    TAM_GRI(GameReplicationInfo).bSpectateAll = bSpectateAll;

    TAM_GRI(GameReplicationInfo).bForceRUP = bForceRUP;
    TAM_GRI(GameReplicationInfo).bRandomPickups = bRandomPickups;

    TAM_GRI(GameReplicationInfo).GoalScore = RoundsToWin;
    
	Misc_BaseGRI(GameReplicationInfo).EnableNewNet = EnableNewNet;
	Misc_BaseGRI(GameReplicationInfo).bDamageIndicator = bDamageIndicator;

    bWeaponsLocked = true;
    Misc_BaseGRI(GameReplicationInfo).bWeaponsLocked = true;
    Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;
}

function GetServerDetails(out ServerResponseLine ServerState)
{
    Super.GetServerDetails(ServerState);

    AddServerDetail(ServerState, "3SPN Version", class'TAM_GRI'.default.Version);
    AddServerDetail(ServerState, "Challenge Mode", bChallengeMode);
    AddServerDetail(ServerState, "Random Pickups", bRandomPickups);
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
}

static function FillPlayInfo(PlayInfo PI)
{
    Super.FillPlayInfo(PI);

    PI.AddSetting("3SPN", "StartingHealth", "Starting Health", 0, 100, "Text", "3;0:999");
    PI.AddSetting("3SPN", "StartingArmor", "Starting Armor", 0, 101, "Text", "3;0:999");
    PI.AddSetting("3SPN", "MaxHealth", "Max Health", 0, 102, "Text", "8;0.0:2.0");
    PI.AddSetting("3SPN", "bChallengeMode", "Challenge Mode", 0, 103, "Check");

    PI.AddSetting("3SPN", "MinsPerRound", "Minutes per Round", 0, 120, "Text", "3;0:999");
    PI.AddSetting("3SPN", "OTDamage", "Overtime Damage", 0, 121, "Text", "3;0:999");
    PI.AddSetting("3SPN", "OTInterval", "Overtime Damage Interval", 0, 122, "Text", "3;0:999");

    PI.AddSetting("3SPN", "CampThreshold", "Camp Area", 0, 150, "Text", "3;0:999",, True);
    PI.AddSetting("3SPN", "bKickExcessiveCampers", "Kick Excessive Campers", 0, 151, "Check",,, True);
    PI.AddSetting("3SPN", "bUseCamperIcon", "Camper Icons", 0, 152, "Check",,, True);
    PI.AddSetting("3SPN", "bSelfDamage", "Self Damage", 0, 153, "Check",,, True);

    PI.AddSetting("3SPN", "bForceRUP", "Force Ready", 0, 175, "Check",,, True);
    PI.AddSetting("3SPN", "bRandomPickups", "Random Pickups", 0, 176, "Check");

    PI.AddSetting("3SPN", "bDisableSpeed", "Disable Speed", 0, 200, "Check");
    PI.AddSetting("3SPN", "bDisableInvis", "Disable Invis", 0, 201, "Check");
    PI.AddSetting("3SPN", "bDisableBerserk", "Disable Berserk", 0, 202, "Check");
    PI.AddSetting("3SPN", "bDisableBooster", "Disable Booster", 0, 203, "Check");
    PI.AddSetting("3SPN", "MaxAdrenaline", "Maximum Adrenaline", 0, 210, "Text", "3;100:999",, True);

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
        case "bChallengeMode":      return "Round winners take a health/armor penalty.";

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

        case "bForceRUP":           return "Force players to ready up after 45 seconds.";
        case "bRandomPickups":      return "Spawns three pickups which give random effect when picked up: Health +15, Shield +15 or Adren +10";

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
        
		case "EnableNewNet":		return "Make enhanced netcode available for players.";
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

    InOpt = ParseOption(Options, "ChallengeMode");
    if(InOpt != "")
        bChallengeMode = bool(InOpt);

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

    InOpt = ParseOption(Options, "RandomPickups");
    if(InOpt != "")
        bRandomPickups = bool(InOpt);

    InOpt = ParseOption(Options, "MaxAdrenaline");
    if(InOpt != "")
        MaxAdrenaline = int(InOpt);

    InOpt = ParseOption(Options, "DeathMatch");
    if(InOpt != "" && int(InOpt) > 0)
        bRoundBased = false;
    
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

function SpawnRandomPickupBases()
{
    local float Score[3];
    local float eval;
    local NavigationPoint Best[3];
    local NavigationPoint N;

    for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
    {
        if(InventorySpot(N) == None || InventorySpot(N).myPickupBase == None)
            continue;

        eval = FRand() * 5000.0;

        if(Best[0] != None)
            eval += VSize(Best[0].Location - N.Location) * (FRand() * 4.0 - 2.0);
        if(Best[1] != None)
            eval += VSize(Best[1].Location - N.Location) * (FRand() * 3.5 - 1.75);
        if(Best[2] != None)
            eval += VSize(Best[2].Location - N.Location) * (FRand() * 3.0 - 1.5);

        if(Best[0] == N)
            eval = 0;
        if(Best[1] == N)
            eval = 0;
        if(Best[2] == N)
            eval = 0;

        if(eval > Score[0])
        {
            Score[2] = Score[1];
            Score[1] = Score[0];
            Score[0] = eval;

            Best[2] = Best[1];
            Best[1] = Best[0];
            Best[0] = N;
        }
        else if(eval > Score[1])
        {
            Score[2] = Score[1];
            Score[1] = eval;

            Best[2] = Best[1];
            Best[1] = N;
        }
        else if(eval > Score[2])
        {
            Score[2] = eval;
            Best[2] = N;
        }
    }

    if(Best[0] != None)
    {
        Bases[0] = Spawn(class'Misc_PickupBase',,, Best[0].Location, Best[0].Rotation);
        Bases[0].MyMarker = InventorySpot(Best[0]);
    }
    if(Best[1] != None)
    {
        Bases[1] = Spawn(class'Misc_PickupBase',,, Best[1].Location, Best[1].Rotation);
        Bases[1].MyMarker = InventorySpot(Best[1]);
    }
    if(Best[2] != None)
    {
        Bases[2] = Spawn(class'Misc_PickupBase',,, Best[2].Location, Best[2].Rotation);
        Bases[2].MyMarker = InventorySpot(Best[2]);
    }
}

event InitGame(string Options, out string Error)
{
    local int i;
    local class<Weapon> WeaponClass;
    
    bAllowBehindView = true;

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

    if(bRandomPickups)
        SpawnRandomPickupBases();
    
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

    RoundsToWin = GoalScore;
    GoalScore = 0;
}

function AddDefaultInventory(Pawn P)
{
	Super.AddDefaultInventory(P);
    MutTAM.GiveAmmo(P);
}

function ScoreKill(Controller Killer, Controller Other)
{
    Super.ScoreKill(Killer, Other);

    if(Other != None && Other.PlayerReplicationInfo != None && ((Other.PlayerReplicationInfo.Score % 10000 ) > 9900) )
        Other.PlayerReplicationInfo.Score = int((Other.PlayerReplicationInfo.Score + 100) / 10000) * 10000;
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation,
                          out vector Momentum, class<DamageType> DamageType)
{
    local Misc_PRI PRI;
    local int OldDamage;
    local int NewDamage;
    local int RealDamage;
    local float Score;

    local vector EyeHeight;
    
    if(bEndOfRound || LockTime > 0)
        return 0;
    
    if(injured != None && injured.SpawnTime > Level.TimeSeconds)
        return 0;
    
    if(!bSelfDamage && injured == instigatedBy)
        return 0;    

    if(DamageType == Class'DamTypeSuperShockBeam')
        return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    if(Misc_Pawn(instigatedBy) != None)
    {
        PRI = Misc_PRI(instigatedBy.PlayerReplicationInfo);
        if(PRI == None)
            return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

        /* self-injury */
        if(injured == instigatedBy)
        {
            OldDamage = Misc_PRI(instigatedBy.PlayerReplicationInfo).AllyDamage;

            RealDamage = OldDamage + Damage;

            if(class<DamType_Camping>(DamageType) != None || class<DamType_Overtime>(DamageType) != None)
                return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

            if(class<DamTypeShieldImpact>(DamageType) != None)
                NewDamage = OldDamage;
            else
                NewDamage = RealDamage;

            PRI.AllyDamage = NewDamage;
            Score = NewDamage - OldDamage;
            if(Score > 0.0)
            {
                // log event
                if(Misc_Player(instigatedBy.Controller) != None)
                {
                    Misc_Player(instigatedBy.Controller).NewFriendlyDamage += Score * 0.01;
                    if(Misc_Player(instigatedBy.Controller).NewFriendlyDamage >= 1.0)
                    {
                        ScoreEvent(PRI, -int(Misc_Player(instigatedBy.Controller).NewFriendlyDamage), "FriendlyDamage");
                        Misc_Player(instigatedBy.Controller).NewFriendlyDamage -= int(Misc_Player(instigatedBy.Controller).NewFriendlyDamage);
                    }
                }
                PRI.Score = FMax(int(PRI.Score / 10000.0) * 10000, PRI.Score - Score * 0.01);
                instigatedBy.Controller.AwardAdrenaline((-Score * 0.10) * AdrenalinePerDamage);
            }

            return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
        }
        else if(instigatedBy != injured)
        {
            PRI = Misc_PRI(instigatedBy.PlayerReplicationInfo);
            if(PRI == None)
                return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

            OldDamage = PRI.EnemyDamage;
            NewDamage = OldDamage + Damage;
            PRI.EnemyDamage = NewDamage;

            Score = NewDamage - OldDamage;
            if(Score > 0.0)
            {
                // log event
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

    if(Misc_Player(Player) != None)
        Misc_Player(Player).DeadClientSetViewTarget(BestStart);

    return BestStart;
} // FindPlayerStart()

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

        // force ready after 90-ish seconds
        if(!bReady && bForceRUP && bPlayersMustBeReady && (ElapsedTime > 60))
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

function StartMatch()
{
    Super.StartMatch();

    CurrentRound = 1;
    TAM_GRI(GameReplicationInfo).CurrentRound = 1;
    GameEvent("NewRound", string(CurrentRound), none);

    RoundTime = 60 * MinsPerRound;
    TAM_GRI(GameReplicationInfo).RoundTime = RoundTime;
    RespawnTime = 2;
    LockTime = 5;

    bWeaponsLocked = true;
}

function StartNewRound()
{
    RespawnTime = 4;
    LockTime = 5;

    bRoundOT = false;
    RoundOTTime = 0;
    RoundTime = 60 * MinsPerRound;

    bWeaponsLocked = true;
    Misc_BaseGRI(GameReplicationInfo).bWeaponsLocked = true;

    CurrentRound++;
    TAM_GRI(GameReplicationInfo).CurrentRound = CurrentRound;
    bEndOfRound = false;
    TAM_GRI(GameReplicationInfo).bEndOfRound = false;

    TAM_GRI(GameReplicationInfo).RoundTime = RoundTime;
    TAM_GRI(GameReplicationInfo).RoundMinute = RoundTime;
    Misc_BaseGRI(GameReplicationInfo).NetUpdateTime = Level.TimeSeconds - 1;

    GameEvent("NewRound", string(CurrentRound), none);
}

function RespawnPlayers(bool bMoveAlive)
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
            //PlayerController(c).ClientReset();
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

// modify player logging in
event PostLogin(PlayerController NewPlayer)
{
	Super.PostLogin(NewPlayer);

    if(bRoundBased && !bRespawning && CurrentRound > 0)
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

    CheckMaxLives(None);
} // PostLogin()

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

	if(bRoundBased && !bRespawning && CurrentRound > 0)
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

    //NewBot.bAdrenalineEnabled = bAllowAdrenaline;

    CheckMaxLives(none);

	return true;
} // AddBot()

function string SwapDefaultCombo(string ComboName)
{
    if(ComboName ~= "xGame.ComboSpeed")
        return "3SPNv3177AT.Misc_ComboSpeed";
    else if(ComboName ~= "xGame.ComboBerserk")
        return "3SPNv3177AT.Misc_ComboBerserk";

    return ComboName;
}

function string RecommendCombo(string ComboName)
{
    local int i;
    local bool bEnabled;

    if(EnabledCombos.Length == 0)
        return Super.RecommendCombo(ComboName);

    for(i = 0; i < EnabledCombos.Length; i++)
    {
        if(EnabledCombos[i] ~= ComboName)
        {
            bEnabled = true;
            break;
        }
    }

    if(!bEnabled)
        ComboName = EnabledCombos[Rand(EnabledCombos.Length)];

    return SwapDefaultCombo(ComboName);
}

function AddGameSpecificInventory(Pawn P)
{
    Super.AddGameSpecificInventory(P);

    if(p == None || p.Controller == None || p.Controller.PlayerReplicationInfo == None)
        return;

    SetupPlayer(P);
    //GiveWeapons(P);
    //GiveAmmo(P);
}

function SetupPlayer(Pawn P)
{
    local byte won;
    local int health;
    local int armor;
    local float formula;

    if(bChallengeMode)
    {
        won = int(P.PlayerReplicationInfo.Score / 10000);

        if(RoundsToWin > 0)
            formula = (0.5 / RoundsToWin);
        else
            formula = 0.0;

        health = StartingHealth - ((StartingHealth * formula) * won);
        armor = StartingArmor - ((StartingArmor * formula) * won);

        p.Health = Max(40, health);
        p.HealthMax = Max(40, health);
        p.SuperHealthMax = int(health * MaxHealth);

        xPawn(p).ShieldStrengthMax = int(armor * MaxHealth);
        if(bRoundBased)
            p.AddShieldStrength(Max(0, armor));
    }
    else
    {
        p.Health = StartingHealth;
        p.HealthMax = StartingHealth;
        p.SuperHealthMax = StartingHealth * MaxHealth;

        xPawn(p).ShieldStrengthMax = StartingArmor * MaxHealth;
        if(bRoundBased)
            p.AddShieldStrength(StartingArmor);
    }

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

        p.GiveWeapon(WeaponInfo[i].WeaponName);
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
        GameReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
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
        local Actor Reset;
        local Controller c;

        if(NextRoundTime > 0)
        {
            GameReplicationInfo.bStopCountDown = true;
            NextRoundTime--;

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
            TAM_GRI(GameReplicationInfo).RoundTime = RoundTime;
            if(RoundTime % 60 == 0)
                TAM_GRI(GameReplicationInfo).RoundMinute = RoundTime;
            if(RoundTime == 0)
                bRoundOT = true;
        }

        if(RespawnTime > 0)
        {
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

        if(bRoundBased)
            CheckForCampers();

        Super.Timer();
    }
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
            // log("Kicking Camper (Possibly Idle): "$c.PlayerReplicationInfo.PlayerName);
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

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
    Super.Killed(Killer, Killed, KilledPawn, DamageType);

    if(!bRoundBased && Killer != None && Killer != Killed)
    {
        Killer.PlayerReplicationInfo.Score += 10000;

        if(int(Killer.PlayerReplicationInfo.Score / 10000) >= RoundsToWin)
        {
            AnnounceBest();
            EndGame(Killer.PlayerReplicationInfo, "LastMan");
        }
    }

    if(Killed != None && Killed.PlayerReplicationInfo != None)
    {
        if(bRespawning || !bRoundBased)
        {
            Killed.PlayerReplicationInfo.bOutOfLives = false;
            Killed.PlayerReplicationInfo.NumLives = 1;
        }
        else
        {
            Killed.PlayerReplicationInfo.bOutOfLives = true;
            Killed.PlayerReplicationInfo.NumLives = 0;
        }
    }
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
    if ( (Killer == Other) || (Killer == None) )
        BroadcastLocalized(self, class'Message_PlayerKilled', 1, None, Other.PlayerReplicationInfo, damageType);
    else
        BroadcastLocalized(self, class'Message_PlayerKilled', 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
}

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

    if(Controller(ViewTarget) != None)
        return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer);
    else
        return (xPawn(ViewTarget).IsPlayerPawn() && xPawn(ViewTarget).PlayerReplicationInfo != None);
}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if(!bRoundBased || bWaitingToStartMatch || bEndOfRound || bWeaponsLocked)
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
			else if(C.PlayerReplicationInfo != Living)
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
    local PlayerController PC;

    bEndOfRound = true;
    TAM_GRI(GameReplicationInfo).bEndOfRound = true;

    if(Scorer == None)
    {
        NextRoundTime = 7;
        return;
    }

    Scorer.Score += 10000;
    ScoreEvent(Scorer, 0, "ObjectiveScore");

    if(int(Scorer.Score / 10000) >= RoundsToWin)
    {
        AnnounceBest();
        EndGame(Scorer, "LastMan");
    }
    else
    {
        for(c = Level.ControllerList; c != None; c = c.NextController)
        {
            PC = PlayerController(c);

            if(PC != None && PC.PlayerReplicationInfo != None)
            {
                if(PC.PlayerReplicationInfo == Scorer || (PC.PlayerReplicationInfo.bOnlySpectator &&
                    (xPawn(PC.ViewTarget) != None && xPawn(PC.ViewTarget).PlayerReplicationInfo == Scorer) ||
                    (Controller(PC.ViewTarget) != None && Controller(PC.ViewTarget).PlayerReplicationInfo == Scorer)))
                    PC.ReceiveLocalizedMessage(class'Message_YouveXTheRound', 1);
                else
                    PC.ReceiveLocalizedMessage(class'Message_YouveXTheRound', 0);
            }
        }

        NextRoundTime = 7;
    }
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

    local string Text;
    local string Green;
    local Color  color;

    color.r = 100;
    color.g = 200;
    color.b = 100;
    Green = class'DMStatsScreen'.static.MakeColorCode(color);

    color.b = 210;
    color.r = 210;
    color.g = 210;
    Text = class'DMStatsScreen'.static.MakeColorCode(color);

    for(C = Level.ControllerList; C != None; C = C.NextController)
	{
		PRI = Misc_PRI(C.PlayerReplicationInfo);

		if(PRI == None || PRI.bOnlySpectator)
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
        acc = Text$"Most Accurate:"@Green$accuracy.PlayerName$Text$";"@accuracy.AveragePercent$"%";

    if(damage != None && damage.EnemyDamage > 0)
        dam = Text$"Most Damage:"@Green$damage.PlayerName$Text$";"@damage.EnemyDamage;

    if(headshots != None && headshots.Headshots > 0)
        hs =  Text$"Most Headshots:"@Green$headshots.PlayerName$Text$";"@headshots.Headshots;

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

    GoalScore = RoundsToWin;
    
	MutTAM.ResetWeaponsToDefaults(bModifyShieldGun);    

    // apply changes made by an admin
    if(NextMapString != "")
    {
        ParseOptions(NextMapString);
        saveconfig();
        NextMapString = "";
    }

    // set all defaults back to their original values
    Class'xPawn'.Default.ControllerClass = class'XGame.xBot';
    Class'XGame.ComboSpeed'.default.Duration = 16;

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
     StartingArmor=100
     MaxHealth=1.250000
     AdrenalinePerDamage=1.000000
     bDisableSpeed=True
     bDisableInvis=True
     bDisableBerserk=True
     MaxAdrenaline=200
     bForceRUP=True
     MinsPerRound=2
     OTDamage=5
     OTInterval=3
     CampThreshold=400.000000
     CampInterval=5
     bKickExcessiveCampers=True
     bUseCamperIcon=True
     bRoundBased=True
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
     bDamageIndicator=True
     GameName2="ArenaMaster"
     bPlayersMustBeReady=True
     ADR_MinorError=-5.000000
     LocalStatsScreenClass=Class'3SPNv3177AT.Misc_StatBoard'
     DefaultPlayerClassName="3SPNv3177AT.Misc_Pawn"
     ScoreBoardType="3SPNv3177AT.AM_Scoreboard"
     HUDType="3SPNv3177AT.AM_HUD"
     MapListType="3SPNv3177AT.MapListAM"
     GoalScore=5
     MaxLives=1
     TimeLimit=0
     DeathMessageClass=Class'3SPNv3177AT.Misc_DeathMessage'
     MutatorClass="3SPNv3177AT.TAM_Mutator"
     PlayerControllerClassName="3SPNv3177AT.Misc_Player"
     GameReplicationInfoClass=Class'3SPNv3177AT.TAM_GRI'
     GameName="ArenaMaster v3.177 AT"
     Description="One life per round. Don't waste it"
     Acronym="AM"
}
