class Misc_Console extends Interaction;

simulated event NotifyLevelChange()
{
    Master.RemoveInteraction(self);
}

function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta )
{
    if  ( (Action == IST_Press) && (Key == IK_F7) )
    {
        Misc_Player(ViewPortOwner.Actor).Menu3SPN();
        return true;
    }

    return false;
}

defaultproperties
{
}
