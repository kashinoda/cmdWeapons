#include <sourcemod>
#include <sdktools>
#include <smlib>
#include <cstrike>

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
    { "weapon_ak47", "AK-47", "ak", "1" },
    { "weapon_aug", "AUG", "aug", "1" },
    { "weapon_awp", "AWP", "awp", "1" },
    { "weapon_bizon", "PP-Bizon", "bizon", "1" },
    { "weapon_cz75a", "CZ-75 Auto", "cz", "1" },
    { "weapon_deagle", "Desert Eagle", "deag", "1" },
    { "weapon_elite", "Dual Berettas", "dualies", "1" },
    { "weapon_famas", "FAMAS", "famas", "1" },
    { "weapon_fiveseven", "Five-SeveN", "57", "1" },
    { "weapon_galilar", "Galil AR", "galil", "1" },
    { "weapon_glock", "Glock-18", "glock", "0" },
    { "weapon_hkp2000", "P2000", "p2000", "0" },
    { "weapon_m249", "M249", "m249", "1" },
    { "weapon_m4a1", "M4A4", "m4", "1" },
    { "weapon_m4a1_silencer", "M4A1-S", "m4s", "1" },
    { "weapon_mac10", "MAC-10", "mac10", "1" },
    { "weapon_mag7", "MAG-7", "mag7", "1" },
    { "weapon_mp7", "MP7", "mp7", "1" },
    { "weapon_mp9", "MP9", "mp9", "1" },
    { "weapon_negev", "Negev", "negev", "1" },
    { "weapon_nova", "Nova", "nova", "1" },
    { "weapon_p250", "P250", "p250", "1" },
    { "weapon_p90", "P90", "p90", "1" },
    { "weapon_sawedoff", "Sawed-Off", "shorty", "1" },
    { "weapon_sg556", "SG 553", "sg", "1" },
    { "weapon_ssg08", "SSG 08", "scout", "1" },
    { "weapon_tec9", "Tec-9", "tec9", "1" },
    { "weapon_ump45", "UMP-45", "ump", "1" },
    { "weapon_usp_silencer", "USP-S", "usp", "0" },
    { "weapon_xm1014", "XM1014", "xm", "1" },
    { "weapon_revolver", "R8 Revolver", "r8", "1" },
    { "weapon_mp5sd", "MP5", "mp5", "1" },
    { "", "Knife", "knife", "1" },
    { "weapon_taser", "Zeus", "zeus", "1" },
};

char sItems[][][] = 
{
    { "weapon_snowball", "SNOWBALLS", "snowball" },
    { "weapon_hegrenade", "GRENADES", "grenade" },
    { "weapon_smokegrenade", "SMOKES", "smoke" },
    { "weapon_flashbang", "FLASHBANGS", "flash" },
    { "weapon_tagrenade", "TAG GRENADS", "tag" },
    { "weapon_decoy", "DECOYS", "decoy" },
    { "weapon_breachcharge", "BREACH CHARGES", "charge" },
    { "weapon_bumpmine", "BUMP MINES", "mine" },
};

bool bValidSelection;
bool bSelectionActive;

int iSelectedWeapon;
int iSelectionType;

bool bOneTapEnabled;
bool bOneTapForceUnhook;

int iDecoyArray[MAXPLAYERS + 1][999];
int iSnowballArray[MAXPLAYERS + 1][999];
int iGrenadeArray[MAXPLAYERS + 1][999];
int iSmokeArray[MAXPLAYERS + 1][999];
int iFlashArray[MAXPLAYERS + 1][999];
int iTagArray[MAXPLAYERS + 1][999];

int iItemAmountArray[sizeof(sItems)][999];

bool bItemSelectionActive;
bool bValidItemSelection;





public void OnPluginStart()
{
    RegAdminCmd("wp", CMD_WP, ADMFLAG_GENERIC, "");
    RegAdminCmd("wpclear", CMD_WPClear, ADMFLAG_GENERIC, "");
    RegAdminCmd("onetap", CMD_OTap, ADMFLAG_GENERIC, "");
    RegAdminCmd("nd", CMD_Nades, ADMFLAG_GENERIC, "");
    RegAdminCmd("rr", CMD_RR, ADMFLAG_GENERIC, "");
    RegAdminCmd("t", CMD_T, ADMFLAG_GENERIC, "");
}

public Action CMD_T(int client, int args)
{
    int test = sizeof(sWeapons);
    PrintToChatAll(" %i",test);

}

