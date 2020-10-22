class Misc_Pawn extends xPawn;

var Misc_Player MyOwner;

/* brightskins */
var bool bBrightskins;

var Material SavedBody;
var Material OrigBody;
var Combiner Combined;
var ConstantColor SkinColor;
var ConstantColor OverlayColor;

var Color RedColor;
var Color BlueColor;

var byte  OverlayType;
var Color OverlayColors[4];
/* brightskins */

/* camping related */
var vector LocationHistory[10];
var int	   NextLocHistSlot;
var bool   bWarmedUp;
var int	   ReWarnTime;
/* camping related */

// adren(rez) monitoring
var float AdrenTimer;

var xEmitter InvisEmitter;

var bool bUseChatIcon;
var ChatIcon ChatIcon;

replication
{
    unreliable if(Role == ROLE_Authority)
        OverlayType;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    SpawnTime = Level.TimeSeconds;      // i don't care SpawnProtection time setting, will handle by myself...
}

simulated function Destroyed()
{
    if(InvisEmitter != None)
    {
        InvisEmitter.mRegen = false;
        InvisEmitter.Destroy();
        InvisEmitter = None;
    }
    if(ChatIcon != None)
    {
        ChatIcon.Destroy();
        ChatIcon = None;
    }

    Super.Destroyed();
}

function bool StartingNewRound()
{
    if(ArenaMaster(Level.Game) != None)
        return (ArenaMaster(Level.Game).RespawnTime > 0 || ArenaMaster(Level.Game).CurrentRound < 1);

    if(Team_GameBase(Level.Game) != None)
        return (Team_GameBase(Level.Game).RespawnTime > 0 || Team_GameBase(Level.Game).CurrentRound < 1);

    return false;
}

function PossessedBy(Controller C)
{
    Super.PossessedBy(C);

    if(bDeleteMe || Controller != C)
        return;

    if(Misc_PRI(C.PlayerReplicationInfo) != None)
    {
        if(!StartingNewRound() )
            SpawnTime += 3.0;
    }

    if(Misc_PRI(PlayerReplicationInfo) != None)
        Misc_PRI(PlayerReplicationInfo).PawnReplicationInfo.SetMyPawn(self);
}

function UnPossessed()
{
    if(Misc_PRI(PlayerReplicationInfo) != None)
        Misc_PRI(PlayerReplicationInfo).PawnReplicationInfo.SetMyPawn(None);

    Super.UnPossessed();
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

    /* if(instigatedBy != None && instigatedBy != self && Misc_PRI(instigatedBy.PlayerReplicationInfo) != None)
        Misc_PRI(instigatedBy.PlayerReplicationInfo).UpdateWeaponFlags(); */
}

function bool InCurrentCombo()
{
    if(TAM_GRI(Level.GRI) == None || TAM_GRI(Level.GRI).bDisableTeamCombos)
        return Super.InCurrentCombo();
    return false;
}

/* function GiveWeapon(string aClassName)
{
	local class<Weapon> WeaponClass;
	local Weapon OldWeapon, NewWeapon;

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	if(FindInventoryType(WeaponClass) != None)
		return;
	newWeapon = Spawn(WeaponClass);
	if(newWeapon != None)
    {
        OldWeapon = Weapon;
        Weapon = NewWeapon;
		NewWeapon.GiveTo(self);
        // NewWeapon.ClientWeaponSet(RocketLauncher(NewWeapon) != None);
        Weapon = OldWeapon;
    }
} */

function GiveWeaponClass(class<Weapon> WeaponClass)
{
    local Weapon NewWeapon;

    if(FindInventoryType(WeaponClass) != None)
        return;

    NewWeapon = Spawn(WeaponClass);
    if(NewWeapon != None)
        NewWeapon.GiveTo(self);
}

// changed to save adren
function RemovePowerups()
{
    local float Adren;

    if(TAM_GRI(Level.GRI) == None || TAM_GRI(Level.GRI).bDisableTeamCombos)
    {
        Super.RemovePowerups();
        return;
    }

    if(Controller != None && Misc_DynCombo(CurrentCombo) != None)
    {
        Adren = Controller.Adrenaline;
        Super.RemovePowerups();
        Controller.Adrenaline = Adren;

        return;
    }

    Super.RemovePowerups();
}

