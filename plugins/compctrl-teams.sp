#include <sourcemod>
#include <sdktools_gamerules>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>

new Handle:g_MinTeamPlayers = INVALID_HANDLE;
new Handle:g_MaxTeamPlayers = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "CompCtrl Team Management",
	author = "Forward Command Post",
	description = "a plugin to manage teams in tournament mode",
	version = "0.0.0",
	url = "http://github.com/fwdcp/CompCtrl/"
};

public OnPluginStart() {
	g_MinTeamPlayers = CreateConVar("compctrl_team_players_min", "0", "the minimum number of players a team is required to play with (0 for no limit)", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_PLUGIN, true, 0.0);
	g_MaxTeamPlayers = CreateConVar("compctrl_team_players_max", "0", "the maximum number of players a team is required to play with (0 for no limit)", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_PLUGIN, true, 0.0);
	
	RegConsoleCmd("sm_ready", Command_ReadyPlayer);
	RegConsoleCmd("sm_unready", Command_UnreadyPlayer);
	
	RegConsoleCmd("sm_teamready", Command_ReadyTeam);
	RegConsoleCmd("sm_teamunready", Command_UnreadyTeam);
	AddCommandListener(Command_ChangeTeamReady, "tournament_readystate");
	
	RegConsoleCmd("sm_teamname", Command_SetTeamName);
	AddCommandListener(Command_ChangeTeamName, "tournament_teamname");
}

public Action:Command_ReadyPlayer(client, args) {
	if (!IsClientConnected(client) || !IsClientInGame(client) || !(TFTeam:GetClientTeam(client) == TFTeam_Blue || TFTeam:GetClientTeam(client) == TFTeam_Red)) {
		ReplyToCommand(client, "You cannot ready yourself!");
		return Plugin_Stop;
	}
	
	if (GameRules_GetProp("m_bPlayerReady", 1, client) == 1) {
		return Plugin_Handled;
	}
	
	GameRules_SetProp("m_bPlayerReady", 1, 1, client, true);
	
	decl String:name[255];
	GetClientName(client, name, sizeof(name));
	
	CPrintToChatAllEx(client, "{teamcolor}%s{default} changed player state to {olive}Ready{default}", name);
	
	new String:classSound[32] = "";
	
	switch (TF2_GetPlayerClass(client)) {
		case TFClass_Scout: {
			classSound = "Scout.Ready";
		}
		case TFClass_Soldier: {
			classSound = "Soldier.Ready";
		}
		case TFClass_Pyro: {
			classSound = "Pyro.Ready";
		}
		case TFClass_DemoMan: {
			classSound = "Demoman.Ready";
		}
		case TFClass_Heavy: {
			classSound = "Heavy.Ready";
		}
		case TFClass_Engineer: {
			classSound = "Engineer.Ready";
		}
		case TFClass_Medic: {
			classSound = "Medic.Ready";
		}
		case TFClass_Sniper: {
			classSound = "Sniper.Ready";
		}
		case TFClass_Spy: {
			classSound = "Spy.Ready";
		}
	}
	
	if (!StrEqual(classSound, "")) {
		new Handle:soundBroadcast;
		
		soundBroadcast = CreateEvent("teamplay_broadcast_audio");
		if (soundBroadcast != INVALID_HANDLE) {
			SetEventInt(soundBroadcast, "team", _:TFTeam_Blue);
			SetEventString(soundBroadcast, "sound", classSound);
			SetEventInt(soundBroadcast, "additional_flags", 0);
			FireEvent(soundBroadcast);
		}
		
		soundBroadcast = CreateEvent("teamplay_broadcast_audio");
		if (soundBroadcast != INVALID_HANDLE) {
			SetEventInt(soundBroadcast, "team", _:TFTeam_Red);
			SetEventString(soundBroadcast, "sound", classSound);
			SetEventInt(soundBroadcast, "additional_flags", 0);
			FireEvent(soundBroadcast);
		}
	}
	
	return Plugin_Handled;
}

public Action:Command_UnreadyPlayer(client, args) {
	if (!IsClientConnected(client) || !IsClientInGame(client) || !(TFTeam:GetClientTeam(client) == TFTeam_Blue || TFTeam:GetClientTeam(client) == TFTeam_Red)) {
		ReplyToCommand(client, "You cannot unready yourself!");
		return Plugin_Stop;
	}
	
	if (GameRules_GetProp("m_bPlayerReady", 1, client) == 0) {
		return Plugin_Handled;
	}
	
	GameRules_SetProp("m_bPlayerReady", 0, 1, client, true);
	
	decl String:name[255];
	GetClientName(client, name, sizeof(name));
	
	CPrintToChatAllEx(client, "{teamcolor}%s{default} changed player state to {olive}Not Ready{default}", name);
	
	return Plugin_Handled;
}
public Action:Command_ReadyTeam(client, args) {
	if (!IsClientConnected(client) || !IsClientInGame(client) || !(TFTeam:GetClientTeam(client) == TFTeam_Blue || TFTeam:GetClientTeam(client) == TFTeam_Red)) {
		ReplyToCommand(client, "You cannot ready your team!");
		return Plugin_Stop;
	}
	
	FakeClientCommand(client, "tournament_readystate 1");
	
	return Plugin_Handled;
}

