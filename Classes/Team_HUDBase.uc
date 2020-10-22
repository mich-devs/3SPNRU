class Team_HUDBase extends HudCTeamDeathmatch
    abstract;

//#exec TEXTURE IMPORT NAME=CHair FILE=Textures\CHair.tga     GROUP=Textures MIPS=On ALPHA=1 DXT=5
#exec OBJ LOAD FILE=../3SPNv3177AT/Media/Texture1.utx PACKAGE=3SPNv3177AT

var Texture TeamTex;
var Material TrackedPlayer;
var int OldRoundTime;
var Misc_Player myOwner;

var const Color FullHealthColor;
var const Color NameColor;
var const Color LocationColor;
var const Color AdrenColor;
var const Color NoInfoColor;

// colored names related ->
simulated function DrawHudPassC (Canvas C)
{
	local VoiceChatRoom VCR;
	local float PortraitWidth,PortraitHeight, X, Y, XL, YL, Abbrev, SmallH, NameWidth;
	local string PortraitString;

	// portrait
	if ( (bShowPortrait || (bShowPortraitVC && Level.TimeSeconds - LastPlayerIDTalkingTime < 2.0)) && (Portrait != None) )
	{
		PortraitWidth = 0.125 * C.ClipY;
		PortraitHeight = 1.5 * PortraitWidth;
		C.DrawColor = WhiteColor;

		C.SetPos(-PortraitWidth*PortraitX + 0.025*PortraitWidth,0.5*(C.ClipY-PortraitHeight) + 0.025*PortraitHeight);
		C.DrawTile( Portrait, PortraitWidth, PortraitHeight, 0, 0, 256, 384);

		C.SetPos(-PortraitWidth*PortraitX,0.5*(C.ClipY-PortraitHeight));
		C.Font = GetFontSizeIndex(C,-2);

		if ( PortraitPRI != None )
		{
			PortraitString = PortraitPRI.PlayerName;
			C.StrLen(PortraitString,XL,YL);
			if ( XL > PortraitWidth )
			{
				C.Font = GetFontSizeIndex(C,-4);
				C.StrLen(PortraitString,XL,YL);
				if ( XL > PortraitWidth )
				{
					Abbrev = float(len(PortraitString)) * PortraitWidth/XL;
					PortraitString = left(PortraitString,Abbrev);
					C.StrLen(PortraitString,XL,YL);
				}
			}
		}
		C.DrawColor = C.static.MakeColor(160,160,160);
		C.SetPos(-PortraitWidth*PortraitX + 0.025*PortraitWidth,0.5*(C.ClipY-PortraitHeight) + 0.025*PortraitHeight);
		C.DrawTile( Material'XGameShaders.ModuNoise', PortraitWidth, PortraitHeight, 0.0, 0.0, 512, 512 );

		C.DrawColor = WhiteColor;
		C.SetPos(-PortraitWidth*PortraitX,0.5*(C.ClipY-PortraitHeight));
		C.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxA1', 1.05 * PortraitWidth, 1.05*PortraitHeight);

		C.DrawColor = WhiteColor;

		X = C.ClipY/256-PortraitWidth*PortraitX;
		Y = 0.5*(C.ClipY+PortraitHeight) + 0.06*PortraitHeight;
		C.SetPos( X + 0.5 * (PortraitWidth - XL), Y );

		if ( PortraitPRI != None )
		{
			if ( PortraitPRI.Team != None )
			{
				if ( PortraitPRI.Team.TeamIndex == 0 )
					C.DrawColor = RedColor;
				else
					C.DrawColor = TurqColor;
			}

			C.DrawText(PortraitString,true);

			if ( Level.TimeSeconds - LastPlayerIDTalkingTime < 2.0
				&& PortraitPRI.ActiveChannel != -1
				&& PlayerOwner.VoiceReplicationInfo != None )
			{
				VCR = PlayerOwner.VoiceReplicationInfo.GetChannelAt(PortraitPRI.ActiveChannel);
				if ( VCR != None )
				{
					PortraitString = "(" @ VCR.GetTitle() @ ")";
					C.StrLen( PortraitString, XL, YL );
					if ( PortraitX == 0 )
						C.SetPos( Max(0, X + 0.5 * (PortraitWidth - XL)), Y + YL );
					else C.SetPos( X + 0.5 * (PortraitWidth - XL), Y + YL );
					C.DrawText( PortraitString );
				}
			}
		}
	}

    if( bShowWeaponInfo && (PawnOwner != None) && (PawnOwner.Weapon != None) )
		PawnOwner.Weapon.NewDrawWeaponInfo(C, 0.86 * C.ClipY);

	if ( (PawnOwner != PlayerOwner.Pawn) && (PawnOwner != None)
		&& (PawnOwner.PlayerReplicationInfo != None) )
	{
		// draw viewed player name
	    C.Font = GetMediumFontFor(C);
        C.SetDrawColor(255,255,0,255);
		C.StrLen(PawnOwner.PlayerReplicationInfo.PlayerName,NameWidth,SmallH);
		NameWidth = FMax(NameWidth, 0.15 * C.ClipX);
		if ( C.ClipX >= 640 )
		{
			C.Font = GetConsoleFont(C);
			C.StrLen("W",XL,SmallH);
			C.SetPos(79*C.ClipX/80 - NameWidth,C.ClipY * 0.68);
			C.DrawText(NowViewing,false);
		}

        C.Font = GetMediumFontFor(C);
        C.SetPos(79*C.ClipX/80 - NameWidth,C.ClipY * 0.68 + SmallH);
        C.DrawTextClipped(Misc_PRI(PawnOwner.PlayerReplicationInfo).GetColoredName(), false);
	}

    DrawCrosshair(C);
    ShowTeamScorePassC(C);
}