// 75% armor absorbtion rate
function int ShieldAbsorb(int dam)
{
    local float Shield;

    if(ShieldStrength == 0)
        return dam;

    SetOverlayMaterial(ShieldHitMat, ShieldHitMatTime, false);
    PlaySound(Sound'WeaponSounds.ArmorHit', SLOT_Pain, 2 * TransientSoundVolume,, 400);

    Shield = ShieldStrength - (dam * 0.75 + 0.5);
    dam *= 0.25;
    if(Shield < 0)
    {
        dam += -(Shield);
        Shield = 0;
    }

    ShieldStrength = Shield;
    return dam;
}

simulated function SetOverlayMaterial(Material mat, float time, bool bOverride)
{
    if(mat == None)
        OverlayType = 0;
    else if(mat == ShieldHitMat)
    {
        OverlayType = 1;
        SetTimer(ShieldHitMatTime, false);
    }
    else if(OverlayType != 1)
    {
        if(mat == Shader'XGameShaders.PlayerShaders.LightningHit')
            OverlayType = 2;
        else if(mat == Shader'UT2004Weapons.Shaders.ShockHitShader')
            OverlayType = 3;
        else if(mat == Shader'XGameShaders.PlayerShaders.LinkHit')
            OverlayType = 4;

        SetTimer(ShieldHitMatTime, false);
    }

    Super.SetOverlayMaterial(mat, time, bOverride);
}

/* brightskins related */
/* copied from a recent xpawn patch version.
   needed to stop GPFs in older versions. */
simulated function bool CheckValidFemaleDefault()
{
	return ( (PlacedFemaleCharacterName ~= "Tamika")
			|| (PlacedFemaleCharacterName ~= "Sapphire")
			|| (PlacedFemaleCharacterName ~= "Enigma")
			|| (PlacedFemaleCharacterName ~= "Cathode")
			|| (PlacedFemaleCharacterName ~= "Rylisa")
			|| (PlacedFemaleCharacterName ~= "Ophelia")
			|| (PlacedFemaleCharacterName ~= "Zarina")
            || (PlacedFemaleCharacterName ~= "Nebri")
            || (PlacedFemaleCharacterName ~= "Subversa")
            || (PlacedFemaleCharacterName ~= "Diva") );
}

simulated function bool CheckValidMaleDefault()
{
	return ( (PlacedCharacterName ~= "Jakob")
			|| (PlacedCharacterName ~= "Gorge")
			|| (PlacedCharacterName ~= "Malcolm")
			|| (PlacedCharacterName ~= "Xan")
			|| (PlacedCharacterName ~= "Brock")
			|| (PlacedCharacterName ~= "Gaargod")
			|| (PlacedCharacterName ~= "Axon")
            || (PlacedCharacterName ~= "Barktooth")
            || (PlacedCharacterName ~= "Torch")
            || (PlacedCharacterName ~= "WidowMaker") );
}
/*
*/

simulated function string CheckAndGetCharacter()
{
    if(!CheckValidFemaleDefault() && !CheckValidMaleDefault())
    {
        if(!CheckValidFemaleDefault())
            PlacedFemaleCharacterName = "Tamika";
        if(!CheckValidMaleDefault())
            PlacedCharacterName = "Jakob";
    }

    if(PlayerReplicationInfo != None && PlayerReplicationInfo.bIsFemale)
        return PlacedFemaleCharacterName;
    else
        return PlacedCharacterName;
}