public Action:Command_UnreadyTeam(client, args) {
	if (!IsClientConnected(client) || !IsClientInGame(client) || !(TFTeam:GetClientTeam(client) == TFTeam_Blue || TFTeam:GetClientTeam(client) == TFTeam_Red)) {
		ReplyToCommand(client, "You cannot unready your team!");
		return Plugin_Stop;
	}
	
	FakeClientCommand(client, "tournament_readystate 0");
	
	return Plugin_Handled;
}

public Action:Command_ChangeTeamReady(client, const String:command[], argc) {
	if (!IsClientConnected(client) || !IsClientInGame(client) || !(TFTeam:GetClientTeam(client) == TFTeam_Blue || TFTeam:GetClientTeam(client) == TFTeam_Red)) {
		ReplyToCommand(client, "You cannot change your team ready state!");
		return Plugin_Stop;
	}
	
	decl String:arg[16];
	
	GetCmdArg(1, arg, sizeof(arg));
	
	new bool:ready = bool:StringToInt(arg);
	
	if (ready) {
		new team = GetClientTeam(client);
		
		new teamPlayers;
		new teamPlayersReady;
		
		for (new i = 1; i < MaxClients; i++) {
			if (!IsClientConnected(i) || !IsClientInGame(i) || GetClientTeam(i) != team) {
				continue;
			}
			
			teamPlayers++;
			
			if (GameRules_GetProp("m_bPlayerReady", 1, i) == 1) {
				teamPlayersReady++;
			}
		}
		
		new minPlayers = GetConVarInt(g_MinTeamPlayers);
		new maxPlayers = GetConVarInt(g_MaxTeamPlayers);
		
		if (minPlayers != 0 && teamPlayers < minPlayers) {
			PrintToChat(client, "You cannot ready your team because it has %i players, which is less than the %i minimum players required to play.", teamPlayers, minPlayers);
			return Plugin_Stop;
		}
		else if (maxPlayers != 0 && teamPlayers > maxPlayers) {
			PrintToChat(client, "You cannot ready your team because it has %i players, which is more than the %i maximum players allowed to play.", teamPlayers, maxPlayers);
			return Plugin_Stop;
		}
		else if (teamPlayersReady < teamPlayers) {
			PrintToChat(client, "You cannot ready your team because %i players on it are not ready.", teamPlayers - teamPlayersReady);
			return Plugin_Stop;
		}
		else {
			return Plugin_Continue;
		}
	}
	else {
		return Plugin_Continue;
	}
}

public Action:Command_SetTeamName(client, args) {
	if (!IsClientConnected(client) || !IsClientInGame(client) || !(TFTeam:GetClientTeam(client) == TFTeam_Blue || TFTeam:GetClientTeam(client) == TFTeam_Red)) {
		ReplyToCommand(client, "You cannot set your team name!");
		return Plugin_Stop;
	}
	
	decl String:arg[256];
	GetCmdArg(1, arg, sizeof(arg));
	
	FakeClientCommand(client, "tournament_teamname \"%s\"", arg);
	
	return Plugin_Handled;
}

public Action:Command_ChangeTeamName(client, const String:command[], argc) {
	if (!IsClientConnected(client) || !IsClientInGame(client) || !(TFTeam:GetClientTeam(client) == TFTeam_Blue || TFTeam:GetClientTeam(client) == TFTeam_Red)) {
		ReplyToCommand(client, "You cannot change your team name!");
		return Plugin_Stop;
	}
	
	decl String:arg[256];
	GetCmdArg(1, arg, sizeof(arg));
	
	new TFTeam:team = TFTeam:GetClientTeam(client);
	
	if (team == TFTeam_Blue) {
		new Handle:name = FindConVar("mp_tournament_blueteamname");
		SetConVarString(name, arg, true);
	}
	else if (team == TFTeam_Red) {
		new Handle:name = FindConVar("mp_tournament_redteamname");
		SetConVarString(name, arg, true);
	}
	
	new Handle:nameChange = CreateEvent("tournament_stateupdate");
	
	if (nameChange != INVALID_HANDLE) {
		SetEventInt(nameChange, "userid", client);
		SetEventBool(nameChange, "namechange", true);
		SetEventString(nameChange, "newname", arg);
		FireEvent(nameChange);
	}
	
	return Plugin_Handled;
}