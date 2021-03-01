#include <a_samp>
#include <zcmd>
#include <sscanf2>

#define SpeedCheck(%0,%1,%2,%3,%4) floatround(floatsqroot(%4?(%0*%0+%1*%1+%2*%2):(%0*%0+%1*%1) ) *%3*1.6)
#define COLOR_GREY        (0xAFAFAFFF)
#define COLOR_LIGHTBLUE   (0x007FFFFF)

new LimitSpeed[MAX_PLAYERS];

public OnGameModeInit()
{
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	LimitSpeed[playerid] = 0;//Buat Disable Speedlimit setiap kali player login
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		return 1;
	}
	return 0;
}

//Functions
stock GetVehicleSpeed(vehicleid, get3d)
{
	new Float:x, Float:y, Float:z;
	GetVehicleVelocity(vehicleid, x, y, z);
	return SpeedCheck(x, y, z, 100.0, get3d);
}
stock ModifyVehicleSpeed(vehicleid,mph) //Miles Per Hour
{
	new Float:Vx,Float:Vy,Float:Vz,Float:Speed,Float:multiple;
	GetVehicleVelocity(vehicleid,Vx,Vy,Vz);
	Speed = floatsqroot(Vx*Vx + Vy*Vy + Vz*Vz);
	if(Speed > 0)
	{
		multiple = ((mph + Speed * 100) / (Speed * 100));
		return SetVehicleVelocity(vehicleid,Vx*multiple,Vy*multiple,Vz*multiple);
	}
	return 0;
}
public OnPlayerUpdate(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && LimitSpeed[playerid])
	{
	    new a, b, c;
		GetPlayerKeys(playerid, a, b ,c);
	    if(a == 8 && GetVehicleSpeed(GetPlayerVehicleID(playerid), 0) > LimitSpeed[playerid])
	    {
	        new newspeed = GetVehicleSpeed(GetPlayerVehicleID(playerid), 0) - LimitSpeed[playerid];
	    	ModifyVehicleSpeed(GetPlayerVehicleID(playerid), -newspeed);
	    }
	}
	return 1;
}
CMD:speedlimit(playerid, params[])
{
	new string[128], speed;
	if(sscanf(params, "i", speed)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: {FFFFFF}/speedlimit [Max MPH] - /speedlimit 0 -  for Disable");
	if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	    return SendClientMessage(playerid, COLOR_GREY, "ERROR: You must be a Driver!");

	if(speed < 0) return SendClientMessage(playerid, COLOR_GREY, "Invalid MPH speed.");
	LimitSpeed[playerid] = speed;
	if(speed == 0) format(string, sizeof(string), "SERVER: {FFFFFF}You've disabled Speedlimit!", speed);
    else format(string, sizeof(string), "SERVER: {FFFFFF}You have set your speed limit to %d MPH, any vehicle you drive will not go past this limit.", speed);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	return 1;
}
