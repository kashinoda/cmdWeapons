#include <sourcemod> 
#include <sdktools> 
#include <smlib> 

#pragma semicolon 1
#pragma tabsize 0
#pragma newdecls required

/* Array containing every weapon in the game, 32 in total */

char sWeapons[][] = {"weapon_awp", "weapon_ssg08", "weapon_ak47", "weapon_m4a1", "weapon_m4a1_silencer", "weapon_sg556", "weapon_aug", "weapon_galilar", "weapon_famas", "weapon_mac10", "weapon_mp9", "weapon_mp7", "weapon_ump45", "weapon_bizon", "weapon_p90", "weapon_mp5sd", "weapon_m249", "weapon_mag7", "weapon_negev", "weapon_nova", "weapon_sawedoff", "weapon_xm1014", "weapon_fiveseven", "weapon_deagle", "weapon_elite", "weapon_p250", "weapon_tec9", "weapon_cz75a", "weapon_revolver", "weapon_usp_silencer", "weapon_glock", "weapon_hkp2000"};

/* Duplicate of the above array with shortened names for use with command arguments. I.e. !wp awp */

char sSelect[][] = {"awp", "scout", "ak", "m4", "m4s", "sg", "aug", "galil", "famas", "mac10", "mp9", "mp7", "ump", "bizon", "p90", "mp5", "m249", "mag7", "negev", "nova", "soff", "xm", "57", "deag", "dualies", "p250", "tec9", "cz", "r8", "usp", "glock", "p2000"};

// Test

bool bValidSelection;
int iSelectedWeapon;

public void OnPluginStart() 
{ 
	RegAdminCmd("wp",	CMD_WP,	ADMFLAG_GENERIC,	""); // Call the weapon function
	RegAdminCmd("wplist",	CMD_WPList,	ADMFLAG_GENERIC,	""); // Call the weapon list function
	RegAdminCmd("wpclear",	CMD_WPClear,	ADMFLAG_GENERIC,	""); // Call the weapon clear function
} 

public Action CMD_WP (int client, int args) // Weapon function
{
    char sCmd[20]; // New string with a max character length of 20
    GetCmdArg(1, sCmd, sizeof(sCmd)); // Take the argument (weapon name) from the admin command (!wp) and store it in the string
    int iWeaponCount = sizeof(sWeapons); // Count of weapons in the sWeapons array, this could also be the sSelect array - we just need the number

    bValidSelection = false; // Reset valid selection flag, used later    

    for (int iWeaponLookup = 0; iWeaponLookup < iWeaponCount; iWeaponLookup++) // Iterate through every entry in the sWeapons array
    {
    	if (StrEqual(sSelect[iWeaponLookup], sCmd)) // Check if the string matches any entry in the sSelect array. This happens 32 times while iWeaponLookup is incrementing
    	{
    		PrintToChatAll(" \x10~ \x01[\x07GUN MODE\x01] \x10~ \x01[\x05%s \x0BNext Round!\x01] \x10~", sWeapons[iWeaponLookup]); // Print the matched weapon to chat, %s calls the string from within the quotes.
    		iSelectedWeapon = iWeaponLookup; // Set the global variable iSelectedweapon to matched weapons position in the array
    		bValidSelection = true; // Set the valid selection flag
    		HookEvent("round_start", EquipPlayers); // Start hooking the round_start event
    	}
        
    }

    if (bValidSelection == false) // Check to see if the selection is now valid, if not print the output to chat
    {
    	PrintToChatAll(" \x05Cannot find %s, type \x0B!wplist \x05to see correct syntax", sCmd);
    }

}

public void EquipPlayers(Event event, const char[] name, bool dontBroadcast) // Called when the round_start event occurs
{
  	for (int iClient = 1; iClient <= MaxClients; iClient++) // Iterate through every available client slot, MaxClients is a global variable which is always 64
        	{

        	if (IsClientConnected(iClient) && IsClientInGame(iClient)) // Check if that client index is connected and in game
       		{

       			for(int iSlot = 0; iSlot < 2; iSlot++)  // Iterate though primary and secondary weapon slots (0=Primary, 1=Secondary, 2=Knife, 3=Grenade, 4=C4)
        		{ 
            		int iEntity;

             		while((iEntity = GetPlayerWeaponSlot(iClient, iSlot)) != -1) // Grab the entity value for every valid client and every non-empty weapon slot
            		{ 
                		RemovePlayerItem(iClient, iEntity); // Remove that entity from the client
                		AcceptEntityInput(iEntity, "Kill"); // Kill the entity
            		} 
        		}

       			GivePlayerItem(iClient, sWeapons[iSelectedWeapon], 0); // Use the global variable that was set earlier to grab the correct weapon form sWeapons array
				GivePlayerItem(iClient, "weapon_flashbang", 0);
				GivePlayerItem(iClient, "weapon_flashbang", 0);
				SetEntProp(iClient, Prop_Data, "m_ArmorValue", 100, 1 );

					if (StrEqual(sWeapons[iSelectedWeapon], "weapon_usp_silencer") || StrEqual(sWeapons[iSelectedWeapon], "weapon_glock") || StrEqual(sWeapons[iSelectedWeapon], "weapon_hkp2000")) // Check for USP, Glock or P2000 and set hemlet to 0 if so
					{
    					SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 0);
    				}

    				else
    				{
    					SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
    				}
    		}
    	}
}

public Action CMD_WPList (int client, int args) // List all the weapon aliases that can be used in the command argument
{
	PrintToChatAll(" \x07Usage: \x01!wp <gun>\x05 awp, scout, ak, m4, m4s, sg, aug, deag, usp, glock, galil, famas, mac10, mp9, mp7, ump, bizon, p90, mp5, m249, mag7, negev, nova, soff, xm, 57, dualies, p250, tec9, cz, r8, p2000"); 
}

public Action CMD_WPClear (int client, int args) // Remove the round_start hook until the !wp command is called again
{
	PrintToChatAll(" \x05Cleared spawn weapons");
	UnhookEvent("round_start", EquipPlayers);
}

public void OnMapEnd() // Remove the round_start hook until the !wp command is called again
{
	UnhookEvent("round_start", EquipPlayers);
}