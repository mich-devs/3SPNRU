class Misc_PRI extends xPlayerReplicationInfo;

// NR = not automatically replicated

var bool bWarned;               // has been warned for camping (next time will receive penalty) - NR
var int CampCount;              // the number of times penalized for camping - NR
var int ConsecutiveCampCount;   // the number of times penalized for camping consecutively - NR

var int EnemyDamage;            // damage done to enemies - NR
var int AllyDamage;             // damage done to allies and self - NR
var float ReverseFF;            // percentage of friendly fire that is returned - NR

var int FlawlessCount;          // number of flawless victories - NR
var int OverkillCount;          // number of overkills - NR
var int DarkHorseCount;         // number of darkhorses - NR

var int JoinRound;              // the round the player joined on

/* hitstats */
struct HitStat
{
    var int Fired;
    var int Hit;
    var int Damage;
};

struct HitStats
{
    var HitStat Primary;
    var HitStat Secondary;
};

var HitStats    Assault;
var HitStat     Bio;
var HitStats    Shock;
var HitStat     Combo;
var HitStats    Link;
var HitStats    Mini;
var HitStats    Flak;
var HitStat     Rockets;
var HitStat     Sniper;

var int         SGDamage;
var int         HeadShots;
var float       AveragePercent;
/* hitstats */

var class<Misc_PawnReplicationInfo> PawnInfoClass;
var Misc_PawnReplicationInfo PawnReplicationInfo;

var int NecroUseScoreAward;
var bool bAllowStatsRecovery;

var string LoginName;
var string LoginGUID;
var bool bSaveStatsOnDelete;

var private string ColoredName;

replication
{
    reliable if(bNetInitial && Role == ROLE_Authority)
        JoinRound;

    reliable if(bNetDirty && Role == ROLE_Authority)
        PawnReplicationInfo;

    reliable if(Role < ROLE_Authority)
        ServerSendNewsText;

    reliable if(Role == ROLE_Authority)
        ClientReceiveNewsText;

    reliable if(Role == ROLE_Authority)
        ColoredName;

    reliable if(Role < ROLE_Authority)
        ServerSetColoredName;
}

function Reset()
{
	HasFlag = None;
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
}

simulated function Destroyed()
{
    Super.Destroyed();

    if(bSaveStatsOnDelete && Role == ROLE_Authority)
        SaveStats();
}

simulated function string GetColoredName()
{
    if(class'GUIComponent'.static.StripColorCodes(ColoredName) ~= PlayerName)
        return ColoredName;

    return PlayerName;
}

simulated function string GetColoredNameEx()
{
    if(class'GUIComponent'.static.StripColorCodes(ColoredName) ~= PlayerName)
    {
        if(ColoredName ~= PlayerName)
            return PlayerName;
        else
            return ColoredName $ "";
    }
    return PlayerName;
}

function ServerSetColoredName(string Name)
{
    local string RealName;

    if(Name == "" || Len(Name) > 100)
        return;

    if(InStr(Name, "") >= 0)
        return;

    RealName = class'GUIComponent'.static.StripColorCodes(Name);
    if(RealName == "" || Len(RealName) > 20)
        return;

    ColoredName = Name;
}

function SaveStats()
{
    local PlayerStatsBackup PB;

    if(!bAllowStatsRecovery)
        return;

    if(bBot || !Level.Game.GameReplicationInfo.bMatchHasBegun || Level.bLevelChange)
        return;

    // save stats data before deleting PRI
    foreach DynamicActors(class'PlayerStatsBackup', PB)
        if(PlayerName ~= PB.PlayerName && LoginGUID ~= PB.PlayerGUID)
        {
            PB.SaveData(self, PlayerName, LoginGUID);
            return;
        }

    PB = Spawn(class'PlayerStatsBackup');

    if(PB != None)
        PB.SaveData(self, PlayerName, LoginGUID);
}