simulated function string GetDefaultCharacter()
{
    local PlayerController P;
    local int MyTeam;
    local int OwnerTeam;

    if(!class'Misc_Player'.default.bForceRedEnemyModel && !class'Misc_Player'.default.bForceBlueAllyModel)
        return Super.GetDefaultCharacter();

    MyTeam = GetTeamNum();
    if(MyTeam == 255)
        MyTeam = 0;

    P = Level.GetLocalPlayerController();
    if(P != None && P.PlayerReplicationInfo != None && !P.PlayerReplicationInfo.bOnlySpectator)
    {
        if(P.Pawn == self)
            return Super.GetDefaultCharacter();

        OwnerTeam = P.GetTeamNum();

        if(class'Misc_Player'.default.bUseTeamModels || OwnerTeam == 255)
        {
            if(MyTeam == 1)
            {
                if(class'Misc_Player'.default.bForceBlueAllyModel)
                {
                    PlacedCharacterName = class'Misc_Player'.default.BlueAllyModel;
                    PlacedFemaleCharacterName = class'Misc_Player'.default.BlueAllyModel;
                }
                else
                    return CheckAndGetCharacter();
            }
            else
            {
                if(class'Misc_Player'.default.bForceRedEnemyModel)
                {
                    PlacedCharacterName = class'Misc_Player'.default.RedEnemyModel;
                    PlacedFemaleCharacterName = class'Misc_Player'.default.RedEnemyModel;
                }
                else
                    return CheckAndGetCharacter();
            }
        }
        else if(!class'Misc_Player'.default.bUseTeamModels)
        {
            if(MyTeam == OwnerTeam)
            {
                if(class'Misc_Player'.default.bForceBlueAllyModel)
                {
                    PlacedCharacterName = class'Misc_Player'.default.BlueAllyModel;
                    PlacedFemaleCharacterName = class'Misc_Player'.default.BlueAllyModel;
                }
                else
                    return CheckAndGetCharacter();
            }
            else
            {
                if(class'Misc_Player'.default.bForceRedEnemyModel)
                {
                    PlacedCharacterName = class'Misc_Player'.default.RedEnemyModel;
                    PlacedFemaleCharacterName = class'Misc_Player'.default.RedEnemyModel;
                }
                else
                    return CheckAndGetCharacter();
            }
        }
    }

    return CheckAndGetCharacter();
}

simulated function bool ForceDefaultCharacter()
{
	local PlayerController P;
    local int MyTeam;
    local int OwnerTeam;

    if(!class'Misc_Player'.default.bForceRedEnemyModel && !class'Misc_Player'.default.bForceBlueAllyModel)
        return Super.ForceDefaultCharacter();

    MyTeam = GetTeamNum();
    if(MyTeam == 255)
        MyTeam = 0;

    P = Level.GetLocalPlayerController();
    if(P != None && P.PlayerReplicationInfo != None && !P.PlayerReplicationInfo.bOnlySpectator)
    {
        if(P.Pawn == self)
            return Super.ForceDefaultCharacter();

        OwnerTeam = P.GetTeamNum();

        if(class'Misc_Player'.default.bUseTeamModels || OwnerTeam == 255)
        {
            if(MyTeam == 1)
                return class'Misc_Player'.default.bForceBlueAllyModel;
            else
                return class'Misc_Player'.default.bForceRedEnemyModel;
        }
        else if(!class'Misc_Player'.default.bUseTeamModels)
        {
            if(MyTeam == OwnerTeam)
                return class'Misc_Player'.default.bForceBlueAllyModel;
            else
                return class'Misc_Player'.default.bForceRedEnemyModel;
        }
    }

    return false;
}