function DisplayEnemyName(Canvas C, PlayerReplicationInfo PRI)
{
	PlayerOwner.ReceiveLocalizedMessage(class'ColoredNameMessage', 0, PRI);
}

// i need this because DrawText don't let me fade texts with color codes
simulated function DrawColoredText(Canvas C, string Text)
{
    local int i;
    local float CX, CY, XL, YL;
    local Color OrigColor;
    local string s;

    CX = C.CurX;
    CY = C.CurY;
    OrigColor = C.DrawColor;

    while(Text != "")
    {
        i = InStr(Text, "");
        if(i >= 0)
        {
            if(i > 0)
            {
                s = Left(Text, i);
                C.DrawTextClipped(s, false);
                C.StrLen(s, XL, YL);
                CX += XL;
                C.SetPos(CX, CY);
            }

            C.DrawColor.R = Asc(Mid(Text, i + 1));
            if(C.DrawColor.R == 27)     // 2xESC gives back original drawcolor
            {
                C.DrawColor = OrigColor;
                Text = Mid(Text, i + 2);
            }
            else
            {
                C.DrawColor.G = Asc(Mid(Text, i + 2));
                C.DrawColor.B = Asc(Mid(Text, i + 3));
                Text = Mid(Text, i + 4);
            }
        }
        else
        {
            C.DrawTextClipped(Text, false);
            break;
        }
    }
}

simulated function DrawMessage(Canvas C, int i, float PosX, float PosY, out float DX, out float DY)
{
    local float FadeValue;
    local float ScreenX, ScreenY;

	if ( !LocalMessages[i].Message.default.bFadeMessage )
		C.DrawColor = LocalMessages[i].DrawColor;
	else
	{
		FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
		C.DrawColor = LocalMessages[i].DrawColor;
		C.DrawColor.A = LocalMessages[i].DrawColor.A * (FadeValue/LocalMessages[i].LifeTime);
	}

	C.Font = LocalMessages[i].StringFont;
	GetScreenCoords( PosX, PosY, ScreenX, ScreenY, LocalMessages[i], C );
	C.SetPos( ScreenX, ScreenY );
	DX = LocalMessages[i].DX / C.ClipX;
    DY = LocalMessages[i].DY / C.ClipY;

	if ( LocalMessages[i].Message.default.bComplexString )
	{
		LocalMessages[i].Message.static.RenderComplexMessage( C, LocalMessages[i].DX, LocalMessages[i].DY,
			LocalMessages[i].StringMessage, LocalMessages[i].Switch, LocalMessages[i].RelatedPRI,
			LocalMessages[i].RelatedPRI2, LocalMessages[i].OptionalObject );
	}
	else
	{
        if(InStr(LocalMessages[i].StringMessage, "") >= 0)
            DrawColoredText(C, LocalMessages[i].StringMessage);
        else
            C.DrawTextClipped(LocalMessages[i].StringMessage, false);
	}

    LocalMessages[i].Drawn = true;
}

simulated function string GetColoredMessage(PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
    if (MsgType == 'Say')
    {
        if(PRI.Team == None)
            return class'DMStatsScreen'.static.MakeColorCode(class'Misc_DeathMessage'.default.TextColor) $ Misc_PRI(PRI).GetColoredName() $ class'DMStatsScreen'.static.MakeColorCode(class'Misc_DeathMessage'.default.TextColor) $ ": "$Msg;
        if(PRI.Team.TeamIndex == 0)
            return class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.RedTeamColor) $ Misc_PRI(PRI).GetColoredName() $ class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.RedTeamColor) $ ": "$Msg;
        if(PRI.Team.TeamIndex == 1)
            return class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.BlueTeamColor) $ Misc_PRI(PRI).GetColoredName() $ class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.BlueTeamColor) $ ": "$Msg;
    }

    if (MsgType == 'TeamSay')
        return class'DMStatsScreen'.static.MakeColorCode(class'TeamSayMessagePlus'.default.DrawColor) $ Misc_PRI(PRI).GetColoredName() $ class'DMStatsScreen'.static.MakeColorCode(class'TeamSayMessagePlus'.default.DrawColor) $ ": "$Msg;
}

