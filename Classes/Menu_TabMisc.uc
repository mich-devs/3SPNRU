class Menu_TabMisc extends UT2k3TabPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local Misc_Player MP;
    local TAM_GRI GRI;

    Super.InitComponent(MyController, MyOwner);

    MP = Misc_Player(PlayerOwner());
    if(MP == None)
        return;

    moCheckBox(Controls[5]).Checked(MP.bMatchHUDToSkins);
    moCheckBox(Controls[6]).Checked(MP.bShowTeamInfo && !MP.bExtendedInfo);
    moCheckBox(Controls[7]).Checked(!MP.bShowCombos);
    moCheckBox(Controls[14]).Checked(MP.bShowTeamInfo && MP.bExtendedInfo);
    moCheckBox(Controls[15]).Checked(MP.bTeamColoredDeathMessages);

    moCheckBox(Controls[16]).Checked(!class'Misc_Pawn'.default.bPlayOwnFootsteps);
    moCheckBox(Controls[17]).Checked(MP.bAutoScreenShot);

	moCheckBox(Controls[8]).Checked(!MP.bUseHitSounds);
    GUISlider(Controls[9]).Value = MP.SoundHitVolume;

    GUISlider(Controls[18]).Value = MP.SoundAloneVolume;
    
    GRI = TAM_GRI(PlayerOwner().Level.GRI);
    if(GRI != None)
    {
        if(GRI.TimeOuts == 0 && !PlayerOwner().PlayerReplicationInfo.bAdmin)
             GUIButton(Controls[20]).DisableMe();
         
        moCheckBox(Controls[1]).Checked(MP.bDisableSpeed);
        moCheckBox(Controls[2]).Checked(MP.bDisableBooster);
        moCheckBox(Controls[3]).Checked(MP.bDisableBerserk);
        moCheckBox(Controls[4]).Checked(MP.bDisableInvis);
        if(GRI.bDisableNecro)
        {
            moCheckBox(Controls[21]).StandardHeight = 0.0;
            moCheckBox(Controls[21]).DisableMe();
        }
        else
            moCheckBox(Controls[21]).Checked(MP.bDisableNecro);

		if(!GRI.EnableNewNet || GRI.Level.NetMode == NM_Standalone)
			moCheckBox(Controls[22]).DisableMe();
        else
            moCheckBox(Controls[22]).Checked(MP.bEnableEnhancedNetCode);

		if(!GRI.bDamageIndicator && GRI.Level.NetMode != NM_Standalone)
        {
            moCheckBox(Controls[23]).StandardHeight = 0.0;
			moCheckBox(Controls[23]).DisableMe();
            moCheckBox(Controls[24]).StandardHeight = 0.0;
			moCheckBox(Controls[24]).DisableMe();
            GUILabel(Controls[26]).StandardHeight = 0.0;
        }
        else
        {
            moCheckBox(Controls[23]).Checked(MP.DamageIndicator == Centered);
            moCheckBox(Controls[24]).Checked(MP.DamageIndicator == Floating);
        }
    }
    else
    {
        moCheckBox(Controls[22]).DisableMe();
        GUIButton(Controls[20]).DisableMe();
    }
}