simulated function bool CheckValid(string name)
{
    return ((name ~= "Abaddon")
        ||  (name ~= "Ambrosia") || (name ~= "Annika") || (name ~= "Arclite")
        ||  (name ~= "Aryss") || (name ~= "Asp") || (name ~= "Axon")
        ||  (name ~= "Azure") || (name ~= "Baird") || (name ~= "BlackJack")
        ||  (name ~= "Barktooth") || (name ~= "Brock") || (name ~= "Brutalis")
        ||  (name ~= "Cannonball") || (name ~= "Cathode") || (name ~= "ClanLord")
        ||  (name ~= "Cleopatra") || (name ~= "Cobalt") || (name ~= "Corrosion")
        ||  (name ~= "Cyclops") || (name ~= "Damarus") || (name ~= "Diva")
        ||  (name ~= "Divisor") || (name ~= "Domina") || (name ~= "Dominator")
        ||  (name ~= "Drekorig") || (name ~= "Enigma") || (name ~= "Faraleth")
        ||  (name ~= "Fate") || (name ~= "Frostbite") || (name ~= "Gaargod")
        ||  (name ~= "Garrett") || (name ~= "Gkublok") || (name ~= "Gorge")
        ||  (name ~= "Greith") || (name ~= "Guardian") || (name ~= "Harlequin")
        ||  (name ~= "Horus") || (name ~= "Hyena") || (name ~= "Jakob")
        ||  (name ~= "Kaela") || (name ~= "Kane") || (name ~= "Kareg")
        ||  (name ~= "Komek") || (name ~= "Kraagesh") || (name ~= "Kragoth")
        ||  (name ~= "Lauren") || (name ~= "Lilith") || (name ~= "Makreth")
        ||  (name ~= "Malcolm") || (name ~= "Mandible") || (name ~= "Matrix")
        ||  (name ~= "Mekkor") || (name ~= "Memphis") || (name ~= "Mokara")
        ||  (name ~= "Motig") || (name ~= "Mr.Crow") || (name ~= "Nebri")
        ||  (name ~= "Nebri") || (name ~= "Ophelia") || (name ~= "Othello")
        ||  (name ~= "Outlaw") || (name ~= "Prism") || (name ~= "Rae")
        ||  (name ~= "Rapier") || (name ~= "Ravage") || (name ~= "Reinha")
        ||  (name ~= "Remus") || (name ~= "Renegade") || (name ~= "Riker")
        ||  (name ~= "Roc") || (name ~= "Romulus") || (name ~= "Rylisa")
        ||  (name ~= "Sapphire") || (name ~= "Satin") || (name ~= "Scarab")
        ||  (name ~= "Selig") || (name ~= "Siren") || (name ~= "Skakruk")
        ||  (name ~= "Skrilax") || (name ~= "Subversa") || (name ~= "Syzygy")
        ||  (name ~= "Tamika") || (name ~= "Thannis") || (name ~= "Torch")
        ||  (name ~= "Thorax") || (name ~= "Virus") || (name ~= "Widowmaker")
        ||  (name ~= "Wraith") || (name ~= "Xan") || (name ~= "Zarina"));
}

simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	local string DefaultSkin;
    local PlayerController p;

    DefaultSkin = GetDefaultCharacter();

	if(PlayerReplicationInfo.CharacterName ~= "Virus" || PlayerReplicationInfo.CharacterName ~= "Enigma"
            	|| PlayerReplicationInfo.CharacterName ~= "Xan" || PlayerReplicationInfo.CharacterName ~= "Cyclops"
		        || PlayerReplicationInfo.CharacterName ~= "Axon" || PlayerReplicationInfo.CharacterName ~= "Matrix"
                || !CheckValid(PlayerReplicationInfo.CharacterName))
		if(Controller == None || Controller.IsA('Bot'))
         		rec = class'xUtil'.static.FindPlayerRecord(DefaultSkin);

	if ((rec.Species == None) || ForceDefaultCharacter())
		rec = class'xUtil'.static.FindPlayerRecord(DefaultSkin);

	Species = rec.Species;
	RagdollOverride = rec.Ragdoll;
	if(!Species.static.Setup(self, rec))
	{
		rec = class'xUtil'.static.FindPlayerRecord(DefaultSkin);
		if(!Species.static.Setup(self, rec))
			return;
	}

	ResetPhysicsBasedAnim();

    if(Level.NetMode == NM_DedicatedServer)
        return;

    p = Level.GetLocalPlayerController();
    if(p == None)
        return;

    bNoCoronas = true;

    if(MyOwner == None)
    {
		MyOwner = Misc_Player(p);

	    if(MyOwner == None)
		    return;
    }

    bBrightskins = class'Misc_Player'.default.bUseBrightskins;
    if(bBrightskins)
    {
        if(OrigBody == None)
		    OrigBody = Skins[0];

	    if(SkinColor == None)
		    SkinColor = New(none)class'ConstantColor';

        if(OverlayColor == None)
            OverlayColor = New(none)class'ConstantColor';

	    if(Combined == None)
		    Combined = New(none)class'Combiner';
    }
}

simulated function RemoveFlamingEffects()
{
    local int i;

    if( Level.NetMode == NM_DedicatedServer )
        return;

    for(i = 0; i < Attached.length; i++)
    {
        if(Attached[i].IsA('xEmitter') && !Attached[i].IsA('BloodJet')
            && !Attached[i].IsA('Emitter_SeeInvis') && !Attached[i].IsA('SpeedTrail')
            && !Attached[i].IsA('RegenCrosses') && !Attached[i].IsA('OffensiveEffect'))
        {
            xEmitter(Attached[i]).mRegen = false;
        }
    }
}

