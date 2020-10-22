class PlayerStatsBackup extends Info;

/* from PlayerReplicationInfo */
var float Score;
var float Deaths;

var int	StartTime;
var int	GoalsScored;
var int	Kills;
/* from PlayerReplicationInfo */

/* from TeamPlayerReplicationInfo */
var bool bFirstBlood;
var array<TeamPlayerReplicationInfo.WeaponStats> WeaponStatsArray;
var byte Spree[6];
var byte MultiKills[7];
var int Suicides;
var int flakcount,combocount,headcount,ranovercount;
var byte Combos[5];
/* from TeamPlayerReplicationInfo */

/* from Misc_PRI */
var bool bWarned;
var int CampCount;
var int ConsecutiveCampCount;

var int EnemyDamage;
var int AllyDamage;
var float ReverseFF;

var int FlawlessCount;
var int OverkillCount;
var int DarkHorseCount;

var int JoinRound;

var Misc_PRI.HitStats Assault;
var Misc_PRI.HitStat  Bio;
var Misc_PRI.HitStats Shock;
var Misc_PRI.HitStat  Combo;
var Misc_PRI.HitStats Link;
var Misc_PRI.HitStats Mini;
var Misc_PRI.HitStats Flak;
var Misc_PRI.HitStat  Rockets;
var Misc_PRI.HitStat  Sniper;

var int SGDamage;
var int HeadShots;
var float AveragePercent;

/* from Misc_PRI */

var float Adrenaline;

var string PlayerName;
var string PlayerGUID;

function SaveData(Misc_PRI PRI, string inPlayerName, string inGUID)
{
    local int i;

    PlayerName = inPlayerName;
    PlayerGUID = inGUID;

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
    // WpChallengeFlags = PRI.WpChallengeFlags;

    if(Controller(PRI.Owner) != None)
        Adrenaline = Controller(PRI.Owner).Adrenaline;
}

function bool RestoreData(Misc_PRI PRI, string inPlayerName, string inGUID)
{
    local int i;

    if(PlayerName ~= inPlayerName && PlayerGUID ~= inGUID)
    {
        PRI.Score = Score;
        PRI.Deaths = Deaths;
        PRI.StartTime = StartTime;
        PRI.GoalsScored = GoalsScored;
        PRI.Kills = Kills;

        PRI.bFirstBlood = bFirstBlood;
        PRI.WeaponStatsArray = WeaponStatsArray;
        for(i = 0; i < 6; i++)
            PRI.Spree[i] = Spree[i];
        for(i = 0; i < 7; i++)
            PRI.MultiKills[i] = MultiKills[i];
        PRI.Suicides = Suicides;
        PRI.flakcount = flakcount;
        PRI.combocount = combocount;
        PRI.headcount = headcount;
        PRI.ranovercount = ranovercount;
        for(i = 0; i < 5; i++)
            PRI.Combos[i] = Combos[i];

        PRI.bWarned = bWarned;
        PRI.CampCount = CampCount;
        PRI.ConsecutiveCampCount = ConsecutiveCampCount;
        PRI.EnemyDamage = EnemyDamage;
        PRI.AllyDamage = AllyDamage;
        PRI.ReverseFF = ReverseFF;
        PRI.FlawlessCount = FlawlessCount;
        PRI.OverkillCount = OverkillCount;
        PRI.DarkHorseCount = DarkHorseCount;
        PRI.JoinRound = JoinRound;

        PRI.Assault = Assault;
        PRI.Bio = Bio;
        PRI.Shock = Shock;
        PRI.Combo = Combo;
        PRI.Link = Link;
        PRI.Mini = Mini;
        PRI.Flak = Flak;
        PRI.Rockets = Rockets;
        PRI.Sniper = Sniper;
        PRI.SGDamage = SGDamage;
        PRI.HeadShots = HeadShots;
        PRI.AveragePercent = AveragePercent;

        if(Controller(PRI.Owner) != None)
            Controller(PRI.Owner).Adrenaline = Adrenaline;

        return true;
    }

    return false;
}

defaultproperties
{
}
