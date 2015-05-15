#include <tf2>

public Extension:__ext_compctrl = 
{
	name = "CompCtrl",
	file = "compctrl.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

enum WinReason {
	WinReason_None = 0,
	WinReason_All_Points_Captured,
	WinReason_Opponents_Dead,
	WinReason_Flag_Capture_Limit,
	WinReason_Defend_Until_Time_Limit,
	WinReason_Stalemate,
	WinReason_TimeLimit,
	WinReason_WinLimit,
	WinReason_WinDiffLimit
};

enum StalemateReason {
	StalemateReason_Join_Mid,
	StalemateReason_Timer,
	StalemateReason_Server_Timelimit
};

/**
 * @brief				Calls SetWinningTeam in CTFGameRules.
 *
 * @param team			The team that has won.
 * @param reason		The reason why the team is winning.
 * @param forceMapReset	Whether to reset the map (usually after a full round is completed).
 * @param switchTeams	Whether to switch teams.
 * @param dontAddScore	Whether to not score this round.
 * @noreturn
 */
native CompCtrl_SetWinningTeam(TFTeam:team, WinReason:reason, bool:forceMapReset, bool:switchTeams, bool:dontAddScore);

/**
 * @brief				Calls SetStalemate in CTFGameRules.
 *
 * @param reason		The reason why the team is winning.
 * @param forceMapReset	Whether to reset the map (usually after a full round is completed).
 * @param switchTeams	Whether to switch teams.
 * @noreturn
 */
native CompCtrl_SetStalemate(StalemateReason:reason, bool:forceMapReset, bool:switchTeams);

/**
 * @brief				Calls HandleSwitchTeams in CTFGameRules.
 *
 * @noreturn
 */
native CompCtrl_SwitchTeams();

/**
 * @brief				Calls ChangeLevel in IVEngineServer.
 *
 * @param s1			The first map change string.
 * @param s2			The second map change string.
 * @noreturn
 */
native CompCtrl_ChangeLevel(const String:s1[], const String:s2[]);

/**
 * @brief				When SetWinningTeam in CTFGameRules is called by the game.
 *
 * @param team			The team that has won.
 * @param reason		The reason why the team is winning.
 * @param forceMapReset	Whether to reset the map (usually after a full round is completed).
 * @param switchTeams	Whether to switch teams.
 * @param dontAddScore	Whether to not score this round.
 * @return				Plugin_Continue to continue with original values, Plugin_Changed to use new values, Plugin_Handled or Plugin_Stop to stop the game call.
 */
forward Action:CompCtrl_OnSetWinningTeam(&TFTeam:team, &WinReason:reason, &bool:forceMapReset, &bool:switchTeams, &bool:dontAddScore);

/**
 * @brief				When SetStalemate in CTFGameRules is called by the game.
 *
 * @param reason		The reason why the team is winning.
 * @param forceMapReset	Whether to reset the map (usually after a full round is completed).
 * @param switchTeams	Whether to switch teams.
 * @return				Plugin_Continue to continue with original values, Plugin_Changed to use new values, Plugin_Handled or Plugin_Stop to stop the game call.
 */
forward Action:CompCtrl_OnSetStalemate(&StalemateReason:reason, &bool:forceMapReset, &bool:switchTeams);

/**
 * @brief				When HandleSwitchTeams in CTFGameRules is called by the game.
 *
 * @return				Plugin_Continue to allow the team switch, Plugin_Changed or above to prevent the team switch.
 */
forward Action:CompCtrl_OnSwitchTeams();

/**
 * @brief				When RestartTournament in CTFGameRules is called by the game.
 *
 * @return				Plugin_Continue to allow the restart, Plugin_Changed or above to prevent the restart.
 */
forward Action:CompCtrl_OnRestartTournament();

/**
 * @brief				When CheckWinLimit in CTFGameRules is called by the game.
 *
 * @param returnValue	The return value for the function (true for win limit reached, false for not).
 * @return				Plugin_Continue to return the original value, Plugin_Changed or above to use the new value.
 */
forward Action:CompCtrl_OnCheckWinLimit(&bool:returnValue);

/**
 * @brief				When ResetScores in CTFTeam is called by the game.
 *
 * @param team			The team that is having its scores reset.
 * @return				Plugin_Continue to allow the reset, Plugin_Changed or above to prevent the reset.
 */
forward Action:CompCtrl_OnResetTeamScores(TFTeam:team);

/**
 * @brief				When ChangeLevel in IVEngineServer is called by the game.
 *
 * @param s1			The first map change string.
 * @param s2			The second map change string.
 * @noreturn			Plugin_Continue to allow the level change, Plugin_Changed or above to prevent the level change.
 */
forward Action:CompCtrl_OnChangeLevel(const String:s1[], const String:s2[]);