simulated function Message(PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
    if(MsgType == 'Say' || MsgType == 'TeamSay')
    {
        if (class'HUD'.default.bMessageBeep)
            PlayerOwner.PlayBeepSound();

        AddTextMessage(GetColoredMessage(PRI, Msg, MsgType), class'LocalMessage', PRI);
        return;
    }

    Super.Message(PRI, Msg, MsgType);
}
// <- colored names related

// for class'Message_PlayerKilled' OBSOLETE
static function IntBox GetWeaponTexCoords(int WeaponNum)
{
    return default.BarWeaponIcon[WeaponNum].TextureCoords;
}

exec function ShowStats()
{
	bShowLocalStats = !bShowLocalStats;
    Misc_Player(PlayerOwner).bFirstOpen = bShowLocalStats;
}

simulated function CalculateEnergy()
{
	if ( PawnOwner.Controller == None )
	{
		CurEnergy = Clamp(PlayerOwner.Adrenaline, 0, 999);
        MaxEnergy = FMax(100, CurEnergy);
	}
	else
	{
		CurEnergy = Clamp(PawnOwner.Controller.Adrenaline, 0, 999);
        MaxEnergy = FMax(100, CurEnergy);
	}
}

function Draw2DLocationDot(Canvas C, vector Loc, float OffsetX, float OffsetY, float ScaleX, float ScaleY)
{
	local rotator Dir;
	local float Angle, Scaling, Dist, DistZ;
	local Actor Start;

	if(PlayerOwner.Pawn == None)
    {
        if(PlayerOwner.ViewTarget != None)
            Start = PlayerOwner.ViewTarget;
        else
		    Start = PlayerOwner;
    }
	else
		Start = PlayerOwner.Pawn;

	Dir = rotator(Loc - Start.Location);
	DistZ = (Loc.Z - Start.Location.Z) / 500.0;
    Loc.Z = Start.Location.Z;
	Dist = FMin(VSize(Loc - Start.Location) / 2000.0, 1.0) ** 0.5 + 0.15;
	Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2832 / 65536;

	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(OffsetX * C.ClipX + ScaleX * C.ClipX * sin(Angle) * Dist,
			OffsetY * C.ClipY - ScaleY * C.ClipY * cos(Angle) * Dist);
    C.DrawColor.R = C.DrawColor.R * (1 - FClamp(DistZ, 0.0, 1.0));
    C.DrawColor.G = C.DrawColor.G * (1 - FClamp(Abs(DistZ), 0.0, 0.3));
    C.DrawColor.B = C.DrawColor.B * (1 + FClamp(DistZ, -1.0, 0.0));

	Scaling = 24 * C.ClipX * (0.45 * HUDScale) / 1600;

	C.DrawTile(LocationDot, Scaling, Scaling, 340, 432, 78, 78);
}

simulated function bool ShouldDrawPlayer(Misc_PRI PRI)
{
    if(PRI == None || PRI.bOutOfLives || PRI.Team == None || PRI == PlayerOwner.PlayerReplicationInfo)
        return false;
    return true;
}

