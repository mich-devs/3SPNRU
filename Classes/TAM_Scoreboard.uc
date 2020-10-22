class TAM_Scoreboard extends ScoreBoardTeamDeathMatch;

var int LastUpdateTime;

var const Texture Box;
var const Texture BaseTex;

var const float Scale;
var byte  BaseAlpha;

var const Color SBRedColor, SBBlueColor;

simulated function SetCustomBarColor(out Color C, PlayerReplicationInfo PRI, bool bOwner);
simulated function SetCustomLocationColor(out Color C, PlayerReplicationInfo PRI, bool bOwner);

simulated function UpdateScoreBoard(Canvas C)
{
    local PlayerReplicationInfo PRI, OwnerPRI;
    local float XL, YL;
    local string Specs[6];
    local string SpecsColor[6];
    local string name;
    local int i;
    local byte reds, blues;
    local byte OwnerTeam;
    local bool bDrawnOwner;

    local int BarX;
    local int BarY;
    local int BarW;
    local int BarH;

    local int PlayerBoxX;
    local int PlayerBoxY;
    local int PlayerBoxW;
    local int PlayerBoxH;

    local int MiscX;
    local int MiscY;
    local int MiscW;
    local int MiscH;

    local int NameY;
    local int StatY;
    local int NameW;
    local int NameX;
    local int LocationX;
    local int ScoreX;
    local int DeadX;
    local int PingX;
    // local int BatteryX;
    local int SpecCount;

    local int RedPing;
    local int RedScore;
    local int RedKills;

    local int BluePing;
    local int BlueScore;
    local int BlueKills;
    
    local int CpX;
    local int CpY;
    local float Ratio;
    local int ShiftY;
    local int ShiftTextY;
    
    local int SpecY, MaxSpecs;

    OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
    if(OwnerPRI.Team != None)
        OwnerTeam = OwnerPRI.Team.TeamIndex;
    else
        OwnerTeam = 255;
    
    CpX = C.ClipX;
    CpY = C.ClipY;
    Ratio = float(CpX) / CpY;

    if (Ratio > 2.2)        // ultra-wide
    {
        CpY = CpY * 1.28;
        ShiftY = C.ClipY * 0.12;
        ShiftTextY = C.ClipY * 0.003;
        SpecY = C.ClipY * 0.85;
        MaxSpecs = 4;
    }
    else if (Ratio > 1.7)   // wide
    {
        CpY = CpY * 1.23;
        ShiftY = C.ClipY * 0.08;
        ShiftTextY = C.ClipY * 0.003;
        SpecY = C.ClipY * 0.85;
        MaxSpecs = 4;
    }
    else if (Ratio > 1.5)   // laptop
    {
        CpY = CpY * 1.15;
        ShiftY = C.ClipY * 0.03;
        ShiftTextY = C.ClipY * 0.002;
        SpecY = C.ClipY * 0.85;
        MaxSpecs = 4;
    }
    else                    // std vga
    {
        CpY = CpY * 1.1;
        ShiftY = C.ClipY * 0.03;
        ShiftTextY = 0;
        SpecY = C.ClipY * 0.81;
        MaxSpecs = 6;
    }

    NameY = CpY * 0.0075 * Scale * Scale - ShiftTextY;
    StatY = CpY * 0.035 * Scale - ShiftTextY;
    BarW = CpX * 0.46;
    NameW = CpX * 0.23;
    NameX = CpX * 0.01;
    LocationX = CpX * 0.02;

    ScoreX = CpX * 0.27;
    DeadX = CpX * 0.35;
    PingX = CpX * 0.42;

    PlayerBoxX = CpX * 0.02;
    PlayerBoxW = CpX * 0.46;
    PlayerBoxH = CpY * 0.404;
    BarH = PlayerBoxH / 7.52;

    /* draw header */
    C.Style = ERenderStyle.STY_Alpha;
    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -1);

    // box
    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;

    C.SetPos(0, 0);
    C.DrawTile(BaseTex, CpX, CpY * 0.065, 140, 312, 744, 74);
    C.SetPos(0, CpY * 0.06475);
    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawTile(BaseTex, CpX, CpY * 0.005, 140, 387, 744, 4);

    // text
    name = GRI.GameName$MapName$Level.Title;
    C.StrLen(name, XL, YL);
    //C.SetPos(C.ClipX * 0.5 - XL * 0.5, C.ClipY * 0.02 - YL * 0.5 + 2);
    C.SetPos(CpX * 0.01, CpY * 0.02 - YL * 0.5 + 2);
    C.DrawColor = HUDClass.default.WhiteColor * 0.7;
    C.DrawTextClipped(name);

    name = class'GUIComponent'.static.StripColorCodes(GRI.ServerName);
    C.StrLen(name, XL, YL);
    C.SetPos(CpX * 0.99 - XL, CpY * 0.02 - YL * 0.5 + 2);
    C.DrawTextClipped(name);

    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);

    // text
    if(UnrealPlayer(Owner).bDisplayLoser)
        name = class'HUDBase'.default.YouveLostTheMatch;
    else if(UnrealPlayer(Owner).bDisplayWinner)
        name = class'HUDBase'.default.YouveWonTheMatch;
    else
    {
        name = FragLimit@GRI.GoalScore;
        if(GRI.TimeLimit != 0)
            name = name@spacer@TimeLimit@FormatTime(GRI.RemainingTime);
        else
            name = name@spacer@FooterText@FormatTime(GRI.ElapsedTime);
    }

    C.StrLen(name, XL, YL);
    //C.SetPos(C.ClipX * 0.5 - XL * 0.5, C.ClipY * 0.05 - YL * 0.5 + 1);
    C.SetPos(CpX * 0.01, CpY * 0.05 - YL * 0.5 + 1);
    C.DrawColor = HUDClass.default.RedColor * 0.7;
    C.DrawColor.G = 130;
    C.DrawTextClipped(name);

    // clock
    name = "";
    if(Level.Month < 10)
        name = "0";
    name = name$Level.Month$"/";
    if(Level.Day < 10)
        name = name$"0";
    name = name$Level.Day$"/"$Level.Year@"- ";
    if(Level.Hour < 10)
        name = name$"0";
    name = name$Level.Hour$":";
    if(Level.Minute < 10)
        name = name$"0";
    name = name$Level.Minute$":";
    if(Level.Second < 10)
        name = name$"0";
    name = name$Level.Second;

    C.StrLen(name, XL, YL);
    C.SetPos(CpX * 0.99 - XL, CpY * 0.05 - YL * 0.5 + 1);
    C.DrawTextClipped(name);
    /* draw header */

    /* draw the two team's score bars */
    MiscX = CpX * 0.01;
    MiscY = CpY * 0.191 - ShiftY;
    MiscW = CpX * 0.48;
    MiscH = CpY * 0.040 * scale;

    C.DrawColor = HUDClass.default.RedColor;
    C.DrawColor.A = BaseAlpha;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 73, 772, 50);

    // red team score
    C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -1);
    C.DrawColor = HUDClass.default.WhiteColor * 0.7;
    name = string(int(GRI.Teams[0].Score));
    C.StrLen(name, XL, YL);
    C.SetPos(MiscX + (MiscW * 0.5) - (XL * 0.5), MiscY + (MiscH * 0.6) - (YL * 0.5));
    C.DrawTextClipped(name);

    MiscX = CpX * 0.51;
    C.DrawColor = HUDClass.default.TurqColor;
    C.DrawColor.A = BaseAlpha;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 73, 772, 50);

    // blue team score
    C.DrawColor = HUDClass.default.WhiteColor * 0.7;
    name = string(int(GRI.Teams[1].Score));
    C.StrLen(name, XL, YL);
    C.SetPos(MiscX + (MiscW * 0.5) - (XL * 0.5), MiscY + (MiscH * 0.6) - (YL * 0.5));
    C.DrawTextClipped(name);

    MiscY = CpY * 0.15 - ShiftY;
    /* draw the two team's score bars */

    /* draw the team's backgrounds */
    // draw the top and example bar
    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;

    MiscX = CpX * 0.01;
    MiscY = MiscY + MiscH;
    MiscH = CpY * 0.1183 * scale;
    C.SetPos(MiscX, MiscY);
    // C.DrawTile(BaseTex, MiscW, MiscH, 126, 126, 772, 137);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 128, 772, 137);

    MiscX = CpX * 0.51;
    C.SetPos(MiscX, MiscY);
    // C.DrawTile(BaseTex, MiscW, MiscH, 126, 125, 772, 137);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 128, 772, 137);

    MiscX = CpX * 0.01;
    MiscY = MiscY + MiscH;
    MiscH = CpY * 0.03 * scale;
    MiscW = CpX * 0.0075;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 263, 10, 10);

    MiscX = CpX * 0.51;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 263, 10, 10);

    MiscX = CpX * 0.01 + MiscW;
    MiscW = CpX * 0.48 - (MiscW * 2);
    C.SetPos(MiscX, MiscY);
    C.DrawColor = HUDClass.default.RedColor;
    C.DrawColor.A = BaseAlpha;
    C.DrawTile(BaseTex, MiscW, MiscH, 137, 263, 751, 42);

    C.SetPos(MiscX + MiscW, MiscY);
    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;
    C.DrawTile(BaseTex, CpX * 0.0069, MiscH, 888, 263, 10, 10);

    MiscX = MiscX + CpX * 0.5;
    C.SetPos(MiscX, MiscY);
    C.DrawColor = HUDClass.default.TurqColor;
    C.DrawColor.A = BaseAlpha;
    C.DrawTile(BaseTex, MiscW, MiscH, 137, 263, 751, 42);

    C.SetPos(MiscX + MiscW, MiscY);
    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;
    C.DrawTile(BaseTex, CpX * 0.0069, MiscH, 888, 263, 10, 10);

    MiscX = CpX * 0.01;
    MiscY = MiscY + MiscH;
    MiscH = CpY * 0.005 * scale;
    MiscW = CpX * 0.48;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 306, 772, 4);

    MiscX = CpX * 0.51;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 306, 772, 4);

    PlayerBoxY = (MiscY + MiscH + (CpY * 0.005 * Scale)) - ShiftY;

    MiscX = CpX * 0.01;
    MiscY = MiscY + MiscH;
    MiscH = CpY * 0.005 * scale;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 398, 772, 10);

    MiscX = CpX * 0.51;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 398, 772, 10);
    
    /* draw the player's bars */
    for(i = 0; i < GRI.PRIArray.Length; i++)
    {
        PRI = GRI.PRIArray[i];
        if(PRI.Team == None)
        {
            if(!PRI.bOnlySpectator || SpecCount >= MaxSpecs)
                continue;

            if(PRI.PlayerName ~= "WebAdmin" || PRI.PlayerName ~= "DemoRecSpectator" || Left(PRI.PlayerName, 6) ~= "Player")
                continue;

            Specs[SpecCount] = PRI.PlayerName;
            if(Misc_PRI(PRI) != None)
                SpecsColor[SpecCount] = Misc_PRI(PRI).GetColoredName();
            else
                SpecsColor[SpecCount] = PRI.PlayerName;
            SpecCount++;
            continue;
        }

        if(Level.TimeSeconds - LastUpdateTime > 4)
            Misc_Player(Owner).ServerUpdateStats(TeamPlayerReplicationInfo(PRI));

        if(PRI.Team.TeamIndex == 0)
        {
            if(reds > 6)
                continue;
            if(reds == 6 && OwnerTeam == 0 && !bDrawnOwner && PRI != OwnerPRI)
                continue;

            BarX = PlayerBoxX;
            BarY = PlayerBoxY + (BarH * Reds) + ShiftY;

            C.DrawColor = HUDClass.default.WhiteColor;
            C.DrawColor.A = BaseAlpha;
            C.SetPos(int(CpX * 0.01), BarY);
            C.DrawTile(BaseTex, int(CpX * 0.48), BarH, 126, 398, 772, 10);

            if(PRI == OwnerPRI)
            {
                C.DrawColor.R = 255;
                C.DrawColor.G = 50;
                C.DrawColor.B = 0;
                C.DrawColor.A = BaseAlpha;
            }
            else
            {
                C.DrawColor = HUDClass.default.WhiteColor;
                C.DrawColor.A = BaseAlpha * 0.5;
            }

            RedPing += PRI.Ping;
            RedScore += PRI.Score;
            RedKills += PRI.Kills;

            reds++;
        }
        else
        {
            if(blues > 6)
                continue;
            if(blues == 6 && OwnerTeam == 1 && !bDrawnOwner && PRI != OwnerPRI)
                continue;

            BarX = CpX * 0.50 + PlayerBoxX;
            BarY = PlayerBoxY + (BarH * Blues) + ShiftY;

            C.DrawColor = HUDClass.default.WhiteColor;
            C.DrawColor.A = BaseAlpha;
            C.SetPos(int(CpX * 0.51), BarY);
            C.DrawTile(BaseTex, int(CpX * 0.48), BarH, 126, 398, 772, 10);

            if(PRI == OwnerPRI)
            {
                C.DrawColor.R = 50;
                C.DrawColor.G = 178;
                C.DrawColor.B = 255;
                C.DrawColor.A = BaseAlpha;
            }
            else
            {
                C.DrawColor = HUDClass.default.WhiteColor;
                C.DrawColor.A = BaseAlpha * 0.5;
            }

            BluePing += PRI.Ping;
            BlueScore += PRI.Score;
            BlueKills += PRI.Kills;

            blues++;
        }

        SetCustomBarColor(C.DrawColor, PRI, PRI == OwnerPRI);

        if(PRI == OwnerPRI)
            bDrawnOwner = true;

        C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);

        // draw background
        C.SetPos(BarX, BarY);
        C.DrawTile(BaseTex, BarW, BarH * 0.95, 140, 312, 744, 74);
        C.SetPos(BarX, BarY + BarH * 0.95);
        C.DrawColor = HUDClass.default.WhiteColor;
        C.DrawTile(BaseTex, BarW, BarH * 0.05, 140, 387, 744, 3);

        // name

        C.SetPos(BarX + NameX, BarY + NameY);
        if(PRI.bOutOfLives)
            C.DrawColor = HUDClass.default.WhiteColor * 0.3;
        else
        {
            C.DrawColor = HUDClass.default.WhiteColor * 0.7;
        }

        name = PRI.PlayerName;
        C.StrLen(name, XL, YL);
        if(!PRI.bOutOfLives && Misc_PRI(PRI) != None)
            name = Misc_PRI(PRI).GetColoredName();
        // if(XL > NameW)
        //     name = Left(name, NameW / XL * len(name));
        C.DrawTextClipped(name);

        // score
        C.DrawColor = HUDClass.default.WhiteColor * 0.7;
        name = string(int(PRI.Score));
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + ScoreX - (XL * 0.5), BarY + NameY);
        C.DrawTextClipped(name);

        // kills
        name = string(PRI.Kills);
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + DeadX -(XL * 0.5), BarY + NameY);
        C.DrawTextClipped(name);

        // ping
        C.DrawColor = HUDClass.default.CyanColor * 0.5;
        C.DrawColor.B = 150;
        C.DrawColor.R = 20;
        name = string(Min(999, PRI.Ping * 4));
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + PingX - (XL * 0.5), BarY + NameY);
        C.DrawTextClipped(name);

        C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);
        name = string(PRI.PacketLoss);
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + PingX - (XL * 0.5), BarY + StatY);
        C.DrawTextClipped(name);

        // location (ready/not ready/dead)
        if(!GRI.bMatchHasBegun)
        {
            if(PRI.bReadyToPlay)
                name = ReadyText;
            else
                name = NotReadyText;

            if(PRI.bAdmin)
            {
                name = "Admin -"@name;
                C.DrawColor.R = 170;
                C.DrawColor.G = 20;
                C.DrawColor.B = 20;
            }
            else
            {
                C.DrawColor = HUDClass.default.RedColor * 0.7;
                C.DrawColor.G = 130;
            }
        }
        else
        {
            if(!PRI.bAdmin /*&& !PRI.bOutOfLives*/)
            {
                if(!PRI.bOutOfLives)
                {
                    C.DrawColor = HUDClass.default.RedColor * 0.7;
                    C.DrawColor.G = 130;

                    if(PRI.Team.TeamIndex == OwnerTeam)
                        name = PRI.GetLocationName();
                    else
                        name = PRI.StringUnknown;
                }
                else
                {
                    C.DrawColor.R = 170;
                    C.DrawColor.G = 20;
                    C.DrawColor.B = 20;

                    name = PRI.GetLocationName();
                }

                SetCustomLocationColor(C.DrawColor, PRI, PRI == OwnerPRI);
            }
            else
            {
                C.DrawColor.R = 170;
                C.DrawColor.G = 20;
                C.DrawColor.B = 20;

                //if(PRI.bAdmin)
                    name = "Admin";
                /*else if(PRI.bOutOfLives)
                    name = "Dead";*/
            }
        }
        C.StrLen(name, XL, YL);
        if(XL > NameW)
            name = left(name, NameW / XL * len(name));
        C.SetPos(BarX + LocationX, BarY + StatY);
        C.DrawTextClipped(name);

        // points per round
        C.DrawColor = HUDClass.default.WhiteColor * 0.55;

        if(Misc_BaseGRI(GRI).CurrentRound - Misc_PRI(PRI).JoinRound > 0)
            XL = PRI.Score / (Misc_BaseGRI(GRI).CurrentRound - Misc_PRI(PRI).JoinRound);
        else
            XL = PRI.Score;

        if(int((XL - int(XL)) * 10) < 0)
        {
            if(int(XL) == 0)
                name = "-"$string(int(XL));
            else
                name = string(int(XL));
            name = name$"."$-int((XL - int(XL)) * 10);
        }
        else
        {
            name = string(int(XL));
            name = name$"."$int((XL - int(XL)) * 10);
        }

        C.StrLen(name, XL, YL);
        C.SetPos(BarX + ScoreX - (XL * 0.5), BarY + StatY);
        C.DrawTextClipped(name);

        // draw deaths
        C.DrawColor.R = 170;
        C.DrawColor.G = 20;
        C.DrawColor.B = 20;
        name = string(int(PRI.Deaths));
        C.StrLen(name, xl, yl);
        C.SetPos(BarX + DeadX - (XL * 0.5), BarY + StatY);
        C.DrawTextClipped(name);
    }

    C.DrawColor = HUDClass.default.WhiteColor;

    if(Reds > 0)
    {
        RedPing /= Reds;

        // draw team totals
        if(Reds >= 2)
        {
            BarX = PlayerBoxX;
            BarY = PlayerBoxY + (BarH * Reds) + ShiftY;

            C.DrawColor = HUDClass.default.WhiteColor;
            C.DrawColor.A = BaseAlpha;
            C.SetPos(int(CpX * 0.01), BarY);
            C.DrawTile(BaseTex, int(CpX * 0.48), BarH * 0.6, 126, 398, 772, 10);

            // draw background
            C.DrawColor.R = 255;
            C.DrawColor.G = 50;
            C.DrawColor.B = 0;
            C.DrawColor.A = BaseAlpha * 0.75;

            C.SetPos(BarX, BarY);
            C.DrawTile(BaseTex, BarW, BarH * 0.55, 140, 312, 744, 74);
            C.SetPos(BarX, BarY + BarH * 0.55);
            C.DrawColor = HUDClass.default.WhiteColor;
            C.DrawTile(BaseTex, BarW, BarH * 0.05, 140, 387, 744, 3);

            C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);

            C.DrawColor = HUDClass.default.WhiteColor * 0.7;

            // "Red Team"
            C.SetPos(BarX + NameX, BarY + NameY * 0.7);
            C.DrawTextClipped("Red Team");

            // score
            name = string(RedScore);
            C.StrLen(name, XL, YL);
            C.SetPos(BarX + ScoreX - XL * 0.5, BarY + NameY * 0.7);
            C.DrawTextClipped(name);

            // kills
            name = string(RedKills);
            C.StrLen(name, XL, YL);
            C.SetPos(BarX + DeadX - XL * 0.5, BarY + NameY * 0.7);
            C.DrawTextClipped(name);

            // ping
            C.DrawColor = HUDClass.default.CyanColor * 0.5;
            C.DrawColor.B = 150;
            C.DrawColor.R = 20;

            name = string(Min(999, RedPing * 4));
            C.StrLen(name, XL, YL);
            C.SetPos(BarX + PingX - XL * 0.5, BarY + NameY * 0.7);
            C.DrawTextClipped(name);
        }
    }
    if(Blues > 0)
    {
        BluePing /= Blues;

        // draw team totals
        if(Blues >= 2)
        {
            BarX = PlayerBoxX + (CpX * 0.5);
            BarY = PlayerBoxY + (BarH * Blues) + ShiftY;

            C.DrawColor = HUDClass.default.WhiteColor;
            C.DrawColor.A = BaseAlpha;
            C.SetPos(int(CpX * 0.51), BarY);
            C.DrawTile(BaseTex, int(CpX * 0.48), BarH * 0.6, 126, 398, 772, 10);

            // draw background
            C.DrawColor.R = 50;
            C.DrawColor.G = 178;
            C.DrawColor.B = 255;
            C.DrawColor.A = BaseAlpha * 0.75;

            C.SetPos(BarX, BarY);
            C.DrawTile(BaseTex, BarW, BarH * 0.55, 140, 312, 744, 74);
            C.SetPos(BarX, BarY + BarH * 0.55);
            C.DrawColor = HUDClass.default.WhiteColor;
            C.DrawTile(BaseTex, BarW, BarH * 0.05, 140, 387, 744, 3);

            C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);

            C.DrawColor = HUDClass.default.WhiteColor * 0.7;

            // "Red Team"
            C.SetPos(BarX + NameX, BarY + NameY * 0.7);
            C.DrawTextClipped("Blue Team");

            // score
            name = string(BlueScore);
            C.StrLen(name, XL, YL);
            C.SetPos(BarX + ScoreX - XL * 0.5, BarY + NameY * 0.7);
            C.DrawTextClipped(name);

            // kills
            name = string(BlueKills);
            C.StrLen(name, XL, YL);
            C.SetPos(BarX + DeadX - XL * 0.5, BarY + NameY * 0.7);
            C.DrawTextClipped(name);

            // ping
            C.DrawColor = HUDClass.default.CyanColor * 0.5;
            C.DrawColor.B = 150;
            C.DrawColor.R = 20;

            name = string(Min(999, BluePing * 4));
            C.StrLen(name, XL, YL);
            C.SetPos(BarX + PingX - XL * 0.5, BarY + NameY * 0.7);
            C.DrawTextClipped(name);
        }
    }

    C.DrawColor = HUDClass.default.WhiteColor;
    C.DrawColor.A = BaseAlpha;
    MiscX = CpX * 0.01;
    MiscY = PlayerBoxY + (BarH * Reds) + ShiftY;
    if(Reds > 1)
        MiscY += BarH * 0.6;

    MiscH = CpY * 0.0633 * Scale;
    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 829, 772, 68);

    MiscX = CpX * 0.51;
    MiscY = PlayerBoxY + (BarH * Blues) + ShiftY;
    if(Blues > 1)
        MiscY += BarH * 0.6;

    C.SetPos(MiscX, MiscY);
    C.DrawTile(BaseTex, MiscW, MiscH, 126, 829, 772, 68);
    /* draw the player's bars */

    /* example bar text */
    for(i = 0; i < 2; i++)
    {
        if(i == 0)
            BarX = CpX * 0.02;
        else
            BarX = CpX * 0.52;
        BarY = CpY * 0.26 * Scale - ShiftY;

        C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -2);

        // name
        C.DrawColor = HUDClass.default.WhiteColor * 0.7;
        C.SetPos(BarX + NameX, BarY + NameY);
        C.DrawTextClipped("Name", true);

        // score
        name = "Score";
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + ScoreX - (XL * 0.5), BarY + NameY);
        C.DrawTextClipped(name, true);

        // kills
        name = "Kills";
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + DeadX -(XL * 0.5), BarY + NameY);
        C.DrawTextClipped(name, true);

        // ping
        C.DrawColor = HUDClass.default.CyanColor * 0.5;
        C.DrawColor.B = 150;
        C.DrawColor.R = 20;
        name = "Ping";
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + PingX - (XL * 0.5), BarY + NameY);
        C.DrawTextClipped(name, true);

        C.Font = PlayerController(Owner).MyHUD.GetFontSizeIndex(C, -3);
        name = "P/L";
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + PingX - (XL * 0.5), BarY + StatY);
        C.DrawTextClipped(name, true);

        // location (ready/not ready/dead)
        C.DrawColor = HUDClass.default.RedColor * 0.7;
        C.DrawColor.G = 130;
        name = "Location";
        C.SetPos(BarX + LocationX, BarY + StatY);
        C.DrawTextClipped(name, true);

        // points per round
        C.DrawColor = HUDClass.default.WhiteColor * 0.55;
        name = "PPR";
        C.StrLen(name, XL, YL);
        C.SetPos(BarX + ScoreX - (XL * 0.5), BarY + StatY);
        C.DrawTextClipped(name, true);

        // draw deaths
        C.DrawColor.R = 170;
        C.DrawColor.G = 20;
        C.DrawColor.B = 20;
        name = "Deaths";
        C.StrLen(name, xl, yl);
        C.SetPos(BarX + DeadX - (XL * 0.5), BarY + StatY);
        C.DrawTextClipped(name, true);
    }
    /* example bar text */

    /* spec list */
    if(SpecCount > 0)
    {
        MiscX = CpX * 0.8;
        MiscY = SpecY;
        MiscW = CpX * 0.18;
        MiscH = CpY * 0.155 / 7 * (SpecCount + 1);

        C.StrLen("Testy", XL, YL);
        NameY = CpY * 0.155 / 7 * 0.6 - (YL * 0.5);

        C.DrawColor = HUDClass.default.WhiteColor * 0.15;
        C.DrawColor.A = BaseAlpha;
        C.SetPos(MiscX, MiscY);
        C.DrawRect(Box, MiscW, MiscH);

        C.DrawColor = HUDClass.default.WhiteColor * 0.4;
        C.SetPos(MiscX, MiscY);
        C.DrawRect(Box, MiscW, 1);
        C.SetPos(MiscX, MiscY);
        C.DrawRect(Box, 1, MiscH);
        C.SetPos(MiscX + MiscW, MiscY);
        C.DrawRect(Box, 1, MiscH);
        C.SetPos(MiscX, MiscY + MiscH);
        C.DrawRect(Box, MiscW + 1, 1);

        C.DrawColor = HUDClass.default.WhiteColor * 0.7;
        C.SetPos(MiscX + NameX, MiscY + NameY);
        C.DrawTextClipped("Spectators");

        C.DrawColor = HUDClass.default.RedColor * 0.7;
        C.DrawColor.G = 130;
        for(i = 0; i < SpecCount; i++)
        {
            name = specs[i];
			C.StrLen(name, XL, YL);
            name = SpecsColor[i];
			// if(XL > MiscW - (NameX * 4))
		    //     name = Left(name, (MiscW - (NameX * 4)) / XL * len(name));
            C.SetPos(MiscX + NameX * 2, MiscY + (CpY * 0.16 / 7 * (i + 1)) + NameY);
            C.DrawTextClipped(name);
        }
    }
    /* spec list */

    if(Level.TimeSeconds - LastUpdateTime > 4)
		LastUpdateTime = Level.TimeSeconds;

    bDisplayMessages = true;
}

defaultproperties
{
     Box=Texture'Engine.WhiteSquareTexture'
     BaseTex=Texture'3SPNv3177AT.textures.ScoreBoard'
     Scale=0.900000
     BaseAlpha=150
     SBRedColor=(B=150,G=160,R=255,A=255)
     SBBlueColor=(B=255,G=200,R=140,A=255)
}
