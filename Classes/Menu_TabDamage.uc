class Menu_TabDamage extends UT2k3TabPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local Misc_Player MP;
    local TAM_GRI GRI;

    Super.InitComponent(MyController, MyOwner);

    MP = Misc_Player(PlayerOwner());
    if(MP == None)
        return;
            
            moCheckBox(Controls[23]).StandardHeight = 0.0;
			moCheckBox(Controls[1]).DisableMe();
            moCheckBox(Controls[24]).StandardHeight = 0.0;
			moCheckBox(Controls[2]).DisableMe();
            GUILabel(Controls[26]).StandardHeight = 0.0;
            moCheckBox(Controls[23]).Checked(MP.DamageIndicator == Centered);
            moCheckBox(Controls[24]).Checked(MP.DamageIndicator == Floating);
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
        if(c == Controls[23])
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

    MP.SaveConfig();
}

// Decompiled with UE Explorer.
defaultproperties
{
     Begin Object Class=GUIImage Name=TabBackground
         Image=Texture'InterfaceContent.Menu.ScoreBoxA'
         ImageColor=(B=0,G=0,R=0)
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'3SPNRU-B1.Menu_TabDamage.TabBackground'

    begin object name=DamageCheck class=moCheckBox
        Caption="Centered"
        OnCreateComponent=DamageCheck.InternalOnCreateComponent
        Hint="Shows numeric damage as centered value when you hit an enemy."
        WinTop=0.560
        WinLeft=0.750
        WinWidth=0.150
        OnChange=OnChange
    object end
    Controls(23)=moCheckBox'3SPNRU-B1.Menu_TabDamage.DamageCheck'
    // Reference: moCheckBox'Menu_TabDamage.DamageCheck'

    begin object name=DamageCheck2 class=moCheckBox
        Caption="Floating"
        OnCreateComponent=DamageCheck2.InternalOnCreateComponent
        Hint="Shows numeric damage as floating near players when you hit an enemy."
        WinTop=0.610
        WinLeft=0.750
        WinWidth=0.150
        OnChange=OnChange
    object end
//    Controls(24)=moCheckBox'3SPNRU-B1.Menu_TabDamage.DamageCheck2'
    // Reference: moCheckBox'Menu_TabDamage.DamageCheck2'

    begin object name=DamageLabel class=GUILabel
        Caption="Damage indicator"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.560
        WinLeft=0.520
        WinWidth=0.210
        bStandardized=true
        StandardHeight=0.030
    object end
//    Controls(26)=GUILabel'3SPNRU-B1.Menu_TabDamage.DamageLabel
    // Reference: GUILabel'Menu_TabDamage.DamageLabel'
}