function OnChange(GUIComponent C)
{
    local bool b;
    local Misc_Player MP;
    MP = Misc_Player(PlayerOwner());
    if(MP == None)
        return;

    if(moCheckBox(c) != None)
    {
        b = moCheckBox(c).IsChecked();
        if(c == Controls[1])
        {
            MP.bDisableSpeed = b;
            class'Misc_Player'.default.bDisableSpeed = b;
        }
        else if(c == Controls[2])
        {
            MP.bDisableBooster = b;
            class'Misc_Player'.default.bDisableBooster = b;
        }
        else if(c == Controls[3])
        {
            MP.bDisableBerserk = b;
            class'Misc_Player'.default.bDisableBerserk = b;
        }
        else if(c == Controls[4])
        {
            MP.bDisableInvis = b;
            class'Misc_Player'.default.bDisableInvis = b;
        }
        else if(c == Controls[21])
        {
            MP.bDisableNecro = b;
            class'Misc_Player'.default.bDisableNecro = b;
        }
        else if(c == Controls[5])
        {
            MP.bMatchHUDToSkins = b;
            class'Misc_Player'.default.bMatchHUDToSkins = b;
        }
        else if(c == Controls[6])
        {
            MP.bShowTeamInfo = b;
            class'Misc_Player'.default.bShowTeamInfo = b;
            if (b)
            {
                MP.bExtendedInfo = false;
                class'Misc_Player'.default.bExtendedInfo = false;
                moCheckBox(Controls[14]).MyCheckBox.bChecked = false;
            }
        }
        else if(c == Controls[7])
        {
            MP.bShowCombos = !b;
            class'Misc_Player'.default.bShowCombos = !b;
        }
        else if(c == Controls[14])
        {
            MP.bExtendedInfo = b;
            class'Misc_Player'.default.bExtendedInfo = b;
            if (b)
            {
                MP.bShowTeamInfo = true;
                class'Misc_Player'.default.bShowTeamInfo = true;
                moCheckBox(Controls[6]).MyCheckBox.bChecked = false;
            }
            else
            {
                MP.bShowTeamInfo = false;
                class'Misc_Player'.default.bShowTeamInfo = false;
                moCheckBox(Controls[6]).MyCheckBox.bChecked = false;
            }
        }
        else if(c == Controls[15])
        {
            MP.bTeamColoredDeathMessages = b;
            class'Misc_Player'.default.bTeamColoredDeathMessages = b;
        }

        else if(c == Controls[16])
        {
            class'UnrealPawn'.default.bPlayOwnFootsteps = !b;
            class'xPawn'.default.bPlayOwnFootsteps = !b;
            class'Misc_Pawn'.default.bPlayOwnFootsteps = !b;
            class'Misc_Pawn'.static.StaticSaveConfig();

            if(xPawn(MP.Pawn) != None)
            {
                xPawn(MP.Pawn).bPlayOwnFootsteps = !b;
                MP.Pawn.SaveConfig();
            }
            return;
        }

        else if(c == Controls[17])
        {
            MP.bAutoScreenShot = b;
            class'Misc_Player'.default.bAutoScreenShot = b;
        }

        else if(c == Controls[8])
        {
            MP.bUseHitSounds = !b;
            class'Misc_Player'.default.bUseHitSounds = !b;

            if(b)
                GUISlider(Controls[9]).DisableMe();
            else
                GUISlider(Controls[9]).EnableMe();
        }
        
        else if(c == Controls[22])
        {
            MP.bEnableEnhancedNetCode = b;
			class'Misc_Player'.default.bEnableEnhancedNetCode = b;
			if(!b)
				Misc_Player(PlayerOwner()).SetNetCodeDisabled();
        }

        else if(c == Controls[23])
        {
            if (b)
            {
                MP.DamageIndicator = Centered;
                class'Misc_Player'.default.DamageIndicator = Centered;
                moCheckBox(Controls[24]).MyCheckBox.bChecked = false;
            }
            else
            {
                MP.DamageIndicator = Disabled;
                class'Misc_Player'.default.DamageIndicator = Disabled;
            }
        }                

        else if(c == Controls[24])
        {
            if (b)
            {
                MP.DamageIndicator = Floating;
                class'Misc_Player'.default.DamageIndicator = Floating;
                moCheckBox(Controls[23]).MyCheckBox.bChecked = false;
            }
            else
            {
                MP.DamageIndicator = Disabled;
                class'Misc_Player'.default.DamageIndicator = Disabled;
            }
        }                
    }
    else if(GUISlider(c) != None)
    {
        switch(c)
        {
            case Controls[9]:
                MP.SoundHitVolume = GUISlider(c).Value;
                class'Misc_Player'.default.SoundHitVolume = GUISlider(c).Value;
            break;

            case Controls[18]:
                MP.SoundAloneVolume = GUISlider(c).Value;
                class'Misc_Player'.default.SoundAloneVolume = GUISlider(c).Value;
            break;
        }
    }

    MP.SaveConfig();
}

function bool OnClick(GUIComponent C)
{
    if(C == Controls[20])
    {
        Misc_Player(PlayerOwner()).CallTimeout();
        Controller.CloseMenu();
    }

	return true;
}

function Closed(GUIComponent Sender, bool bCancelled)
{
    Super.Closed(Sender, bCancelled);
    class'PlayerSettings'.static.SaveMiscSettings( Misc_Player(PlayerOwner()) );
}


