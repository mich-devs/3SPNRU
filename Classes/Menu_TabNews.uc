class Menu_TabNews extends UT2k3TabPanel;

var array<string> Text;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string Content;

    Super.InitComponent(MyController, MyOwner);
	Content = JoinArray(Text, GUIScrollTextBox(Controls[1]).Separator, true);
	GUIScrollTextBox(Controls[1]).SetContent(Content, GUIScrollTextBox(Controls[1]).Separator);
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
     Controls(0)=GUIImage'3SPNv3177AT.Menu_TabNews.TabBackground'

     Begin Object Class=GUIScrollTextBox Name=TextBoxObj
         bNoTeletype=True
         Separator="`"
         OnCreateComponent=TextBoxObj.InternalOnCreateComponent
         FontScale=FNS_Small
         WinTop=0.010000
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.980000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(1)=GUIScrollTextBox'3SPNv3177AT.Menu_TabNews.TextBoxObj'

}
