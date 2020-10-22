class Menu_TabDamage extends UT2k3TabPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local Misc_Player MP;
    local TAM_GRI GRI;

    Super.InitComponent(MyController, MyOwner);

    MP = Misc_Player(PlayerOwner());
    if(MP == None)
        return;

    if(GRI.bDamageIndicator)
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
    begin object name=DamageCheck class=moCheckBox
        Caption="Centered"
        OnCreateComponent=DamageCheck.InternalOnCreateComponent
        Hint="Shows numeric damage as centered value when you hit an enemy."
        WinTop=0.560
        WinLeft=0.750
        WinWidth=0.150
        OnChange=OnChange
    object end

    begin object name=DamageCheck2 class=moCheckBox
        Caption="Floating"
        OnCreateComponent=DamageCheck2.InternalOnCreateComponent
        Hint="Shows numeric damage as floating near players when you hit an enemy."
        WinTop=0.610
        WinLeft=0.750
        WinWidth=0.150
        OnChange=OnChange
    object end
}