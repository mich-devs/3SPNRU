class ChatIcon extends Actor;

#exec OBJ LOAD FILE=../3SPNv3177AT/Media/Texture2.utx PACKAGE=3SPNv3177AT

var const Texture RedIcon, BlueIcon, GreenIcon;

function PostBeginPlay()
{
    if(Pawn(Owner) == None)
        return;

    if(Pawn(Owner).GetTeamNum() == 0)
        Texture = RedIcon;
    else if(Pawn(Owner).GetTeamNum() == 1)
        Texture = BlueIcon;
    else
        Texture = GreenIcon;
}


function Tick(float DeltaTime)
{
    if(Pawn(Owner) == None && !bDeleteMe)
        Destroy();
}

defaultproperties
{
     RedIcon=Texture'3SPNv3177AT.TA.Red'
     BlueIcon=Texture'3SPNv3177AT.TA.Blue'
     GreenIcon=Texture'3SPNv3177AT.TA.Green'
     DrawScale=0.500000
     Style=STY_Masked
}