simulated function DrawPlayers(Canvas C)
{
    local int i;
    local int Team;
    local float xl;
    local float yl;
    local float MaxNamePos;
    local int posx;
    local int posy;
    local float scale;
    local string name;
    local int listy;
    local int space;
    local int namey;
    local int namex;
    local int height;
    local int width;

    local int health;
    local int starthealth;

    local int allies;
    local int enemies;

    local Misc_PRI PRI;

    if(myOwner == None)
        return;

    if(PlayerOwner.PlayerReplicationInfo.Team != None)
        Team = PlayerOwner.GetTeamNum();
    else
    {
        if(Pawn(PlayerOwner.ViewTarget) == None || Pawn(PlayerOwner.ViewTarget).GetTeamNum() == 255)
            return;
        Team = Pawn(PlayerOwner.ViewTarget).GetTeamNum();
    }

    listy = 0.08 * HUDScale * C.ClipY;
    space = 0.005 * HUDScale * C.ClipY;
    scale = FMax(HUDScale, 0.75);
    height = C.ClipY * 0.0255 * Scale;
    width = C.ClipX * 0.13 * Scale;
    namex = C.ClipX * 0.025 * Scale;
    MaxNamePos = 0.99 * (width - namex);
    C.Font = GetFontSizeIndex(C, -3 + int(Scale * 1.25));
    C.StrLen("Test", xl, yl);
    namey = (height * 0.6) - (yl * 0.5);

    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);
        if(!ShouldDrawPlayer(PRI))
            continue;

        if(!myOwner.bShowTeamInfo)
            continue;

        if (PRI.PawnReplicationInfo == None)
            continue;

        if(PRI.Team.TeamIndex == Team)
        {
            if(allies > 9)
                continue;

            posy = listy + ((height + space) * allies);
            posx = C.ClipX * 0.01;

            // draw background
            C.SetPos(posx, posy);
            C.DrawColor = default.BlackColor;
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw disc
            C.SetPos(posx, posy);
            C.DrawColor = default.WhiteColor;
            C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

            // draw name
            name = PRI.PlayerName;
            C.StrLen(name, xl, yl);
            name = PRI.GetColoredName();
            // if(xl > MaxNamePos)
            //     name = left(name, MaxNamePos / xl * len(name));
            C.DrawColor = NameColor;
            C.SetPos(posx + namex, posy + namey);
            C.DrawTextClipped(name);

            // draw health dot
            health = PRI.PawnReplicationInfo.Health + PRI.PawnReplicationInfo.Shield;
            if(TAM_TeamInfo(PRI.Team) != None)
                starthealth = TAM_TeamInfo(PRI.Team).StartingHealth;
            else if(TAM_TeamInfoRed(PRI.Team) != None)
                starthealth = TAM_TeamInfoRed(PRI.Team).StartingHealth;
            else if(TAM_TeamInfoBlue(PRI.Team) != None)
                starthealth = TAM_TeamInfoBlue(PRI.Team).StartingHealth;
            else
                starthealth = 200;

            if(health < starthealth)
            {
                C.DrawColor.B = 0;

                C.DrawColor.R = Min(255, (511 * (float(StartHealth - Health) / float(StartHealth))));

                if(C.DrawColor.R == 255)
				    C.DrawColor.G = Min(255, (511 * (float(Health) / float(StartHealth))));
                else
                    C.DrawColor.G = 255;
            }
            else
                C.DrawColor = FullHealthColor;

            C.SetPos(posx + (0.0022 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
            C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

            // draw location dot
            C.DrawColor = WhiteColor;
            Draw2DLocationDot(C, PRI.PawnReplicationInfo.Position, (posx / C.ClipX) + (0.006 * Scale), (posy / C.ClipY) + (0.008 * Scale), 0.008 * Scale, 0.01 * Scale);

            // friends shown
            allies++;
        }
        else
        {
            if(enemies > 9)
                continue;

            posy = listy + ((height + space) * enemies);
            posx = C.ClipX * 0.99;

            // draw background
            C.SetPos(posx - width, posy);
            C.DrawColor = default.BlackColor;
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw disc
            C.SetPos(posx - (C.ClipX * 0.0195 * Scale), posy);
            C.DrawColor = default.WhiteColor;
            C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

            // draw name
            name = PRI.PlayerName;
            C.StrLen(name, xl, yl);
            name = PRI.GetColoredName();
            // if(xl > MaxNamePos)
            // {
            //     name = left(name, MaxNamePos / xl * len(name));
            //     C.StrLen(name, xl, yl);
            // }
            C.DrawColor = NameColor;
            C.SetPos(posx - xl - namex, posy + namey);
            C.DrawTextClipped(name);

            if (Misc_BaseGRI(PlayerOwner.GameReplicationInfo).bSpectateAll)
            {
                // draw health dot
                health = PRI.PawnReplicationInfo.Health + PRI.PawnReplicationInfo.Shield;
                if(TAM_TeamInfo(PRI.Team) != None)
                    starthealth = TAM_TeamInfo(PRI.Team).StartingHealth;
                else if(TAM_TeamInfoRed(PRI.Team) != None)
                    starthealth = TAM_TeamInfoRed(PRI.Team).StartingHealth;
                else if(TAM_TeamInfoBlue(PRI.Team) != None)
                    starthealth = TAM_TeamInfoBlue(PRI.Team).StartingHealth;
                else
                    starthealth = 200;

                if(health < starthealth)
                {
                    C.DrawColor.B = 0;

                    C.DrawColor.R = Min(255, (511 * (float(StartHealth - Health) / float(StartHealth))));

                    if(C.DrawColor.R == 255)
                        C.DrawColor.G = Min(255, (511 * (float(Health) / float(StartHealth))));
                    else
                        C.DrawColor.G = 255;
                }
                else
                    C.DrawColor = FullHealthColor;

                C.SetPos(posx - (0.0165 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
                C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

                // draw location dot
                C.DrawColor = WhiteColor;
                Draw2DLocationDot(C, PRI.PawnReplicationInfo.Position, (posx * 0.987 / C.ClipX) + (0.006 * Scale), (posy / C.ClipY) + (0.008 * Scale), 0.008 * Scale, 0.01 * Scale);
            }
            else
            {
                // draw health dot
                C.DrawColor = NoInfoColor;
                C.SetPos(posx - (0.0165 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
                C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);
            }

            // enemies shown
            enemies++;
        }
    }
}

simulated function DrawPlayersExtended(Canvas C)
{
    local int i;
    local int Team;
    local float xl;
    local float yl;
    local float MaxNamePos;
    local int posx;
    local int posy;
    local float scale;
    local string name;
    local int listy;
    local int space;
    local int namey;
    local int namex;
    local int height;
    local int width;
    local Misc_PRI pri;
    local int health;
    local int starthealth;

    local int allies;
    local int enemies;

    if(myOwner == None)
        return;

    if(PlayerOwner.PlayerReplicationInfo.Team != None)
        Team = PlayerOwner.GetTeamNum();
    else
    {
        if(Pawn(PlayerOwner.ViewTarget) == None || Pawn(PlayerOwner.ViewTarget).GetTeamNum() == 255)
            return;
        Team = Pawn(PlayerOwner.ViewTarget).GetTeamNum();
    }

    listy = 0.08 * HUDScale * C.ClipY;
    scale = 0.75;
    height = C.ClipY * 0.02;
    space = height + (0.0075 * C.ClipY);
    namex = C.ClipX * 0.02;

    C.Font = GetFontSizeIndex(C, -3);
    C.StrLen("Test", xl, yl);
    namey = (height * 0.6) - (yl * 0.5);

    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);
        if(!ShouldDrawPlayer(PRI))
            continue;

        if(!myOwner.bShowTeamInfo)
            continue;

        if (PRI.PawnReplicationInfo == None)
            continue;

        if(PRI.Team.TeamIndex == Team)
        {
            if(allies > 9)
                continue;

            space = height + (0.0075 * C.ClipY);
            width = C.ClipX * 0.18;
            MaxNamePos = 0.67 * (width - namex);

            posy = listy + ((height + space) * allies);
            posx = C.ClipX * 0.01;

            // draw backgrounds
            C.DrawColor = default.BlackColor;
            C.DrawColor.A = 100;
            C.SetPos(posx, posy);
            C.DrawTile(TeamTex, width + posx, height, 168, 211, 166, 44);
            C.SetPos(posx, posy + height * 1.1);
            C.DrawTile(TeamTex, width + posx, height, 168, 211, 166, 44);

            // draw disc
            C.SetPos(posx, posy);
            C.DrawColor = default.WhiteColor;
            C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

            // draw name
            name = PRI.PlayerName;
            C.StrLen(name, xl, yl);
            name = PRI.GetColoredName();
            // if(xl > MaxNamePos)
            //     name = left(name, MaxNamePos / xl * len(name));
            C.DrawColor = NameColor;
            C.SetPos(posx + namex, posy + namey);
            C.DrawTextClipped(name);

            // draw health dot
            health = PRI.PawnReplicationInfo.Health + PRI.PawnReplicationInfo.Shield;
            if(TAM_TeamInfo(PRI.Team) != None)
                starthealth = TAM_TeamInfo(PRI.Team).StartingHealth;
            else if(TAM_TeamInfoRed(PRI.Team) != None)
                starthealth = TAM_TeamInfoRed(PRI.Team).StartingHealth;
            else if(TAM_TeamInfoBlue(PRI.Team) != None)
                starthealth = TAM_TeamInfoBlue(PRI.Team).StartingHealth;
            else
                starthealth = 200;

            if(health < starthealth)
            {
                C.DrawColor.B = 0;
                C.DrawColor.R = Min(200, (400 * (float(StartHealth - Health) / float(StartHealth))));

                if(C.DrawColor.R == 200)
				    C.DrawColor.G = Min(200, (400 * (float(Health) / float(StartHealth))));
                else
                    C.DrawColor.G = 200;
            }
            else
                C.DrawColor = FullHealthColor;

            C.SetPos(posx + (0.0022 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
            C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

            // draw health
            name = string(health);
            C.StrLen(name, xl, yl);
            C.SetPos(posx + width - xl, posy + namey);
            C.DrawTextClipped(name);

            // draw location
            MaxNamePos = 0.99 * (width - namex);
            name = PRI.GetLocationName();
            C.StrLen(name, xl, yl);
            if(xl > MaxNamePos)
                name = left(name, MaxNamePos / xl * len(name));
            C.SetPos(posx + namex, posy + (height * 1.1) + namey);
            C.DrawColor = LocationColor;
            C.DrawTextClipped(name);

            // draw adren
            /* name = ".";
            C.DrawColor = NameColor;
            C.StrLen(name, xl, yl);
            C.SetPos(posx * -1 + width - xl, posy + namey - yl * 0.15);
            C.DrawText(name); */

            name = string(PRI.PawnReplicationInfo.Adrenaline);
            C.StrLen(name, xl, yl);
            C.DrawColor = AdrenColor;
            // C.SetPos(posx * -1 + width, posy + namey);
            C.SetPos(posx + width - xl, posy + (height * 1.1) + namey);
            C.DrawTextClipped(name);

            // draw location dot
            C.DrawColor = WhiteColor;
            Draw2DLocationDot(C, PRI.PawnReplicationInfo.Position, (posx / C.ClipX) + (0.006 * Scale), (posy / C.ClipY) + (0.008 * Scale), 0.008 * Scale, 0.01 * Scale);

            // friends shown
            allies++;
        }
        else
        {
            if(enemies > 9)
                continue;

            if (Misc_BaseGRI(PlayerOwner.GameReplicationInfo).bSpectateAll)
                space = height + (0.0075 * C.ClipY);
            else
                space = (0.005 * C.ClipY);
            width = C.ClipX * 0.18;
            MaxNamePos = 0.67 * (width - namex);

            posy = listy + ((height + space) * enemies);
            posx = C.ClipX * 0.99;

            // draw backgrounds
            C.DrawColor = default.BlackColor;
            C.DrawColor.A = 100;
            C.SetPos(posx - width, posy);
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw disc
            C.SetPos(posx - (C.ClipX * 0.0195 * Scale), posy);
            C.DrawColor = default.WhiteColor;
            C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

            // draw name
            name = PRI.PlayerName;
            C.StrLen(name, xl, yl);
            name = PRI.GetColoredName();
            // if(xl > MaxNamePos)
            // {
            //     name = left(name, MaxNamePos / xl * len(name));
            //     C.StrLen(name, xl, yl);
            // }
            C.DrawColor = NameColor;
            C.SetPos(posx - xl - namex, posy + namey);
            C.DrawTextClipped(name);

            if (Misc_BaseGRI(PlayerOwner.GameReplicationInfo).bSpectateAll)
            {
                // draw health dot
                health = PRI.PawnReplicationInfo.Health + PRI.PawnReplicationInfo.Shield;
                if(TAM_TeamInfo(PRI.Team) != None)
                    starthealth = TAM_TeamInfo(PRI.Team).StartingHealth;
                else if(TAM_TeamInfoRed(PRI.Team) != None)
                    starthealth = TAM_TeamInfoRed(PRI.Team).StartingHealth;
                else if(TAM_TeamInfoBlue(PRI.Team) != None)
                    starthealth = TAM_TeamInfoBlue(PRI.Team).StartingHealth;
                else
                    starthealth = 200;

                if(health < starthealth)
                {
                    C.DrawColor.B = 0;
                    C.DrawColor.R = Min(200, (400 * (float(StartHealth - Health) / float(StartHealth))));

                    if(C.DrawColor.R == 200)
                        C.DrawColor.G = Min(200, (400 * (float(Health) / float(StartHealth))));
                    else
                        C.DrawColor.G = 200;
                }
                else
                    C.DrawColor = FullHealthColor;

                C.SetPos(posx * 0.989 - (0.0022 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
                C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

                // draw health
                name = string(health);
                C.StrLen(name, xl, yl);
                C.SetPos(posx * 1.042 - width - xl, posy + namey);
                C.DrawTextClipped(name);

                // draw location
                C.DrawColor = default.BlackColor;
                C.DrawColor.A = 100;
                C.SetPos(posx - width, posy + height * 1.1);
                C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

                MaxNamePos = 0.99 * (width - namex);
                name = PRI.GetLocationName();
                C.StrLen(name, xl, yl);
                if(xl > MaxNamePos)
                {
                    name = left(name, MaxNamePos / xl * len(name));
                    C.StrLen(name, xl, yl);
                }
                C.SetPos(posx - xl - namex, posy + (height * 1.1) + namey);
                C.DrawColor = LocationColor;
                C.DrawTextClipped(name);

                // draw adren
                /* name = ".";
                C.DrawColor = NameColor;
                C.StrLen(name, xl, yl);
                C.SetPos(posx * 1.042 - width - xl, posy + namey - yl * 0.15);
                C.DrawText(name); */

                name = string(PRI.PawnReplicationInfo.Adrenaline);
                C.StrLen(name, xl, yl);
                C.DrawColor = AdrenColor;
                // C.SetPos(posx * 1.043 - width, posy + namey);
                C.SetPos(posx * 1.042 - width - xl, posy + (height * 1.1) + namey);
                C.DrawTextClipped(name);

                // draw location dot
                C.DrawColor = WhiteColor;
                Draw2DLocationDot(C, PRI.PawnReplicationInfo.Position, (posx * 0.987 / C.ClipX) + (0.006 * Scale), (posy / C.ClipY) + (0.008 * Scale), 0.008 * Scale, 0.01 * Scale);
            }
            else
            {
                // draw health dot
                C.DrawColor = NoInfoColor;
                C.SetPos(posx * 0.989 - (0.0022 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
                C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);
            }

            // enemies shown
            enemies++;
        }
    }
}

simulated function UpdateRankAndSpread(Canvas C)
{
    if(MyOwner == None)
        return;

    if(!MyOwner.bExtendedInfo)
        DrawPlayers(C);
    else
        DrawPlayersExtended(C);
}

simulated function UpdateHUD()
{
    local Color red;
    local Color blue;
    local int team;

    if(myOwner == None)
    {
        myOwner = Misc_Player(PlayerOwner);

        if(myOwner == None)
        {
            Super.UpdateHUD();
            return;
        }
    }

    if(MyOwner.bMatchHUDToSkins)
	{
        if(MyOwner.PlayerReplicationInfo.bOnlySpectator)
        {
            if(Pawn(MyOwner.ViewTarget) != None && Pawn(MyOwner.ViewTarget).GetTeamNum() != 255)
                team = Pawn(MyOwner.ViewTarget).GetTeamNum();
            else
                return;
        }
        else
            team = MyOwner.GetTeamNum();

        red = MyOwner.RedOrEnemy * 2;
        blue = MyOwner.BlueOrAlly * 2;
        red.A = HudColorRed.A;
        blue.A = HudColorBlue.A;

		if(!MyOwner.bUseTeamColors)
		{
			if(team == 0)
			{
				HudColorRed = blue;
				HudColorBlue = red;
                HudColorTeam[0] = blue;
                HudColorTeam[1] = red;

				TeamSymbols[0].Tints[0] = blue;
				TeamSymbols[0].Tints[1] = blue;
				TeamSymbols[1].Tints[0] = red;
				TeamSymbols[1].Tints[1] = red;
			}
			else
			{
				HudColorBlue = blue;
				HudColorRed = red;
                HudColorTeam[1] = blue;
                HudColorTeam[0] = red;

				TeamSymbols[0].Tints[0] = red;
				TeamSymbols[0].Tints[1] = red;
				TeamSymbols[1].Tints[0] = blue;
				TeamSymbols[1].Tints[1] = blue;
			}
		}
		else
		{
			HudColorRed = red;
			HudColorBlue = blue;
		}
	}
	else
	{
		HudColorRed = default.HudColorRed;
		HudColorBlue = default.HudColorBlue;
        HudColorTeam[0] = default.HudColorTeam[0];
        HudColorTeam[1] = default.HudColorTeam[1];

		TeamSymbols[0].Tints[0] = default.HudColorTeam[0];
		TeamSymbols[0].Tints[1] = default.HudColorTeam[0];
		TeamSymbols[1].Tints[0] = default.HudColorTeam[1];
		TeamSymbols[1].Tints[1] = default.HudColorTeam[1];
	}

    Super.UpdateHUD();
}

simulated function DrawUTeamSymbols(Canvas C)
{
    /* XL = RedIcon.SizeX * HUDScale * ResScaleX;
    YL = RedIcon.SizeY * HUDScale * ResScaleY;
    X = C.ClipX * RedIcon.PosX - XL * RedIcon.PivotX + RedIcon.OffsetX * HUDScale * ResScaleX;
    Y = C.ClipY * RedIcon.PosY - YL * RedIcon.PivotY + RedIcon.OffsetY * HUDScale * ResScaleY; */
    
    local float X, Y, XL, YL;

    XL = 32 * HUDScale * ResScaleX;
    YL = 32 * HUDScale * ResScaleY;
    X = C.ClipX * 0.5 - XL * 1.5;
    Y = 2 * HUDScale * ResScaleY;

    C.SetDrawColor(255, 255, 255, 255);

    C.SetPos(X, Y);
    C.DrawTile(Texture'UTeamSymbols', XL, YL, 0, 0, 128, 128);
    
    X = C.ClipX * 0.5 + XL * 0.5;
    C.SetPos(X, Y);
    C.DrawTile(Texture'UTeamSymbols', XL, YL, 128, 0, 128, 128);    
}

simulated function ShowTeamScorePassA(Canvas C)
{
	if ( bShowPoints )
	{
		DrawSpriteWidget (C, TeamScoreBackground[0]);
		DrawSpriteWidget (C, TeamScoreBackground[1]);
		//DrawSpriteWidget (C, TeamScoreBackgroundDisc[0]);
		//DrawSpriteWidget (C, TeamScoreBackgroundDisc[1]);
        DrawUTeamSymbols (C);

        TeamScoreBackground[0].Tints[TeamIndex] = HudColorBlack;
        TeamScoreBackground[0].Tints[TeamIndex].A = 150;
        TeamScoreBackground[1].Tints[TeamIndex] = HudColorBlack;
        TeamScoreBackground[1].Tints[TeamIndex].A = 150;

		//if (TeamSymbols[0].WidgetTexture != None)
		//	DrawSpriteWidget (C, TeamSymbols[0]);
        //
		//if (TeamSymbols[1].WidgetTexture != None)
		//	DrawSpriteWidget (C, TeamSymbols[1]);

        ShowVersusIcon(C);
	 	DrawNumericWidget (C, ScoreTeam[0], DigitsBig);
		DrawNumericWidget (C, ScoreTeam[1], DigitsBig);
	}
}

function CheckCountdown(GameReplicationInfo GRI)
{
    local Misc_BaseGRI G;

    G = Misc_BaseGRI(GRI);
    if(G == None || G.MinsPerRound == 0 || G.RoundTime == 0 || G.RoundTime == OldRoundTime || GRI.Winner != None)
    {
        Super.CheckCountdown(GRI);
        return;
    }

    OldRoundTime = G.RoundTime;

    if(OldRoundTime > 30 && G.MinsPerRound < 2)
        return;

    if(OldRoundTime == 60)
        PlayerOwner.PlayStatusAnnouncement(LongCountName[3], 1, true);
    else if(OldRoundTime == 30)
        PlayerOwner.PlayStatusAnnouncement(LongCountName[4], 1, true);
    else if(OldRoundTime == 20)
        PlayerOwner.PlayStatusAnnouncement(LongCountName[5], 1, true);
    else if(OldRoundTime <= 5 && OldRoundTime > 0)
        PlayerOwner.PlayStatusAnnouncement(CountDownName[OldRoundTime - 1], 1, true);
}

simulated function DrawTimer(Canvas C)
{
	local Misc_BaseGRI GRI;
	local int Minutes, Hours, Seconds;

	GRI = Misc_BaseGRI(PlayerOwner.GameReplicationInfo);

    if(GRI == None)
        return;

	if(GRI.MinsPerRound > 0)
    {
        Seconds = GRI.RoundTime;
        if(GRI.TimeLimit > 0 && GRI.RoundTime > GRI.RemainingTime)
            Seconds = GRI.RemainingTime;
    }
    else if(GRI.TimeLimit > 0)
        Seconds = GRI.RemainingTime;
	else
		Seconds = GRI.ElapsedTime;

	TimerBackground.Tints[TeamIndex] = HudColorBlack;
    TimerBackground.Tints[TeamIndex].A = 150;

	DrawSpriteWidget(C, TimerBackground);
	DrawSpriteWidget(C, TimerBackgroundDisc);
	DrawSpriteWidget(C, TimerIcon);

	TimerMinutes.OffsetX = default.TimerMinutes.OffsetX - 80;
	TimerSeconds.OffsetX = default.TimerSeconds.OffsetX - 80;
	TimerDigitSpacer[0].OffsetX = Default.TimerDigitSpacer[0].OffsetX;
	TimerDigitSpacer[1].OffsetX = Default.TimerDigitSpacer[1].OffsetX;

	if( Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

		DrawNumericWidget( C, TimerHours, DigitsBig);
        TimerHours.Value = Hours;

		if(Hours>9)
		{
			TimerMinutes.OffsetX = default.TimerMinutes.OffsetX;
			TimerSeconds.OffsetX = default.TimerSeconds.OffsetX;
		}
		else
		{
			TimerMinutes.OffsetX = default.TimerMinutes.OffsetX -40;
			TimerSeconds.OffsetX = default.TimerSeconds.OffsetX -40;
			TimerDigitSpacer[0].OffsetX = Default.TimerDigitSpacer[0].OffsetX - 32;
			TimerDigitSpacer[1].OffsetX = Default.TimerDigitSpacer[1].OffsetX - 32;
		}
		DrawSpriteWidget( C, TimerDigitSpacer[0]);
	}
	DrawSpriteWidget( C, TimerDigitSpacer[1]);

	Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    TimerMinutes.Value = Min(Minutes, 60);
	TimerSeconds.Value = Min(Seconds, 60);

	DrawNumericWidget( C, TimerMinutes, DigitsBig);
	DrawNumericWidget( C, TimerSeconds, DigitsBig);
}

simulated function DrawDamageIndicators(Canvas C)
{
    local float XL, YL;
    local string Name;
    
    Super.DrawDamageIndicators(C);
    
    if(bHideHud || Misc_Player(PlayerOwner) == None || Misc_Player(PlayerOwner).DamageIndicator != Centered)
        return;

    if(Misc_Player(PlayerOwner).SumDamageTime + 1 <= Level.TimeSeconds)
        return;
    
    if(C.ClipX >= 1600)
        C.Font = GetFontSizeIndex(C, -2);
    else
        C.Font = GetFontSizeIndex(C, -1);

    C.DrawColor = class'Emitter_Damage'.static.ColorRamp(Misc_Player(PlayerOwner).SumDamage);
    C.DrawColor.A = Clamp(int(((Misc_Player(PlayerOwner).SumDamageTime + 1) - Level.TimeSeconds) * 200), 1, 200);

    Name = string(Misc_Player(PlayerOwner).SumDamage);
    C.StrLen(Name, XL, YL);
    C.SetPos((C.ClipX - XL) * 0.5, (C.ClipY - YL) * 0.46);
    C.DrawTextClipped(Name);
}

defaultproperties
{
     TeamTex=Texture'HUDContent.Generic.HUD'
     TrackedPlayer=Texture'3SPNv3177AT.textures.chair'
     FullHealthColor=(B=200,G=100,A=255)
     NameColor=(B=200,G=200,R=200,A=255)
     LocationColor=(G=130,R=175,A=255)
     AdrenColor=(B=250,G=230,R=210,A=128)
     NoInfoColor=(B=255,G=255,R=255,A=96)
}
