class Menu_TabTAMAdmin extends UT2k3TabPanel;

var bool bAdmin;

var moComboBox MapList;
var string MapName;
var array<string> Maps;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);

    moEditBox(Controls[4]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).StartingHealth));
    moEditBox(Controls[5]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).StartingArmor));
    moCheckBox(Controls[6]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bChallengeMode);
    moEditBox(Controls[7]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).MaxHealth));

    moEditBox(Controls[8]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).MinsPerRound));
    moEditBox(Controls[9]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).OTDamage));
    moEditBox(Controls[10]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).OTInterval));
    moEditBox(Controls[20]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).Timeouts));

    moCheckBox(Controls[11]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bDisableTeamCombos);
    moCheckBox(Controls[12]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bDisableSpeed);
    moCheckBox(Controls[13]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bDisableInvis);
    moCheckBox(Controls[14]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bDisableBerserk);
    moCheckBox(Controls[15]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bDisableBooster);
    moCheckBox(Controls[21]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bDisableNecro);

    moCheckBox(Controls[16]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bKickExcessiveCampers);
    moEditBox(Controls[17]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).CampThreshold));

    moCheckBox(Controls[18]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bForceRUP);
    moCheckBox(Controls[19]).Checked(TAM_GRI(PlayerOwner().Level.GRI).bRandomPickups);

    moEditBox(Controls[20]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).Timeouts));

    moEditBox(Controls[22]).SetText(string(TAM_GRI(PlayerOwner().Level.GRI).MaxAdrenaline));

    MapName = Left(string(PlayerOwner().Level), InStr(string(PlayerOwner().Level), "."));

    MapList = moComboBox(Controls[3]);
    MapList.AddItem(MapName);
    MapList.SilentSetIndex(MapList.FindIndex(MapName));
    xPlayer(PlayerOwner()).ProcessMapName = ProcessMapName;
    xPlayer(PlayerOwner()).ServerRequestMapList();

    bAdmin = (PlayerOwner().PlayerReplicationInfo.bAdmin || PlayerOwner().Level.NetMode == NM_Standalone);
    if(!bAdmin)
        for(i = 1; i < Controls.Length; i++)
            Controls[i].DisableMe();

    SetTimer(1.0, true);
}

function ProcessMapName(string map)
{
    if(map == "")
    {
        MapList.ResetComponent();
        MapList.AddItem(MapName);
        MapList.SilentSetIndex(MapList.FindIndex(MapName));
    }
    else
    {
        if(map ~= MapName)
            return;

        MapList.AddItem(map);
    }
}

function OnChange(GUIComponent C)
{
}

function bool OnClick(GUIComponent C)
{
    local string s;

    if(!bAdmin)
        return false;

    // save
    if(C == Controls[1])
    {
        s = "?StartingHealth="$moEditBox(Controls[4]).GetText();
        s = s$"?StartingArmor="$moEditBox(Controls[5]).GetText();
        s = s$"?ChallengeMode="$moCheckBox(Controls[6]).IsChecked();
        s = s$"?MaxHealth="$moEditBox(Controls[7]).GetText();

        s = s$"?MinsPerRound="$moEditBox(Controls[8]).GetText();
        s = s$"?OTDamage="$moEditBox(Controls[9]).GetText();
        s = s$"?OTInterval="$moEditBox(Controls[10]).GetText();
        s = s$"?Timeouts="$moEditBox(Controls[20]).GetText();

        s = s$"?DisableTeamCombos="$moCheckBox(Controls[11]).IsChecked();
        s = s$"?DisableSpeed="$moCheckBox(Controls[12]).IsChecked();
        s = s$"?DisableInvis="$moCheckBox(Controls[13]).IsChecked();
        s = s$"?DisableBerserk="$moCheckBox(Controls[14]).IsChecked();
        s = s$"?DisableBooster="$moCheckBox(Controls[15]).IsChecked();
        s = s$"?DisableNecro="$moCheckBox(Controls[21]).IsChecked();
        s = s$"?MaxAdrenaline="$moEditBox(Controls[22]).GetText();

        s = s$"?KickExcessiveCampers="$moCheckBox(Controls[16]).IsChecked();
        s = s$"?CampThreshold="$moEditBox(Controls[17]).GetText();

        s = s$"?ForceRUP="$moCheckBox(Controls[18]).IsChecked();
        s = s$"?RandomPickups="$moCheckBox(Controls[19]).IsChecked();
        s = s$"?Timeouts="$moEditBox(Controls[20]).GetText();

        if(Misc_Player(PlayerOwner())  != None)
        {
            Misc_Player(PlayerOwner()).ClientMessage("Sent settings to server");
            Misc_Player(PlayerOwner()).ServerSetMapString(s);
        }
    }

    // map change
    if(C == Controls[2])
    {
        s = MapList.GetText();

        if(PlayerOwner().Level.NetMode != NM_Standalone)
            PlayerOwner().ConsoleCommand("admin servertravel"@s);
        else
            PlayerOwner().ConsoleCommand("open"@s);
    }

    return true;
}

