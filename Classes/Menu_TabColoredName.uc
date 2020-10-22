class Menu_TabColoredName extends UT2k3TabPanel;

var Color LetterColors[20];
var const Color DefaultColor;

var bool bChangesMade;
var bool bColorWasReset;
var bool bShiftPressed;
var bool bGradientMode;
var int  GradientRef;

/* convert percentage color to real - also provide that real color
   can be saved later into a string (won't contain any disallowed characters) */
function Color ColorPerc2Real(Color This)
{
    local Color NewColor;

    NewColor.R = int(This.R * 2.52) + 1;
    if(This.R > 4 && This.R < 10)
        NewColor.R++;

    NewColor.G = int(This.G * 2.52) + 1;
    if(This.G > 4 && This.G < 10)
        NewColor.G++;

    NewColor.B = int(This.B * 2.52) + 1;
    if(This.B > 4 && This.B < 10)
        NewColor.B++;

    NewColor.A = 255;

    return NewColor;
}

function Color ColorReal2Perc(Color This)
{
    local Color NewColor;

    NewColor.R = Clamp(This.R * 0.397, 0, 100);
    NewColor.G = Clamp(This.G * 0.397, 0, 100);
    NewColor.B = Clamp(This.B * 0.397, 0, 100);
    NewColor.A = 255;

    return NewColor;
}

function string Letters2ColoredName()
{
    local string PlayerName;
    local string ColoredName;
    local int i;

    PlayerName = StripColorCodes(PlayerOwner().PlayerReplicationInfo.PlayerName);
    ColoredName = "";

    for(i = 0; i < Len(PlayerName); i++)
        if(i > 0 && LetterColors[i] == LetterColors[i-1])
            ColoredName $= Mid(PlayerName, i, 1);
        else
            ColoredName $= class'GameInfo'.static.MakeColorCode( ColorPerc2Real(LetterColors[i]) ) $ Mid(PlayerName, i, 1);

    return ColoredName;
}

function string ColoredName2Letters(string ColoredName)
{
    local Color CurrentColor;
    local int i, j;
    local string PlayerName;

    CurrentColor = default.DefaultColor;
    j = 0;
    PlayerName = "";

    for(i = 0; i < Len(ColoredName); i++)
    {
        if(Mid(ColoredName, i, 1) == Chr(27) )
        {
            CurrentColor.R = Asc(Mid(ColoredName, i+1, 1));
            CurrentColor.G = Asc(Mid(ColoredName, i+2, 1));
            CurrentColor.B = Asc(Mid(ColoredName, i+3, 1));
            CurrentColor = ColorReal2Perc(CurrentColor);
            i += 3;
            continue;
        }

        PlayerName $= Mid(ColoredName, i, 1);
        LetterColors[j++] = CurrentColor;
    }

    return PlayerName;
}

function MakeGradient(int Start, int End)
{
    local int i;
    local float fPos, fScale;

    if(Start == End)
        return;

    fScale = End - Start;
    for(i = Start; i <= End; i++)
    {
        fPos = float(i - Start) / fScale;
        LetterColors[i].R = Lerp(fPos, LetterColors[Start].R, LetterColors[End].R);
        LetterColors[i].G = Lerp(fPos, LetterColors[Start].G, LetterColors[End].G);
        LetterColors[i].B = Lerp(fPos, LetterColors[Start].B, LetterColors[End].B);
        GUILabel(Controls[i+1]).TextColor = ColorPerc2Real( LetterColors[i] );
    }
}