public Action CMD_RR(int client, int args)
{
    CS_TerminateRound(0.5, CSRoundEnd_Draw);
    PrintToChatAll("  \x01[\x05ENDING ROUND \x0BDRAW\x01] \x10~");

}

public Action CMD_OTap(int client, int args)
{
    if (bValidSelection == false)
    {
        PrintToChatAll(" \x07FAILED \x05Please choose a weapon first with \x09!wp <gun>");
    }
    else
    {
        if (bOneTapEnabled == false)
        {
            bOneTapEnabled = true;
            PrintToChatAll(" \x10~ \x01[\x07GUN MODE\x01] \x10~ \x01[\x05ONE TAP MODE ENABLED \x0BNext Round!\x01] \x10~");
        }

        else
        {
            PrintToChatAll(" \x10~ \x01[\x07GUN MODE\x01] \x10~ \x01[\x05ONE TAP MODE DISABLED \x0BNext Round!\x01] \x10~");
            bOneTapEnabled = false;
            bOneTapForceUnhook = true;
        }
    }

}

public Action CMD_WPClear(int client, int args)
{
    PrintToChatAll(" \x05Weapon selection cleared!");
    bOneTapForceUnhook = true;
    bSelectionActive = false;
    bItemSelectionActive = false;

    int iItemCount = sizeof(sItems);
    for (int iItemLookup = 0; iItemLookup < iItemCount; iItemLookup++)
    {
        iItemAmountArray[iItemLookup][1] = 0;

    }

}

public void OnMapStart()
{
    bOneTapForceUnhook = true;
    bSelectionActive = false;
    bItemSelectionActive = false;

    int iItemCount = sizeof(sItems);
    for (int iItemLookup = 0; iItemLookup < iItemCount; iItemLookup++)
    {
        iItemAmountArray[iItemLookup][1] = 0;

    }
}

public Action CMD_WP(int client, int args)
{
    char sCmd[20];
    GetCmdArg(1, sCmd, sizeof(sCmd));
    int iWeaponCount = sizeof(sWeapons);

    if (StrEqual("randomeach",sCmd))
    {
        iSelectionType = 2;
        bSelectionActive = true;
        HookEvent("round_start", EquipPlayers);
        PrintToChatAll(" \x10~ \x01[\x07GUN MODE\x01] \x10~ \x01[\x05RANDOM GUN EACH \x0BNext Round!\x01] \x10~");
    }

    else
    {

    if (StrEqual("randomall",sCmd))
    {
        iSelectionType = 3;
        bSelectionActive = true;
        HookEvent("round_start", EquipPlayers);
        PrintToChatAll(" \x10~ \x01[\x07GUN MODE\x01] \x10~ \x01[\x05RANDOM GUN ALL \x0BNext Round!\x01] \x10~");
    }

    else
    {
    // Iterate through the array and see if any weapons match the command argument

    for (int iWeaponLookup = 0; iWeaponLookup < iWeaponCount; iWeaponLookup++)
    {
        if (StrEqual(sWeapons[iWeaponLookup][2], sCmd))
        {
            PrintToChatAll(" \x10~ \x01[\x07GUN MODE\x01] \x10~ \x01[\x05%s \x0BNext Round!\x01] \x10~", sWeapons[iWeaponLookup][1]);
            iSelectedWeapon = iWeaponLookup;
            iSelectionType = 1;
            bSelectionActive = true;
            bValidSelection = true;
            HookEvent("round_start", EquipPlayers);
        }
    }

    if (bValidSelection == false)
    {
        PrintToChatAll(" \x07Cannot find \x09%s", sCmd);
        PrintToChatAll(" Usage: \x08!wp <gun>\x01 - \x05awp, scout, ak, m4, m4s, sg, aug, deag, usp, glock, galil, famas, mac10, mp9, mp7, ump, bizon, p90, mp5, m249, mag7, negev, nova, shorty, xm, 57, dualies, p250, tec9, cz, r8, p2000, \x01 OR \x09randomeach, randomall");
 
    }
    }
    }
}

