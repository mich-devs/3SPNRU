class Menu_TabDamage extends UT2k3TabPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local Misc_Player MP;
    local TAM_GRI GRI;

    Super.InitComponent(MyController, MyOwner);

    MP = Misc_Player(PlayerOwner());
    if(MP == None)
        return;
		
		if(!GRI.bDamageIndicator && GRI.Level.NetMode != NM_Standalone)
        {
            moCheckBox(Controls[2]).StandardHeight = 0.0;
			moCheckBox(Controls[2]).DisableMe();
            moCheckBox(Controls[3]).StandardHeight = 0.0;
			moCheckBox(Controls[3]).DisableMe();
            GUILabel(Controls[1]).StandardHeight = 0.0;
        }
        else
        {
            moCheckBox(Controls[2]).Checked(MP.DamageIndicator == Centered);
            moCheckBox(Controls[3]).Checked(MP.DamageIndicator == Floating);
        }
}
/*function OnChange(GUIComponent C)
{
    local bool b;
    local Misc_Player MP;
    MP = Misc_Player(PlayerOwner());
    if(MP == None)
        return;

    if(moCheckBox(c) != None)
    {
        b = moCheckBox(c).IsChecked();
        if(c == Controls[2])
        {
            if (b)
            {
                MP.DamageIndicator = Centered;
                class'Misc_Player'.default.DamageIndicator = Centered;
                moCheckBox(Controls[2]).MyCheckBox.bChecked = false;
            }
            else
            {
                MP.DamageIndicator = Disabled;
                class'Misc_Player'.default.DamageIndicator = Disabled;
            moCheckBox(Controls[3]).StandardHeight = 0.0;
			moCheckBox(Controls[3]).DisableMe();
            //GUILabel(Controls[1).StandardHeight = 0.0;
        }
        else
        {
            moCheckBox(Controls[2]).Checked(MP.DamageIndicator == Centered);
            moCheckBox(Controls[3]).Checked(MP.DamageIndicator == Floating);
        }
    }
//    //moCheckBox(Controls[1]).StandardHeight = 0.0;
//	//moCheckBox(Controls[1]).DisableMe();
//   //moCheckBox(Controls[2]).StandardHeight = 0.0;
//	//moCheckBox(Controls[2]).DisableMe();
//    GUILabel(Controls[1]).StandardHeight = 0.0;
//    moCheckBox(Controls[2]).Checked(MP.DamageIndicator == Centered);
//    moCheckBox(Controls[3]).Checked(MP.DamageIndicator == Floating);
//}
*/

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
        if(c == Controls[2])
        {
            if (b)
            {
                MP.DamageIndicator = Centered;
                class'Misc_Player'.default.DamageIndicator = Centered;
                moCheckBox(Controls[2]).MyCheckBox.bChecked = true;
            }
            else
            {
                MP.DamageIndicator = Disabled;
                class'Misc_Player'.default.DamageIndicator = Disabled;
            }
        }                

        else if(c == Controls[3])
        {
            if (b)
            {
                MP.DamageIndicator = Floating;
                class'Misc_Player'.default.DamageIndicator = Floating;
                moCheckBox(Controls[3]).MyCheckBox.bChecked = true;
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

    Begin Object Class=GUILabel Name=DamageLabel 
        Caption="Damage Indicators"
        TextColor=(R=255,G=255,B=255,A=255)
        WinTop=0.040
        WinLeft=0.175
        WinWidth=0.600
        bStandardized=true
        StandardHeight=0.030
    End Object
    Controls(1)=GUILabel'3SPNRU-B1.Menu_TabDamage.DamageLabel'

    Begin Object Class=moCheckBox Name=DamageCheck
        Caption="Enable centered damage numbers."
        OnCreateComponent=DamageCheck.InternalOnCreateComponent
        Hint="Shows numeric damage centered on your screen when you hit an enemy."
        WinTop=0.095
        WinLeft=0.200
        WinWidth=0.600
        OnChange=OnChange
    End Object
    Controls(2)=moCheckBox'3SPNRU-B1.Menu_TabDamage.DamageCheck'

    Begin Object Class=moCheckBox Name=DamageCheck2
        Caption="Enable floating damage numbers."
        OnCreateComponent=DamageCheck2.InternalOnCreateComponent
        Hint="Shows numeric damage floating near players when you hit an enemy."
        WinTop=0.140
        WinLeft=0.200
        WinWidth=0.600
        OnChange=OnChange
    End Object
    Controls(3)=moCheckBox'3SPNRU-B1.Menu_TabDamage.DamageCheck2'
}
