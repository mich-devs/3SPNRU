class Menu_TAMLoginMenu extends UT2K4PlayerLoginMenu;

function AddPanels()
{
	Panels[0].ClassName = "3SPNCv42101.Menu_PlayerLoginControlsTAM";
	Super.AddPanels();
}

defaultproperties
{
}