function RestoreStats()
{
    local Misc_PRI PRI;
    local PlayerStatsBackup PB;
    local int i;
    local string s;

    if(!bAllowStatsRecovery)
        return;

    if(bBot || !Level.Game.GameReplicationInfo.bMatchHasBegun || Level.bLevelChange)
        return;

    // if a player loses internet connection, his PRI may still exist, if any, use that
    foreach DynamicActors(class'Misc_PRI', PRI)
        if(PRI != self && PRI.PlayerName ~= LoginName && PRI.LoginGUID ~= LoginGUID)
        {
            Score = PRI.Score;
            Deaths = PRI.Deaths;
            StartTime = PRI.StartTime;
            GoalsScored = PRI.GoalsScored;
            Kills = PRI.Kills;

            bFirstBlood = PRI.bFirstBlood;
            WeaponStatsArray = PRI.WeaponStatsArray;
            for(i = 0; i < 6; i++)
                Spree[i] = PRI.Spree[i];
            for(i = 0; i < 7; i++)
            MultiKills[i] = PRI.MultiKills[i];
            Suicides = PRI.Suicides;
            flakcount = PRI.flakcount;
            combocount = PRI.combocount;
            headcount = PRI.headcount;
            ranovercount = PRI.ranovercount;
            for(i = 0; i < 5; i++)
                Combos[i] = PRI.Combos[i];

            bWarned = PRI.bWarned;
            CampCount = PRI.CampCount;
            ConsecutiveCampCount = PRI.ConsecutiveCampCount;
            EnemyDamage = PRI.EnemyDamage;
            AllyDamage = PRI.AllyDamage;
            ReverseFF = PRI.ReverseFF;
            FlawlessCount = PRI.FlawlessCount;
            OverkillCount = PRI.OverkillCount;
            DarkHorseCount = PRI.DarkHorseCount;
            JoinRound = PRI.JoinRound;

            Assault = PRI.Assault;
            Bio = PRI.Bio;
            Shock = PRI.Shock;
            Combo = PRI.Combo;
            Link = PRI.Link;
            Mini = PRI.Mini;
            Flak = PRI.Flak;
            Rockets = PRI.Rockets;
            Sniper = PRI.Sniper;
            SGDamage = PRI.SGDamage;
            HeadShots = PRI.HeadShots;
            AveragePercent = PRI.AveragePercent;

            if(Controller(Owner) != None && Controller(PRI.Owner) != None)
                Controller(Owner).Adrenaline = Controller(PRI.Owner).Adrenaline;

            /* switch player names between PRIs, so the player get back his name,
               and further we can save stats properly if needed */
            s = PlayerName;
            PlayerName = PRI.PlayerName;
            PRI.PlayerName = s;

            // older version of PRI should NOT be saved on its deletion
            PRI.bSaveStatsOnDelete = false;
            return;
        }

    // get stats back from a saved backup copy of PRI what is previously destroyed
    foreach DynamicActors(class'PlayerStatsBackup', PB)
        if(PB.RestoreData(self, LoginName, LoginGUID) )
        {
            PB.Destroy();
            return;
        }
}

function ServerSendNewsText(int Row)
{
    if(!class'Text_TabNews'.default.bShowText || class'Text_TabNews'.default.TextPrepared.Length == 0)
        ClientReceiveNewsText(0, "");
    else if(Row < 0)
        ClientReceiveNewsText(class'Text_TabNews'.default.TextPrepared.Length-1,
                              class'Text_TabNews'.default.TextPrepared[class'Text_TabNews'.default.TextPrepared.Length-1]);
    else
        ClientReceiveNewsText(Row, class'Text_TabNews'.default.TextPrepared[Row]);
}

simulated function ClientReceiveNewsText(int Row, string Text)
{
    class'Text_TabNews'.default.TextPrepared[Row] = Text;
    if (Row > 0)
        ServerSendNewsText(Row - 1);
    else
        EndReceiveNewsText();
}

simulated function EndReceiveNewsText()
{
    local Menu_TabNews NewsTab;

    if (class'Text_TabNews'.default.TextPrepared.Length == 1 && class'Text_TabNews'.default.TextPrepared[0] == "")
        class'Text_TabNews'.default.TextPrepared.Length = 0;
    else
        class'Text_TabNews'.static.UnPrepareText();

    class'Menu_TabNews'.default.Text = class'Text_TabNews'.default.Text;
    foreach AllObjects(class'Menu_TabNews', NewsTab)
        NewsTab.Text = class'Text_TabNews'.default.Text;

    Misc_Player(Level.GetLocalPlayerController()).MenuGotData();
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    bSaveStatsOnDelete = true;

    if(!bDeleteMe && Level.NetMode != NM_Client)
        PawnReplicationInfo = Spawn(PawnInfoClass, self,, vect(0,0,0), rot(0,0,0));
}

simulated function string GetLocationName()
{
    if(bOutOfLives && !bOnlySpectator)
        return default.StringDead;

    return Super.GetLocationName();
}

function ProcessHitStats()
{
    local int count;

    AveragePercent = 0.0;

    if(Assault.Primary.Fired > 9)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Assault.Primary.Fired, Assault.Primary.Hit);
        count++;
    }

    if(Assault.Secondary.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Assault.Secondary.Fired, Assault.Secondary.Hit);
        count++;
    }

    if(Bio.Fired > 0)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Bio.Fired, Bio.Hit);
        count++;
    }

    if(Shock.Primary.Fired > 4)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Shock.Primary.Fired, Shock.Primary.Hit);
        count++;
    }

    if(Shock.Secondary.Fired > 4)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Shock.Secondary.Fired, Shock.Secondary.Hit);
        count++;
    }

    if(Combo.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Combo.Fired, Combo.Hit);
        count++;
    }

    if(Link.Primary.Fired > 9)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Link.Primary.Fired, Link.Primary.Hit);
        count++;
    }

    if(Link.Secondary.Fired > 14)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Link.Secondary.Fired, Link.Secondary.Hit);
        count++;
    }

    if(Mini.Primary.Fired > 19)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Mini.Primary.Fired, Mini.Primary.Hit);
        count++;
    }

    if(Mini.Secondary.Fired > 14)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Mini.Secondary.Fired, Mini.Secondary.Hit);
        count++;
    }

    if(Flak.Primary.Fired > 19)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Flak.Primary.Fired / 9, Flak.Primary.Hit / 9);
        count++;
    }

    if(Flak.Secondary.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Flak.Secondary.Fired, Flak.Secondary.Hit);
        count++;
    }

    if(Rockets.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Rockets.Fired, Rockets.Hit);
        count++;
    }

    if(Sniper.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Sniper.Fired, Sniper.Hit);
        count++;
    }

    if(count > 0)
        AveragePercent /= count;
}

defaultproperties
{
     PawnInfoClass=Class'3SPNv3177AT.Misc_PawnReplicationInfo'
}
