class Text_TabNews extends Actor
    Config(3SPNv3177AT);

const LineWrapAt = 48;      // wrap lines (for replication) at
const MaxLineLength = 60;   // max length of last line (don't want to start new line only for few chars)

var config bool bShowText;
var config array<string> Text;
var array<string> TextPrepared;

/* hold data for custom tex-color control sequences */
struct TColorCodes
{
    var string Code;
    var string CodeRepl;
    var string Decode;
};
var const array<TColorCodes> ColorCodes;

/* prepare Text array for replication. */
static function bool PrepareText()
{
    local int i, j;

    default.TextPrepared.Length = 0;
    if (!default.bShowText || (default.Text.Length == 0) )
        return false;

    default.TextPrepared.Length = 1;

    for(i = 0; i < default.Text.Length; i++)
    {
        if(Right(default.Text[i], 1) == "\\")
            default.TextPrepared[j] $= ColorMark2Repl(Left(default.Text[i], Len(default.Text[i])-1) );
        else
            default.TextPrepared[j] $= ColorMark2Repl(default.Text[i]) $ "`";

        while (Len(default.TextPrepared[j]) > MaxLineLength)
        {
            default.TextPrepared[j+1] = Mid(default.TextPrepared[j], LineWrapAt);
            default.TextPrepared[j] = Left(default.TextPrepared[j], LineWrapAt);
            j++;
        }
    }

    if(Left(default.TextPrepared[0], 1) != "`")
        default.TextPrepared[0] = "`" $ default.TextPrepared[0];

    return true;
}

/* reverse operation of PrepareText. */
static function bool UnPrepareText()
{
    local int i, j, p;

    default.Text.Length = 0;
    if (default.TextPrepared.Length == 0)
        return false;

    default.Text.Length = 1;

    for(i = 0; i < default.TextPrepared.Length; i++)
    {
        default.Text[j] $= Repl2Color(default.TextPrepared[i]);

        while(true)
        {
            p = Instr(default.Text[j], "`");
            if(p < 0)
                break;
            default.Text[j+1] = Mid(default.Text[j], p+1);
            if(p == 0)
                default.Text[j] = " ";
            else
                default.Text[j] = Left(default.Text[j], p);
            j++;
        }
    }

    return true;
}

/* switch color codes to corresponding control-chars for replication.
   also removes unreal color code chars (they could screw up on reverse side), and the ` newline marker char. */
static function string ColorMark2Repl(string Text)
{
    local int i, p;

    Text = class'GUIComponent'.static.StripColorCodes(Text);
    ReplaceText(Text, "`", "");

    for(i = 0; i < default.ColorCodes.Length; i++)
        while(true)
        {
            p = InStr(Text, default.ColorCodes[i].Code);
            if(p < 0)
                break;
            Text = Left(Text, p) $ default.ColorCodes[i].CodeRepl $ Mid(Text, p + Len(default.ColorCodes[i].Code) );
        }

    return Text;
}

/* converts our color control-chars to unreal color codes. */
static function string Repl2Color(string Text)
{
    local int i, p;

    for(i = 0; i < default.ColorCodes.Length; i++)
        while(true)
        {
            p = InStr(Text, default.ColorCodes[i].CodeRepl);
            if(p < 0)
                break;
            Text = Left(Text, p) $ default.ColorCodes[i].Decode $ Mid(Text, p + 1);
        }

    return Text;
}

defaultproperties
{
     ColorCodes(0)=(Code="\black\",CodeRepl="",Decode="")
     ColorCodes(1)=(Code="\dkgray\",CodeRepl="",Decode="€€€")
     ColorCodes(2)=(Code="\gray\",CodeRepl="",Decode="ÄÄÄ")
     ColorCodes(3)=(Code="\white\",CodeRepl="",Decode="ÿÿÿ")
     ColorCodes(4)=(Code="\red\",CodeRepl="",Decode="ÿ")
     ColorCodes(5)=(Code="\blue\",CodeRepl="",Decode="@ÿ")
     ColorCodes(6)=(Code="\green\",CodeRepl="",Decode="ÿ")
     ColorCodes(7)=(Code="\yellow\",CodeRepl="",Decode="ÿÿ")
     ColorCodes(8)=(Code="\cyan\",CodeRepl="",Decode="ÿÿ")
     ColorCodes(9)=(Code="\purple\",CodeRepl="",Decode="ÿÿ")
     ColorCodes(10)=(Code="\orange\",CodeRepl="",Decode="ÿ€")
}
