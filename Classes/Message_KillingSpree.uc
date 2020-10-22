//================================================================================
// Message_KillingSpree.
//================================================================================

class Message_KillingSpree extends KillingSpreeMessage;

var Color SpreeColor[10];

static function bool IsPRISpectated (PlayerReplicationInfo PRI)
{
  local Controller PC;

  PC = PRI.Level.GetLocalPlayerController();
  if ( PlayerController(PC) == None )
  {
    return False;
  }
  if ( (Pawn(PlayerController(PC).ViewTarget) != None) && (Pawn(PlayerController(PC).ViewTarget).PlayerReplicationInfo == PRI) )
  {
    return True;
  }
  return False;
}

static function int GetFontSize (int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer)
{
  if ( (RelatedPRI1 != None) && (RelatedPRI2 == None) )
  {
    if ( IsPRISpectated(RelatedPRI1) )
    {
      Default.PosY = 0.69999999;
      return 0;
    } else {
      Default.PosY = 0.12;
      return -1;
    }
  }
  if ( (RelatedPRI1 == None) && (RelatedPRI2 != None) )
  {
    Default.PosY = 0.82999998;
    return -1;
  }
  if ( (RelatedPRI1 != None) && (RelatedPRI2 != None) )
  {
    Default.PosY = 0.82999998;
    return -1;
  }
  Default.PosY = -1.0;
}

static function Color GetColor (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
  if ( Switch < 10 )
  {
    return Default.SpreeColor[Switch];
  }
  return Default.DrawColor;
}

defaultproperties
{
     SpreeColor(0)=(A=255)
     SpreeColor(1)=(A=255)
     SpreeColor(2)=(A=255)
     SpreeColor(3)=(A=255)
     SpreeColor(4)=(A=255)
     SpreeColor(5)=(A=255)
     EndSpreeNote="'s Killing Spree Ended By"
     EndSelfSpree="Blown His Own Spree"
     EndFemaleSpree="Blown Her Own Spree"
     SpreeNote(0)="Is On K I L L I N G  S P R E E"
     SpreeNote(1)="Is On R A M P A G E"
     SpreeNote(2)="Is D O M I N A T I N G"
     SpreeNote(3)="Is U N S T O P P A B L E"
     SpreeNote(4)="Is G O D L I K E"
     SpreeNote(5)="Is W I C K E D  S I C K"
     SelfSpreeNote(0)="KILLING  SPREE"
     SelfSpreeNote(1)="R A M P A G E"
     SelfSpreeNote(2)="D O M I N A T I N G"
     SelfSpreeNote(3)="U N S T O P P A B L E"
     SelfSpreeNote(4)="G O D L I K E"
     SelfSpreeNote(5)="WICKED SICK"
     Lifetime=5
}