simulated function SetChatIcon()
{
    if(bIsTyping && Health > 0)
    {
        if(ChatIcon == None)
        {
            ChatIcon = Spawn(class'ChatIcon', self);
            if(ChatIcon != None)
            {
                AttachToBone(ChatIcon, 'head');
                ChatIcon.SetRelativeLocation(vect(64,0,0) );
            }
        }
    }
    else
    {
        if(ChatIcon != None)
        {
            ChatIcon.Destroy();
            ChatIcon = None;
        }
    }
}

function float RatePlayerAdren(Controller C, float Amount)
{
    if(C == Controller || Misc_Player(C) == None || C.PlayerReplicationInfo == None || C.PlayerReplicationInfo.Team == None)
        return -1;

    if(C.PlayerReplicationInfo.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex)
        return -1;

    if(C.Adrenaline >= 100)
        return -1;
    
    if(C.Adrenaline < 100 && C.Adrenaline + Amount > 100)
    {
        if(C.PlayerReplicationInfo.bOutOfLives)
            return 1000 - C.Adrenaline;
        
        return 2000 - C.Adrenaline;
    }
    return -1;
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if(Role == ROLE_Authority)
    {
        if(Misc_Player(Controller) != None && Controller.Adrenaline > 100 && PlayerReplicationInfo != None && PlayerReplicationInfo.Team != None &&
           TAM_Mutator(Level.Game.BaseMutator) != None && TAM_Mutator(Level.Game.BaseMutator).ThisTeamNeedsRez == PlayerReplicationInfo.Team.TeamIndex)
        {
            // adren warnings
            if(AdrenTimer <= 6.0 && AdrenTimer + DeltaTime >= 6.0)  // 6 s delay
            {
                Misc_Player(Controller).ReceiveLocalizedMessage(class'Message_AdrenWarning', 0);
                AdrenTimer = 0;
            }
            else
                AdrenTimer = AdrenTimer + DeltaTime;
        }
        else if(AdrenTimer != 0)
            AdrenTimer = 0;
    }

    if(Level.NetMode == NM_DedicatedServer)
        return;

    if(bUseChatIcon)
        SetChatIcon();

    if(MyOwner == None)
        MyOwner = Misc_Player(Level.GetLocalPlayerController());

    if(MyOwner != None)
    {
        if(bInvis)
        {
            if(MyOwner.bSeeInvis)
            {
                if(InvisEmitter == None)
                    InvisEmitter = Spawn(class'Emitter_SeeInvis', self,, Location, Rotation);
                AttachToBone(InvisEmitter, 'spine');
            }
            else if(InvisEmitter != None)
            {
                DetachFromBone(InvisEmitter);
                InvisEmitter.mRegen = false;
                InvisEmitter.Destroy();
                InvisEmitter = None;
            }

            return;
        }
        else if(InvisEmitter != None)
        {
            DetachFromBone(InvisEmitter);
            InvisEmitter.mRegen = false;
            InvisEmitter.Destroy();
            InvisEmitter = None;
        }
    }
    else if(bInvis)
        return;

    if(bPlayedDeath)
		return;

    bBrightskins = class'Misc_Player'.default.bUseBrightskins;
    SetSkin();
}

simulated function SetSkin()
{
    if(bBrightskins)
    {
        if(OverlayType != 0)
            SetOverlaySkin();
        else
            SetBrightSkin();
    }
    else
        SetStandardSkin();
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	SetStandardSkin();
	bUnlit = false;
	Super.PlayDying(DamageType, HitLoc);
}

simulated function SetStandardSkin()
{
	if(OrigBody != None)
		Skins[0] = OrigBody;

	bUnlit = true;
}

simulated static function ClampColor(out Color color)
{
    color.R = Min(color.r, 100) / 100.0 * 128.0;
    color.G = Min(color.g, 100) / 100.0 * 128.0;
    color.B = Min(color.b, 100) / 100.0 * 128.0;
    color.A = 128;
}

