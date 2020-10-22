class Misc_BaseGRI extends GameReplicationInfo;

var string Version;

var int RoundTime;
var int RoundMinute;
var int CurrentRound;
var bool bEndOfRound;

var int MinsPerRound;
var int OTDamage;
var int OTInterval;

var int StartingHealth;
var int StartingArmor;
var float MaxHealth;

var float CampThreshold;
var bool bKickExcessiveCampers;

var bool bForceRUP;

var bool bDisableSpeed;
var bool bDisableBooster;
var bool bDisableInvis;
var bool bDisableBerserk;
var int  MaxAdrenaline;
var int  TimeOuts;
var bool bSpectateAll;
var bool bRoundBased;

var bool bWeaponsLocked;

var bool bHasNewsText;

var byte MaxPlayersForBoost;
var bool bUseChatIcon;
var bool EnableNewNet;
var bool bDamageIndicator;

replication
{
    reliable if(bNetInitial && Role == ROLE_Authority)
        RoundTime, MinsPerRound, bDisableSpeed, bDisableBooster, bDisableInvis,
        bDisableBerserk, MaxAdrenaline, StartingHealth, StartingArmor, MaxHealth, OTDamage,
        OTInterval, CampThreshold, bKickExcessiveCampers, bForceRUP,
        TimeOuts, bSpectateAll, bRoundBased, MaxPlayersForBoost, bUseChatIcon, EnableNewNet, bDamageIndicator;

    reliable if(!bNetInitial && bNetDirty && Role == ROLE_Authority)
        RoundMinute;

    reliable if(bNetDirty && Role == ROLE_Authority)
        CurrentRound, bEndOfRound, bWeaponsLocked;
}

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

    if (Role == ROLE_Authority)
    {
        class'Text_TabNews'.static.PrepareText();
        
        MaxPlayersForBoost = class'TAM_Mutator'.default.MaxPlayersForBoost;
        class'Misc_Player'.default.MaxPlayersForBoost = MaxPlayersForBoost;
        
        class'Misc_PRI'.default.bAllowStatsRecovery = class'TAM_Mutator'.default.bAllowStatsRecovery;

        class'Misc_PRI'.default.NecroUseScoreAward = class'TAM_Mutator'.default.NecroUseScoreAward;
        
        bUseChatIcon = class'TAM_Mutator'.default.bUseChatIcon;
        class'Misc_Pawn'.default.bUseChatIcon = bUseChatIcon;
    }
}

simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    
    if (Role < ROLE_Authority)
    {
        class'Misc_Player'.default.MaxPlayersForBoost = MaxPlayersForBoost;

        class'Misc_Pawn'.default.bUseChatIcon = bUseChatIcon;        
    }
}

simulated function Timer()
{
    Super.Timer();

    if(Level.NetMode == NM_Client)
    {
        if(RoundMinute > 0)
        {
            RoundTime = RoundMinute;
            RoundMinute = 0;
        }

        if(RoundTime > 0 && !bStopCountDown)
            RoundTime--;
    }
}

defaultproperties
{
     Version="3.177 AT"
     bRoundBased=True
     EnableNewNet=True
}
