#include <sourcemod> 
#include <sdktools> 
#include <smlib> 

#pragma semicolon 1
#pragma tabsize 0
#pragma newdecls required

public Plugin myinfo = 
{
    name = "EZ Weapons",
    author = "Kashinoda",
    description = "Set spawn guns using !wp <gun>",
    url = "https://github.com/kashinoda/",
};

// Weapon Array [0] Item Name, [1] Formatted name, [2] Lookup name, [3] Include Hemlet

char sWeapons[][][] = 
{
    {"weapon_ak47", "AK-47", "ak", "1"},
    {"weapon_aug", "AUG", "aug", "1"},
    {"weapon_awp", "AWP", "awp", "1"},
    {"weapon_bizon", "PP-Bizon", "bizon", "1"},
    {"weapon_cz75a", "CZ-75 Auto", "cz", "1"},
    {"weapon_deagle", "Desert Eagle", "deag", "1"},
    {"weapon_elite", "Dual Berettas", "dualies", "1"},
    {"weapon_famas", "FAMAS", "famas", "1"},
    {"weapon_fiveseven", "Five-SeveN", "57", "1"},
    {"weapon_galilar", "Galil AR", "galil", "1"},
    {"weapon_glock", "Glock-18", "glock", "0"},
    {"weapon_hkp2000", "P2000", "p2000", "0"},
    {"weapon_m249", "M249", "m249", "1"},
    {"weapon_m4a1", "M4A4", "m4", "1"},
    {"weapon_m4a1_silencer", "M4A1-S", "m4s", "1"},
    {"weapon_mac10", "MAC-10", "mac10", "1"},
    {"weapon_mag7", "MAG-7", "mag7", "1"},
    {"weapon_mp7", "MP7", "mp7", "1"},
    {"weapon_mp9", "MP9", "mp9", "1"},
    {"weapon_negev", "Negev", "negev", "1"},
    {"weapon_nova", "Nova", "nova", "1"},
    {"weapon_p250", "P250", "p250", "1"},
    {"weapon_p90", "P90", "p90", "1"},
    {"weapon_sawedoff", "Sawed-Off", "shorty", "1"},
    {"weapon_sg556", "SG 553", "sg", "1"},
    {"weapon_ssg08", "SSG 08", "scout", "1"},
    {"weapon_tec9", "Tec-9", "tec9", "1"},
    {"weapon_ump45", "UMP-45", "ump", "1"},
    {"weapon_usp_silencer", "USP-S", "usp", "0"},
    {"weapon_xm1014", "XM1014", "xm", "1"},
    {"weapon_revolver", "R8 Revolver", "r8", "1"},
    {"weapon_mp5sd", "MP5", "mp5", "1"},
};

bool bValidSelection;
int iSelectedWeapon;

public void OnPluginStart() 
{ 
	RegAdminCmd("wp",	CMD_WP,	ADMFLAG_GENERIC,	""); 
	RegAdminCmd("wplist",	CMD_WPList,	ADMFLAG_GENERIC,	""); 
	RegAdminCmd("wpclear",	CMD_WPClear,	ADMFLAG_GENERIC,	""); 
} 

public Action CMD_WP (int client, int args)
{
    char sCmd[20]; 
    GetCmdArg(1, sCmd, sizeof(sCmd)); 
    int iWeaponCount = sizeof(sWeapons); 
    bValidSelection = false; 

    // Iterate through the array and see if any weapons match the command argument

    for (int iWeaponLookup = 0; iWeaponLookup < iWeaponCount; iWeaponLookup++) 
    {
        if (StrEqual(sWeapons[iWeaponLookup][2], sCmd)) 
        {
    	   PrintToChatAll(" \x10~ \x01[\x07GUN MODE\x01] \x10~ \x01[\x05%s \x0BNext Round!\x01] \x10~", sWeapons[iWeaponLookup][1]); 
    	   iSelectedWeapon = iWeaponLookup; 
    	   bValidSelection = true; 
    	   HookEvent("round_start", EquipPlayers); 
    	}
    }

    if (bValidSelection == false) 
    {        
        PrintToChatAll(" \x05Cannot find %s, type \x0B!wplist \x05to see correct syntax", sCmd);
    }
}

public void EquipPlayers(Event event, const char[] name, bool dontBroadcast) 
{
  	for (int iClient = 1; iClient <= MaxClients; iClient++) 
    {
        	if (IsClientConnected(iClient) && IsClientInGame(iClient)) 
            {
                // Iterate though primary and secondary weapon slots (0=Primary, 1=Secondary, 2=Knife, 3=Grenade, 4=C4)

       			for(int iSlot = 0; iSlot < 2; iSlot++) 
                { 
            		int iEntity;

                    // Grab the entity value for every valid client and every non-empty weapon slot

             		while((iEntity = GetPlayerWeaponSlot(iClient, iSlot)) != -1) 
                    {
                        // Remove that entity from the client then kill it

                		RemovePlayerItem(iClient, iEntity); 
                		AcceptEntityInput(iEntity, "Kill");
            		} 
        		}

       			GivePlayerItem(iClient, sWeapons[iSelectedWeapon][0], 0);
				GivePlayerItem(iClient, "weapon_flashbang", 0);
				GivePlayerItem(iClient, "weapon_flashbang", 0);
				SetEntProp(iClient, Prop_Data, "m_ArmorValue", 100, 1 );

				if (StrEqual(sWeapons[iSelectedWeapon][3], "0")) 
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

public Action CMD_WPList (int client, int args) 
{
	PrintToChatAll(" \x07Usage: \x01!wp <gun>\x05 awp, scout, ak, m4, m4s, sg, aug, deag, usp, glock, galil, famas, mac10, mp9, mp7, ump, bizon, p90, mp5, m249, mag7, negev, nova, shorty, xm, 57, dualies, p250, tec9, cz, r8, p2000"); 
}

public Action CMD_WPClear (int client, int args) 
{
	PrintToChatAll(" \x05Cleared spawn weapons");
	UnhookEvent("round_start", EquipPlayers);
}

public void OnMapEnd() 
{
	UnhookEvent("round_start", EquipPlayers);
}

