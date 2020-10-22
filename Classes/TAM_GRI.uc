class TAM_GRI extends Misc_BaseGRI;

var bool bChallengeMode;
var bool bDisableTeamCombos;
var bool bRandomPickups;
var bool bDisableNecro;

replication
{
    reliable if(bNetInitial && Role == ROLE_Authority)
        bDisableTeamCombos, bChallengeMode, bRandomPickups, bDisableNecro;
}

defaultproperties
{
}