function ResetColors()
{
    local int i;

    for(i = 0; i < 20; i++)
    {
        LetterColors[i] = DefaultColor;
        GUILabel(Controls[i+1]).TextColor = ColorPerc2Real(DefaultColor);
    }
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);

    ColoredName2Letters( class'PlayerSettings'.static.GetColoredName(PlayerOwner().PlayerReplicationInfo) );

    for(i = 1; i < (Len(PlayerOwner().PlayerReplicationInfo.PlayerName) + 1); i++)
    {
        GUILabel(Controls[i]).WinLeft = (0.50 - (0.50 * 0.030 * Len(PlayerOwner().PlayerReplicationInfo.PlayerName)) + (0.030 * (i-1)));
        GUILabel(Controls[i]).Caption = Mid(PlayerOwner().PlayerReplicationInfo.PlayerName, i-1, 1);
        GUILabel(Controls[i]).TextColor = ColorPerc2Real( LetterColors[i-1] );
    }

    GUISlider(Controls[27]).MinValue = 1;
    GUISlider(Controls[27]).WinLeft = (0.50 - (0.50 * 0.030 * Len(PlayerOwner().PlayerReplicationInfo.PlayerName)));
    GUISlider(Controls[27]).MaxValue = Min((Len(PlayerOwner().PlayerReplicationInfo.PlayerName)), 20);
    GUISlider(Controls[27]).Value = 1;
    GUISlider(Controls[27]).WinWidth = (0.0297 * Min((Len(PlayerOwner().PlayerReplicationInfo.PlayerName)), 20));
    GUISlider(Controls[27]).BarStyle = None;
    GUISlider(Controls[27]).FillImage = None;

    OnChange(Controls[27]);

    bChangesMade = false;
    bShiftPressed = false;
    bGradientMode = false;
    OnKeyEvent = InternalOnKeyEvent;
}

function OnChange(GUIComponent C)
{
    if(C == Controls[21] || C == Controls[22] || C == Controls[23])
    {
        // color changed
        bChangesMade = true;
        bColorWasReset = false;

        LetterColors[GUISlider(Controls[27]).Value - 1].R = GUISlider(Controls[21]).Value;
        LetterColors[GUISlider(Controls[27]).Value - 1].G = GUISlider(Controls[22]).Value;
        LetterColors[GUISlider(Controls[27]).Value - 1].B = GUISlider(Controls[23]).Value;
        GUILabel(Controls[GUISlider(Controls[27]).Value]).TextColor = ColorPerc2Real( LetterColors[GUISlider(Controls[27]).Value - 1] );
    }

    if(C == Controls[27])
    {
        // letter changed
        GUISlider(Controls[21]).Value = LetterColors[GUISlider(Controls[27]).Value - 1].R;
        GUISlider(Controls[22]).Value = LetterColors[GUISlider(Controls[27]).Value - 1].G;
        GUISlider(Controls[23]).Value = LetterColors[GUISlider(Controls[27]).Value - 1].B;
        bGradientMode = bShiftPressed;
    }

    if(!bGradientMode)
    {
        GradientRef = GUISlider(Controls[27]).Value;
        Controls[31].bVisible = false;
    }
    else
    {
        if(C == Controls[21] || C == Controls[22] || C == Controls[23] || C == Controls[27])
            MakeGradient(GradientRef - 1, GUISlider(Controls[27]).Value - 1);
    }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local float p1, p2;

    if(Key == 16)
    {
        if(State == 1)
            bShiftPressed = true;

        if(State == 3)
            bShiftPressed = false;

        if(bShiftPressed)
        {
            p1 = (0.50 - (0.50 * 0.030 * Len(PlayerOwner().PlayerReplicationInfo.PlayerName)) + (0.030 * (GradientRef - 0.8)));
            p2 = (0.50 - (0.50 * 0.030 * Len(PlayerOwner().PlayerReplicationInfo.PlayerName)) + (0.030 * (GUISlider(Controls[27]).Value - 0.2)));

            if(GUISlider(Controls[27]).Value > GradientRef)
            {
                Controls[31].WinLeft = p1;
                Controls[31].WinWidth = p2-p1;
                Controls[31].bVisible = true;
            }
            else
            {
                Controls[31].bVisible = false;
                bShiftPressed = false;
            }
        }
    }

    return false;
}

function bool OnClick(GUIComponent C)
{
    if(C == Controls[27])
        OnChange(C);

    if(C == Controls[30])
    {
        // reset colors
        bChangesMade = true;
        bColorWasReset = true;

        ResetColors();
        GUISlider(Controls[27]).Value = 1;
        OnChange(Controls[27]);
    }

    return true;
}

function Closed(GUIComponent Sender, bool bCancelled)
{
    local string ColoredName;

    Super.Closed(Sender, bCancelled);

    if(!bChangesMade)
        return;

    if(bColorWasReset)
    {
        class'PlayerSettings'.static.DeleteColoredName(PlayerOwner().PlayerReplicationInfo);

        if(Misc_PRI(PlayerOwner().PlayerReplicationInfo) != None)
            Misc_PRI(PlayerOwner().PlayerReplicationInfo).ServerSetColoredName(PlayerOwner().PlayerReplicationInfo.PlayerName);
    }
    else
    {
        ColoredName = Letters2ColoredName();
        class'PlayerSettings'.static.SaveColoredName(PlayerOwner().PlayerReplicationInfo, ColoredName);

        if(Misc_PRI(PlayerOwner().PlayerReplicationInfo) != None)
            Misc_PRI(PlayerOwner().PlayerReplicationInfo).ServerSetColoredName(ColoredName);
    }
}