simulated function SetBrightSkin()
{
	local int TeamIndex;
	local int OwnerTeam;

	if(MyOwner != None && MyOwner.IsInState('GameEnded'))
		return;

	if(OrigBody == None)
		OrigBody = Skins[0];

	if(SkinColor == None)
		SkinColor = New(none)class'ConstantColor';

    if(OverlayColor == None)
        OverlayColor = New(none)class'ConstantColor';

	if(Combined == None)
		Combined = New(none)class'Combiner';

	TeamIndex = GetTeamNum();
	if(MyOwner != None && !MyOwner.bUseTeamColors)
	{
		if(MyOwner.PlayerReplicationInfo.bOnlySpectator)
		{
			if(Pawn(MyOwner.ViewTarget) != None && Pawn(MyOwner.ViewTarget).PlayerReplicationInfo != None && Pawn(MyOwner.ViewTarget).PlayerReplicationInfo.Team != None)
				OwnerTeam = Pawn(MyOwner.ViewTarget).PlayerReplicationInfo.Team.TeamIndex;
            else
                OwnerTeam = 255;
		}
		else
			ownerTeam = MyOwner.GetTeamNum();

		if(MyOwner.PlayerReplicationInfo != PlayerReplicationInfo && (ownerTeam == 255 || TeamIndex != OwnerTeam))
        {
            SkinColor.Color = MyOwner.RedOrEnemy;
        }
		else/* if(TeamIndex == OwnerTeam || MyOwner.PlayerReplicationInfo == PlayerReplicationInfo)*/
        {
            if ( class'Misc_Player'.default.RedOrEnemy == class'Misc_Player'.default.BlueOrAlly )
            {
                if (TeamIndex == 0)
                    SkinColor.Color = RedColor;
                if (TeamIndex == 1)
                    SkinColor.Color = BlueColor;
            }
            else
                SkinColor.Color = MyOwner.BlueOrAlly;
        }
	}
	else
	{
        if(MyOwner == None)
        {
            if(TeamIndex == 0 || TeamIndex == 255)
			    SkinColor.Color = RedColor;
		    else
			    SkinColor.Color = BlueColor;
        }
        else
        {
		    if(TeamIndex == 0 || TeamIndex == 255)
			    SkinColor.Color = class'Misc_Player'.default.RedOrEnemy;
		    else
			    SkinColor.Color = class'Misc_Player'.default.BlueOrAlly;
        }
	}

    ClampColor(SkinColor.Color);

    Combined.CombineOperation = CO_Add;
    Combined.Material1 = GetSkin();
	Combined.Material2 = SkinColor;
	Skins[0] = Combined;

	bUnlit = true;
}

simulated function Material GetSkin()
{
    local Material TempSkin;
   	local string Skin;

	if(SavedBody != None)
		return SavedBody;

    Skin = String(Skins[0]);

    if(Right(Skin, 2) == "_0" || Right(Skin, 2) == "_1")
    {
        Skin = Left(Skin, Len(Skin) - 2);
    }
    else if(Right(Skin, 3) == "_0B" || Right(Skin, 3) == "_1B")
    {
        Skin = Right(Skin, Len(Skin) - 6);
        Skin = Left(Skin, Len(Skin) - 3);
    }

   	TempSkin = Material(DynamicLoadObject(Skin, class'Material', true));

    if(TempSkin == None)
        TempSkin = Skins[0];

	SavedBody = TempSkin;
	return SavedBody;
}

simulated function SetOverlaySkin()
{
    OverlayColor.Color = OverlayColors[OverlayType - 1];

    Combined.Material1 = GetSkin();
    Combined.Material2 = OverlayColor;
    Skins[0] = Combined;
}

function Timer()
{
    OverlayType = 0;
}
/* brightskins related */

defaultproperties
{
     RedColor=(R=100)
     BlueColor=(B=100,G=25)
     OverlayColors(0)=(G=80,R=128,A=128)
     OverlayColors(1)=(B=128,G=96,R=64,A=128)
     OverlayColors(2)=(B=110,R=80,A=128)
     OverlayColors(3)=(B=64,G=128,R=64,A=128)
     bUseChatIcon=True
     ShieldHitMatTime=0.350000
     bPlayOwnFootsteps=False
     RequiredEquipment(0)="XWeapons.ShieldGun"
     RequiredEquipment(1)=
     bNoWeaponFiring=True
}