// Decompiled with UE Explorer.
defaultproperties
{
    begin object name=TabBackground class=GUIImage
        Image=Texture'InterfaceContent.Menu.ScoreBoxA'
        ImageColor=(R=0,G=0,B=0,A=255)
        ImageStyle=1
        WinHeight=1.0
        bNeverFocus=true
    object end
    // Reference: GUIImage'Menu_TabMisc.TabBackground'
    Controls(0)=TabBackground
    begin object name=SpeedCheck class=moCheckBox
        Caption="Disable Speed"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Disables the Speed adrenaline combo if checked."
        WinTop=0.230
        WinLeft=0.10
        WinWidth=0.380
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.SpeedCheck'
    Controls(1)=SpeedCheck
    begin object name=BoosterCheck class=moCheckBox
        Caption="Disable Booster"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Disables the Booster adrenaline combo if checked."
        WinTop=0.230
        WinLeft=0.520
        WinWidth=0.380
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.BoosterCheck'
    Controls(2)=BoosterCheck
    begin object name=BerserkCheck class=moCheckBox
        Caption="Disable Berserk"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Disables the Berserk adrenaline combo if checked."
        WinTop=0.280
        WinLeft=0.10
        WinWidth=0.380
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.BerserkCheck'
    Controls(3)=BerserkCheck
    begin object name=InvisCheck class=moCheckBox
        Caption="Disable Invisibility"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Disables the Invisibility adrenaline combo if checked."
        WinTop=0.280
        WinLeft=0.520
        WinWidth=0.380
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.InvisCheck'
    Controls(4)=InvisCheck
    begin object name=MatchCheck class=moCheckBox
        Caption="Match HUD color to brightskins"
        OnCreateComponent=InternalOnCreateComponent
        WinTop=0.560
        WinLeft=0.10
        WinWidth=0.380
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.MatchCheck'
    Controls(5)=MatchCheck
    begin object name=TeamCheck class=moCheckBox
        Caption="Standard"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Enables showing team members and enemies on the HUD."
        WinTop=0.440
        WinLeft=0.750
        WinWidth=0.150
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.TeamCheck'
    Controls(6)=TeamCheck
    begin object name=ComboCheck class=moCheckBox
        Caption="Disable Combo List"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Disables showing combo info on the lower right portion of the HUD."
        WinTop=0.440
        WinLeft=0.10
        WinWidth=0.380
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.ComboCheck'
    Controls(7)=ComboCheck
    begin object name=HitsoundsCheck class=moCheckBox
        Caption="Disable Hitsounds"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Disables damage-dependant hitsounds (the lower the pitch, the greater the damage)."
        WinTop=0.750
        WinLeft=0.10
        WinWidth=0.80
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.HitsoundsCheck'
    Controls(8)=HitsoundsCheck
    begin object name=HitVolumeSlider class=GUISlider
        MaxValue=2.0
        WinTop=0.8050
        WinLeft=0.50
        WinWidth=0.40
        OnClick=InternalOnClick
        OnMousePressed=InternalOnMousePressed
        OnMouseRelease=InternalOnMouseRelease
        OnChange=OnChange
        OnKeyEvent=InternalOnKeyEvent
        OnCapturedMouseMove=InternalCapturedMouseMove
    object end
    // Reference: GUISlider'Menu_TabMisc.HitVolumeSlider'
    Controls(9)=HitVolumeSlider
    begin object name=HitVolumeLabel class=GUILabel
        Caption="Hitsound Volume:"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.790
        WinLeft=0.10
    object end
    // Reference: GUILabel'Menu_TabMisc.HitVolumeLabel'
    Controls(10)=HitVolumeLabel
    begin object name=HitSoundsLabel class=GUILabel
        Caption="Sounds:"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.70
        WinLeft=0.050
    object end
    // Reference: GUILabel'Menu_TabMisc.HitSoundsLabel'
    Controls(11)=HitSoundsLabel
    begin object name=ComboLabel class=GUILabel
        Caption="Combos:"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.180
        WinLeft=0.050
    object end
    // Reference: GUILabel'Menu_TabMisc.ComboLabel'
    Controls(12)=ComboLabel
    begin object name=HUDLabel class=GUILabel
        Caption="HUD:"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.390
        WinLeft=0.050
    object end
    // Reference: GUILabel'Menu_TabMisc.HUDLabel'
    Controls(13)=HUDLabel
    begin object name=ExtendCheck class=moCheckBox
        Caption="Extended"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Displays extra teammate info; health and location name."
        WinTop=0.490
        WinLeft=0.750
        WinWidth=0.150
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.ExtendCheck'
    Controls(14)=ExtendCheck
    begin object name=DeathsCheck class=moCheckBox
        Caption="Team-colored death messages"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Colors player names in death messages based on team."
        WinTop=0.610
        WinLeft=0.10
        WinWidth=0.380
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.DeathsCheck'
    Controls(15)=DeathsCheck
    begin object name=StepsCheck class=moCheckBox
        Caption="Disable own footsteps"
        OnCreateComponent=InternalOnCreateComponent
        WinTop=0.080
        WinLeft=0.10
        WinWidth=0.80
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.StepsCheck'
    Controls(16)=StepsCheck
    begin object name=ShotCheck class=moCheckBox
        Caption="Take end-game screenshot"
        OnCreateComponent=InternalOnCreateComponent
        WinTop=0.130
        WinLeft=0.10
        WinWidth=0.80
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.ShotCheck'
    Controls(17)=ShotCheck
    begin object name=AloneVolumeSlider class=GUISlider
        MaxValue=2.0
        WinTop=0.8550
        WinLeft=0.50
        WinWidth=0.40
        OnClick=InternalOnClick
        OnMousePressed=InternalOnMousePressed
        OnMouseRelease=InternalOnMouseRelease
        OnChange=OnChange
        OnKeyEvent=InternalOnKeyEvent
        OnCapturedMouseMove=InternalCapturedMouseMove
    object end
    // Reference: GUISlider'Menu_TabMisc.AloneVolumeSlider'
    Controls(18)=AloneVolumeSlider
    begin object name=AloneVolumeLabel class=GUILabel
        Caption="Alone Volume:"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.840
        WinLeft=0.10
    object end
    // Reference: GUILabel'Menu_TabMisc.AloneVolumeLabel'
    Controls(19)=AloneVolumeLabel
    begin object name=TimeoutButton class=GUIButton
        Caption="Attempt Timeout"
        StyleName="ServerBrowserGridHeader"
        WinTop=0.910
        WinLeft=0.350
        WinWidth=0.30
        WinHeight=0.070
        OnClick=OnClick
        OnKeyEvent=InternalOnKeyEvent
    object end
    // Reference: GUIButton'Menu_TabMisc.TimeoutButton'
    Controls(20)=TimeoutButton
    begin object name=NecroCheck class=moCheckBox
        Caption="Disable Necromancy"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Disables the Necromancy (resurrect team-mate) adrenaline combo if checked."
        WinTop=0.330
        WinLeft=0.10
        WinWidth=0.380
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.NecroCheck'
    Controls(21)=NecroCheck
    begin object name=NewNetCheck class=moCheckBox
        Caption="Enable Enhanced NetCode"
        OnCreateComponent=InternalOnCreateComponent
        WinTop=0.030
        WinLeft=0.10
        WinWidth=0.80
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.NewNetCheck'
    Controls(22)=NewNetCheck
    begin object name=DamageCheck class=moCheckBox
        Caption="Centered"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Shows numeric damage as centered value when you hit an enemy."
        WinTop=0.560
        WinLeft=0.750
        WinWidth=0.150
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.DamageCheck'
    Controls(23)=DamageCheck
    begin object name=DamageCheck2 class=moCheckBox
        Caption="Floating"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Shows numeric damage as floating near players when you hit an enemy."
        WinTop=0.610
        WinLeft=0.750
        WinWidth=0.150
        OnChange=OnChange
    object end
    // Reference: moCheckBox'Menu_TabMisc.DamageCheck2'
    Controls(24)=DamageCheck2
    begin object name=TeamInfoLabel class=GUILabel
        Caption="Teammate info"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.440
        WinLeft=0.520
        WinWidth=0.210
        bStandardized=true
        StandardHeight=0.030
    object end
    // Reference: GUILabel'Menu_TabMisc.TeamInfoLabel'
    Controls(25)=TeamInfoLabel
    begin object name=DamageLabel class=GUILabel
        Caption="Damage indicator"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.560
        WinLeft=0.520
        WinWidth=0.210
        bStandardized=true
        StandardHeight=0.030
    object end
    // Reference: GUILabel'Menu_TabMisc.DamageLabel'
    Controls(26)=DamageLabel
}