public void EquipPlayers(Event event, const char[] name, bool dontBroadcast)
{
    if (bSelectionActive == false)
    {
        // Do Nothing
    }

    else 
    {
    int iRandom = GetRandomInt(0,sizeof(sWeapons) - 1);
  
    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (IsClientConnected(iClient) && IsClientInGame(iClient))
        {
            // Iterate though primary and secondary weapon slots (0=Primary, 1=Secondary, 2=Knife, 3=Grenade, 4=C4)
            for (int iSlot = 0; iSlot < 2; iSlot++)
            {
                int iEntity;

                // Grab the entity value for every valid client and every non-empty weapon slot

                while ((iEntity = GetPlayerWeaponSlot(iClient, iSlot)) != -1)
                {
                    // Remove that entity from the client then kill it

                    RemovePlayerItem(iClient, iEntity);
                    AcceptEntityInput(iEntity, "Kill");
                }
            }

            if  (iSelectionType == 1)
            {
                if (bOneTapEnabled == true)
                {
                    Client_GiveWeaponAndAmmo(iClient, sWeapons[iSelectedWeapon][0], _, 0, _, 1);
                }
                else
                {
                    GivePlayerItem(iClient, sWeapons[iSelectedWeapon][0], 0);
 //                   GivePlayerItem(iClient, "item_defuser", 0);
                }
                
                SetEntProp(iClient, Prop_Data, "m_ArmorValue", 100, 1);

                if (StrEqual(sWeapons[iSelectedWeapon][3], "0"))
                {
                    SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 0);
                }

                else
                {
                    SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
                }
            }

            if  (iSelectionType == 2)
            {
                if (bOneTapEnabled == true)
                {
                    Client_GiveWeaponAndAmmo(iClient, sWeapons[GetRandomInt(0,sizeof(sWeapons) - 1)][0], _, 0, _, 1);
                }
                else
                {
                    GivePlayerItem(iClient, sWeapons[GetRandomInt(0,sizeof(sWeapons) - 1)][0], 0);
                }
                
                SetEntProp(iClient, Prop_Data, "m_ArmorValue", 100, 1);
                SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
            }

            if  (iSelectionType == 3)
            {
                if (bOneTapEnabled == true)
                {
                    Client_GiveWeaponAndAmmo(iClient, sWeapons[iRandom][0], _, 0, _, 1);
                }
                else
                {
                    GivePlayerItem(iClient, sWeapons[iRandom][0], 0);
                }
                SetEntProp(iClient, Prop_Data, "m_ArmorValue", 100, 1);

                if (StrEqual(sWeapons[iRandom][3], "0"))
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

    if (bOneTapEnabled == true)
    {
        HookEvent("weapon_fire", EventOTap);
        bOneTapForceUnhook = false;

    }
    else
    {
        UnhookEvent("weapon_fire", EventOTap);
        bOneTapForceUnhook = true;
    } 
    }
}

public void EventOTap(Event event, const char[] name, bool dontBroadcast)
{
    if (bOneTapForceUnhook == false)
    {
        int iUserID = GetEventInt(event, "userid");
        int iClient = GetClientOfUserId(iUserID);        
        CreateTimer(0.2, GiveAmmo, iClient);         
    }
      
}

public Action GiveAmmo(Handle timer, any client)
{      
    for (int iSlot = 0; iSlot < 2; iSlot++)
    {
        int iEntity;
        if ((iEntity = GetPlayerWeaponSlot(client, iSlot)) != -1)
        {
            char sWeapon[64];
            GetEntityClassname(iEntity, sWeapon, sizeof(sWeapon)); 
 //           Client_GiveWeaponAndAmmo(client, sWeapon, _, 0, _, 1);  
            Client_SetWeaponPlayerAmmo(client, sWeapon, 1);
            Client_SetWeaponClipAmmo(client, sWeapon, 0);
        }
    }
}  

public Action CMD_Nades(int client, int args)
{
    if(args < 1)
    {
       PrintToChatAll(" Usage: \x08!item <item> <amount>\x01 - \x05grenade, smoke, flash, decoy, charge, mine, tag, snowball, \x01 OR \x09randomeach, randomall");     
    }
    else
    {
    ServerCommand("ammo_grenade_limit_breachcharge 999; ammo_grenade_limit_bumpmine 999; ammo_grenade_limit_default 999; ammo_grenade_limit_flashbang 999; ammo_grenade_limit_snowballs 999; ammo_grenade_limit_total 9999; ammo_item_limit_healthshot 999");     
    char sCmd[20];
    GetCmdArg(1, sCmd, sizeof(sCmd));
    char sCmd2[10];
    GetCmdArg(2, sCmd2,sizeof(sCmd2));
    int iAmount = StringToInt(sCmd2);
    if (iAmount > 250)
    {
        iAmount = 250;
    }
    int iItemCount = sizeof(sItems);
    for (int iItemLookup = 0; iItemLookup < iItemCount; iItemLookup++)
    {
        if (StrEqual(sItems[iItemLookup][2], sCmd))
        {
            PrintToChatAll(" \x10~ \x01[\x07ITEM MODE\x01] \x10~ \x01[\x09%i \x05%s \x0BNext Round!\x01] \x10~", iAmount, sItems[iItemLookup][1]);
            iItemAmountArray[iItemLookup][1] = iAmount;
            bItemSelectionActive = true;
            bValidItemSelection = true;

            HookEvent("round_start", EquipPlayerItems);
        }
    }

    if (bValidItemSelection == false)
    {
        PrintToChatAll(" \x07Cannot find \x09%s", sCmd);
        PrintToChatAll(" Usage: \x08!item <item> <amount>\x01 - \x05grenade, smoke, flash, decoy, charge, mine, tag, snowball, \x01 OR \x09randomeach, randomall");
 
    }
    }
}

public void EquipPlayerItems(Event event, const char[] name, bool dontBroadcast)
{
    if (bItemSelectionActive == false)
    {
        // Do Nothing
    }
    else
    {
    for (int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (IsClientConnected(iClient) && IsClientInGame(iClient))
        {
            int iItemCount = sizeof(sItems);
            for (int iItemLookup = 0; iItemLookup < iItemCount; iItemLookup++)
            {
                Client_RemoveWeapon(iClient, sItems[iItemLookup][0]);
            }
            if (iItemAmountArray[7][1] == 0)
            {
                // Do Nothing
            }
            else
            {
                Client_GiveWeaponAndAmmo(iClient, "weapon_bumpmine", _, 0, _, iItemAmountArray[7][1]);                
            }
            if (iItemAmountArray[6][1] == 0)
            {
                // Do Nothing
            }
            else
            {
                Client_GiveWeaponAndAmmo(iClient, "weapon_breachcharge", _, 0, _, iItemAmountArray[6][1]);               
            }
            iDecoyArray[iClient][1] = 0;
            CreateTimer(0.1, GiveDecoys, iClient, TIMER_REPEAT);
            iSnowballArray[iClient][1] = 0;
            CreateTimer(0.1, GiveSnowballs, iClient, TIMER_REPEAT);
            iGrenadeArray[iClient][1] = 0;
            CreateTimer(0.1, GiveGrenades, iClient, TIMER_REPEAT); 
            iFlashArray[iClient][1] = 0;
            CreateTimer(0.1, GiveFlashes, iClient, TIMER_REPEAT);
            iSmokeArray[iClient][1] = 0;
            CreateTimer(0.1, GiveSmokes, iClient, TIMER_REPEAT);
            iTagArray[iClient][1] = 0;
            CreateTimer(0.1, GiveTags, iClient, TIMER_REPEAT);   
        }
    }
    }
}


public Action GiveDecoys(Handle timer, any client)
{   
    if (iDecoyArray[client][1] == iItemAmountArray[5][1])
    {    
        return Plugin_Stop;
    }
    if (bItemSelectionActive == false)
    {    
        return Plugin_Stop;
    }
    GivePlayerItem(client, "weapon_decoy", 0);
    iDecoyArray[client][1] ++;
    return Plugin_Continue;
}  

public Action GiveSnowballs(Handle timer, any client)
{   
    if (iSnowballArray[client][1] == iItemAmountArray[0][1])
    {    
        return Plugin_Stop;
    }
    GivePlayerItem(client, "weapon_snowball", 0);
    iSnowballArray[client][1] ++;
    return Plugin_Continue;
}  

public Action GiveGrenades(Handle timer, any client)
{   
    if (iGrenadeArray[client][1] == iItemAmountArray[1][1])
    {    
        return Plugin_Stop;
    }
    GivePlayerItem(client, "weapon_hegrenade", 0);
    iGrenadeArray[client][1] ++;
    return Plugin_Continue;
}  

public Action GiveFlashes(Handle timer, any client)
{   
    if (iFlashArray[client][1] == iItemAmountArray[3][1])
    {    
        return Plugin_Stop;
    }
    GivePlayerItem(client, "weapon_flashbang", 0);
    iFlashArray[client][1] ++;
    return Plugin_Continue;
}  


public Action GiveSmokes(Handle timer, any client)
{   
    if (iSmokeArray[client][1] == iItemAmountArray[2][1])
    {    
        return Plugin_Stop;
    }
    GivePlayerItem(client, "weapon_smokegrenade", 0);
    iSmokeArray[client][1] ++;
    return Plugin_Continue;
}  


public Action GiveTags(Handle timer, any client)
{   
    if (iTagArray[client][1] == iItemAmountArray[4][1])
    {    
        return Plugin_Stop;
    }
    GivePlayerItem(client, "weapon_tagrenade", 0);
    iTagArray[client][1] ++;
    return Plugin_Continue;
}  