defaultproperties
{
     DefaultColor=(B=100,G=100,R=100,A=255)
     Begin Object Class=GUIImage Name=TabBackground
         Image=Texture'InterfaceContent.Menu.ScoreBoxA'
         ImageColor=(B=0,G=0,R=0)
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'3SPNv3177AT.Menu_TabColoredName.TabBackground'

     Begin Object Class=GUILabel Name=Label1
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(1)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label1'

     Begin Object Class=GUILabel Name=Label2
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(2)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label2'

     Begin Object Class=GUILabel Name=Label3
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(3)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label3'

     Begin Object Class=GUILabel Name=Label4
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(4)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label4'

     Begin Object Class=GUILabel Name=Label5
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(5)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label5'

     Begin Object Class=GUILabel Name=Label6
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(6)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label6'

     Begin Object Class=GUILabel Name=Label7
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(7)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label7'

     Begin Object Class=GUILabel Name=Label8
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(8)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label8'

     Begin Object Class=GUILabel Name=Label9
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(9)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label9'

     Begin Object Class=GUILabel Name=Label10
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(10)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label10'

     Begin Object Class=GUILabel Name=Label11
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(11)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label11'

     Begin Object Class=GUILabel Name=Label12
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(12)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label12'

     Begin Object Class=GUILabel Name=Label13
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(13)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label13'

     Begin Object Class=GUILabel Name=Label14
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(14)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label14'

     Begin Object Class=GUILabel Name=Label15
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(15)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label15'

     Begin Object Class=GUILabel Name=Label16
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(16)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label16'

     Begin Object Class=GUILabel Name=Label17
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(17)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label17'

     Begin Object Class=GUILabel Name=Label18
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(18)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label18'

     Begin Object Class=GUILabel Name=Label19
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(19)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label19'

     Begin Object Class=GUILabel Name=Label20
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.125000
         WinWidth=0.029000
     End Object
     Controls(20)=GUILabel'3SPNv3177AT.Menu_TabColoredName.Label20'

     Begin Object Class=GUISlider Name=RedSlider
         bIntSlider=True
         WinTop=0.343000
         WinLeft=0.330000
         WinWidth=0.425000
         OnClick=RedSlider.InternalOnClick
         OnMousePressed=RedSlider.InternalOnMousePressed
         OnMouseRelease=RedSlider.InternalOnMouseRelease
         OnChange=Menu_TabColoredName.OnChange
         OnKeyEvent=RedSlider.InternalOnKeyEvent
         OnCapturedMouseMove=RedSlider.InternalCapturedMouseMove
     End Object
     Controls(21)=GUISlider'3SPNv3177AT.Menu_TabColoredName.RedSlider'

     Begin Object Class=GUISlider Name=GreenSlider
         bIntSlider=True
         WinTop=0.415000
         WinLeft=0.330000
         WinWidth=0.425000
         OnClick=GreenSlider.InternalOnClick
         OnMousePressed=GreenSlider.InternalOnMousePressed
         OnMouseRelease=GreenSlider.InternalOnMouseRelease
         OnChange=Menu_TabColoredName.OnChange
         OnKeyEvent=GreenSlider.InternalOnKeyEvent
         OnCapturedMouseMove=GreenSlider.InternalCapturedMouseMove
     End Object
     Controls(22)=GUISlider'3SPNv3177AT.Menu_TabColoredName.GreenSlider'

     Begin Object Class=GUISlider Name=BlueSlider
         bIntSlider=True
         WinTop=0.483000
         WinLeft=0.330000
         WinWidth=0.425000
         OnClick=BlueSlider.InternalOnClick
         OnMousePressed=BlueSlider.InternalOnMousePressed
         OnMouseRelease=BlueSlider.InternalOnMouseRelease
         OnChange=Menu_TabColoredName.OnChange
         OnKeyEvent=BlueSlider.InternalOnKeyEvent
         OnCapturedMouseMove=BlueSlider.InternalCapturedMouseMove
     End Object
     Controls(23)=GUISlider'3SPNv3177AT.Menu_TabColoredName.BlueSlider'

     Begin Object Class=GUILabel Name=RedLabel
         Caption="Red"
         TextColor=(R=255)
         WinTop=0.330000
         WinLeft=0.220000
     End Object
     Controls(24)=GUILabel'3SPNv3177AT.Menu_TabColoredName.RedLabel'

     Begin Object Class=GUILabel Name=GreenLabel
         Caption="Green"
         TextColor=(G=255)
         WinTop=0.400000
         WinLeft=0.220000
     End Object
     Controls(25)=GUILabel'3SPNv3177AT.Menu_TabColoredName.GreenLabel'

     Begin Object Class=GUILabel Name=BlueLabel
         Caption="Blue"
         TextColor=(B=255)
         WinTop=0.470000
         WinLeft=0.220000
     End Object
     Controls(26)=GUILabel'3SPNv3177AT.Menu_TabColoredName.BlueLabel'

     Begin Object Class=GUISlider Name=LetterSlider
         Value=1.000000
         bIntSlider=True
         bShowValueTooltip=False
         WinTop=0.185000
         OnClick=LetterSlider.InternalOnClick
         OnMousePressed=LetterSlider.InternalOnMousePressed
         OnMouseRelease=LetterSlider.InternalOnMouseRelease
         OnChange=Menu_TabColoredName.OnChange
         OnKeyEvent=LetterSlider.InternalOnKeyEvent
         OnCapturedMouseMove=LetterSlider.InternalCapturedMouseMove
     End Object
     Controls(27)=GUISlider'3SPNv3177AT.Menu_TabColoredName.LetterSlider'

     Begin Object Class=GUIImage Name=BackgNameBox
         Image=Texture'InterfaceContent.Menu.ScoreBoxA'
         ImageColor=(A=100)
         ImageStyle=ISTY_Stretched
         WinTop=0.100000
         WinLeft=0.185000
         WinWidth=0.625000
         WinHeight=0.150000
         RenderWeight=1.000000
         bNeverFocus=True
     End Object
     Controls(28)=GUIImage'3SPNv3177AT.Menu_TabColoredName.BackgNameBox'

     Begin Object Class=GUIImage Name=BackgColorBox
         Image=Texture'InterfaceContent.Menu.ScoreBoxA'
         ImageColor=(A=100)
         ImageStyle=ISTY_Stretched
         WinTop=0.300000
         WinLeft=0.185000
         WinWidth=0.625000
         WinHeight=0.260000
         RenderWeight=1.000000
         bNeverFocus=True
     End Object
     Controls(29)=GUIImage'3SPNv3177AT.Menu_TabColoredName.BackgColorBox'

     Begin Object Class=GUIButton Name=ResetColorsButton
         Caption="Reset Colors"
         StyleName="ServerBrowserGridHeader"
         WinTop=0.600000
         WinLeft=0.410000
         WinWidth=0.200000
         WinHeight=0.060000
         OnClick=Menu_TabColoredName.OnClick
         OnKeyEvent=ResetColorsButton.InternalOnKeyEvent
     End Object
     Controls(30)=GUIButton'3SPNv3177AT.Menu_TabColoredName.ResetColorsButton'

     Begin Object Class=GUIImage Name=GradMarker
         Image=Texture'InterfaceContent.Menu.ScoreBoxA'
         ImageColor=(A=100)
         ImageStyle=ISTY_Stretched
         WinTop=0.190000
         WinWidth=0.000000
         WinHeight=0.020000
         RenderWeight=1.000000
         bVisible=False
         bNeverFocus=True
     End Object
     Controls(31)=GUIImage'3SPNv3177AT.Menu_TabColoredName.GradMarker'

     Begin Object Class=GUILabel Name=HelpText
         Caption="To quickly make a color-gradient:||- Select first letter, and set its color|- Hold down SHIFT key while dragging to last letter|- Select your gradient's end color"
         TextColor=(B=255,G=255,R=255,A=200)
         TextFont="UT2SmallFont"
         bMultiLine=True
         WinTop=0.750000
         WinLeft=0.250000
         WinWidth=0.600000
         WinHeight=0.200000
     End Object
     Controls(32)=GUILabel'3SPNv3177AT.Menu_TabColoredName.HelpText'

}