function Timer()
{
    local bool bNewAdmin;
    local int i;

    bAdmin = true;

    bNewAdmin = (PlayerOwner().PlayerReplicationInfo.bAdmin || PlayerOwner().Level.NetMode == NM_Standalone);
    if(bNewAdmin == bAdmin)
        return;

    bAdmin = bNewAdmin;

    if(!bAdmin)
        for(i = 1; i < Controls.Length; i++)
            Controls[i].DisableMe();
    else
        for(i = 1; i < Controls.Length; i++)
            Controls[i].EnableMe();
}

defaultproperties
{
     Begin Object Class=GUIImage Name=TabBackground
         Image=Texture'InterfaceContent.Menu.ScoreBoxA'
         ImageColor=(B=0,G=0,R=0)
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'3SPNv3177AT.Menu_TabTAMAdmin.TabBackground'

     Begin Object Class=GUIButton Name=SaveButton
         Caption="Save"
         StyleName="ServerBrowserGridHeader"
         Hint="Save settings. Changes will take effect on the next map."
         WinTop=0.850000
         WinLeft=0.300000
         WinWidth=0.150000
         WinHeight=0.070000
         OnClick=Menu_TabTAMAdmin.OnClick
         OnKeyEvent=SaveButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'3SPNv3177AT.Menu_TabTAMAdmin.SaveButton'

     Begin Object Class=GUIButton Name=LoadButton
         Caption="Load Map"
         StyleName="ServerBrowserGridHeader"
         Hint="Force a map change."
         WinTop=0.850000
         WinLeft=0.550000
         WinWidth=0.150000
         WinHeight=0.070000
         OnClick=Menu_TabTAMAdmin.OnClick
         OnKeyEvent=LoadButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'3SPNv3177AT.Menu_TabTAMAdmin.LoadButton'

     Begin Object Class=moComboBox Name=MapBox
         CaptionWidth=0.200000
         Caption="Map:"
         OnCreateComponent=MapBox.InternalOnCreateComponent
         WinTop=0.775000
         WinLeft=0.200000
         WinWidth=0.600000
         WinHeight=0.037500
     End Object
     Controls(3)=moComboBox'3SPNv3177AT.Menu_TabTAMAdmin.MapBox'

     Begin Object Class=moEditBox Name=HealthBox
         CaptionWidth=0.600000
         Caption="Health:"
         OnCreateComponent=HealthBox.InternalOnCreateComponent
         WinTop=0.050000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(4)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.HealthBox'

     Begin Object Class=moEditBox Name=ArmorBox
         CaptionWidth=0.600000
         Caption="Armor:"
         OnCreateComponent=ArmorBox.InternalOnCreateComponent
         WinTop=0.050000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(5)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.ArmorBox'

     Begin Object Class=moCheckBox Name=ChallengeCheck
         Caption="Challenge Mode"
         OnCreateComponent=ChallengeCheck.InternalOnCreateComponent
         Hint="Round winners take a health/armor penalty."
         WinTop=0.100000
         WinLeft=0.050000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(6)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.ChallengeCheck'

     Begin Object Class=moEditBox Name=MaxHealthBox
         CaptionWidth=0.600000
         Caption="Max Health:"
         OnCreateComponent=MaxHealthBox.InternalOnCreateComponent
         WinTop=0.100000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(7)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.MaxHealthBox'

     Begin Object Class=moEditBox Name=MinsBox
         CaptionWidth=0.600000
         Caption="Minutes Per Round:"
         OnCreateComponent=MinsBox.InternalOnCreateComponent
         WinTop=0.200000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(8)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.MinsBox'

     Begin Object Class=moEditBox Name=OTDamBox
         CaptionWidth=0.600000
         Caption="Overtime Damage:"
         OnCreateComponent=OTDamBox.InternalOnCreateComponent
         WinTop=0.200000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(9)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.OTDamBox'

     Begin Object Class=moEditBox Name=OTIntBox
         CaptionWidth=0.600000
         Caption="Damage Interval:"
         OnCreateComponent=OTIntBox.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(10)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.OTIntBox'

     Begin Object Class=moCheckBox Name=TeamCombosCheck
         Caption="Disable Team Combos"
         OnCreateComponent=TeamCombosCheck.InternalOnCreateComponent
         WinTop=0.330000
         WinLeft=0.050000
         WinWidth=0.900000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(11)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.TeamCombosCheck'

     Begin Object Class=moCheckBox Name=SpeedCheck
         Caption="Disable Speed"
         OnCreateComponent=SpeedCheck.InternalOnCreateComponent
         WinTop=0.380000
         WinLeft=0.050000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(12)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.SpeedCheck'

     Begin Object Class=moCheckBox Name=InvisCheck
         Caption="Disable Invis"
         OnCreateComponent=InvisCheck.InternalOnCreateComponent
         WinTop=0.380000
         WinLeft=0.550000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(13)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.InvisCheck'

     Begin Object Class=moCheckBox Name=BerserkCheck
         Caption="Disable Berserk"
         OnCreateComponent=BerserkCheck.InternalOnCreateComponent
         WinTop=0.430000
         WinLeft=0.050000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(14)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.BerserkCheck'

     Begin Object Class=moCheckBox Name=BoosterCheck
         Caption="Disable Booster"
         OnCreateComponent=BoosterCheck.InternalOnCreateComponent
         WinTop=0.430000
         WinLeft=0.550000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(15)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.BoosterCheck'

     Begin Object Class=moCheckBox Name=KickCheck
         Caption="Kick Excessive Campers"
         OnCreateComponent=KickCheck.InternalOnCreateComponent
         WinTop=0.635000
         WinLeft=0.050000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(16)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.KickCheck'

     Begin Object Class=moEditBox Name=CampBox
         CaptionWidth=0.600000
         Caption="Camp Area:"
         OnCreateComponent=CampBox.InternalOnCreateComponent
         WinTop=0.635000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(17)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.CampBox'

     Begin Object Class=moCheckBox Name=ForceCheck
         Caption="Force Ready"
         OnCreateComponent=ForceCheck.InternalOnCreateComponent
         WinTop=0.700000
         WinLeft=0.050000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(18)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.ForceCheck'

     Begin Object Class=moCheckBox Name=PickupCheck
         Caption="Random Pickups"
         OnCreateComponent=PickupCheck.InternalOnCreateComponent
         Hint="Spawns three pickups which give random effect when picked up: Health +15, Shield +15 or Adren +10"
         WinTop=0.700000
         WinLeft=0.550000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(19)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.PickupCheck'

     Begin Object Class=moEditBox Name=TOBox
         CaptionWidth=0.600000
         Caption="Timeouts:"
         OnCreateComponent=TOBox.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(20)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.TOBox'

     Begin Object Class=moCheckBox Name=NecroCheck
         Caption="Disable Necro"
         OnCreateComponent=NecroCheck.InternalOnCreateComponent
         WinTop=0.480000
         WinLeft=0.050000
         WinWidth=0.400000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(21)=moCheckBox'3SPNv3177AT.Menu_TabTAMAdmin.NecroCheck'

     Begin Object Class=moEditBox Name=MaxAdren
         Caption="Maximum Adrenaline"
         OnCreateComponent=MaxAdren.InternalOnCreateComponent
         Hint="Maximum amount of adrenaline a player can have."
         WinTop=0.560000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.060000
         OnChange=Menu_TabTAMAdmin.OnChange
     End Object
     Controls(22)=moEditBox'3SPNv3177AT.Menu_TabTAMAdmin.MaxAdren'

}
