#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "[Logs] Client Command",
    author = "Nek.'a 2x2 | vk.com/nekromio || t.me/sourcepwn",
    description = "Логирование консольных команд игроков",
    version = "1.0.0 100",
    url = "ggwp.site || vk.com/nekromio || t.me/sourcepwn"
};

static const char whitelist[][] = {
    "ak47", "autobuy", "awp", "buy", "buyammo1", "buyammo2",
    "commandmenu", "deagle", "defuser", "drop", "flashbang",
    "g3sg1", "gameui_allowescape", "gameui_preventescape",
    "hegrenade", "joinclass", "joingame", "jointeam",
    "lastinv", "m4a1", "menuselect", "nightvision", "nvgs",
    "quit", "rebuy", "say", "say_team", "scout", "sectorclear",
    "showbriefing", "spec_mode", "spec_next", "spec_prev",
    "teammenu", "use", "usp", "vban", "vesthelm", "vip", "vips",
    "voice", "vu", "xm1014", "throw_twice", "-hook", "+hook", "vmodenable",
    "spec_player",

    // Radio commands (CS:S)
    "coverme", "takepoint", "holdpos", "regroup", "followme",
    "go", "fallback", "sticktog", "getinpos", "stormfront",
    "report", "roger", "enemyspot", "needbackup", "inposition",
    "reportingin", "getout", "negative", "enemydown"
};

public void OnPluginStart()
{
    AddCommandListener(Cmd_Listener);
}

public Action Cmd_Listener(int client, const char[] command, int argc)
{
    if (!IsValidClient(client))
        return Plugin_Continue;

    char steam[32], sIP[16], sFile[PLATFORM_MAX_PATH];
    GetClientAuthId(client, AuthId_Steam2, steam, sizeof(steam));
    GetClientIP(client, sIP, sizeof(sIP)); 

    char args[192], fullCmd[256];
    GetCmdArgString(args, sizeof(args));

    // Комбинируем команду и аргументы
    if (args[0] != '\0')
    {
        Format(fullCmd, sizeof(fullCmd), "%s %s", command, args);
    }
    else
    {
        strcopy(fullCmd, sizeof(fullCmd), command);
    }

    GetLogFilePath(steam, sFile, sizeof(sFile));
    LogToFileEx(sFile, "[%N] (%s) [%s] -> %s", client, steam, sIP, fullCmd);

    if (!IsWhitelisted(command))
    {
        char sDate[16], sDir[PLATFORM_MAX_PATH], sOddFile[PLATFORM_MAX_PATH];
        FormatTime(sDate, sizeof(sDate), "%Y-%m");
        BuildPath(Path_SM, sDir, sizeof(sDir), "logs/details/cmd/%s", sDate);
        if (!DirExists(sDir)) CreateDirectory(sDir, 511);

        BuildPath(Path_SM, sOddFile, sizeof(sOddFile), "logs/details/cmd/%s/oddly.log", sDate);
        LogToFileEx(sOddFile, "[%N] (%s) [%s] -> %s", client, steam, sIP, fullCmd);
    }

    return Plugin_Continue;
}

stock void GetLogFilePath(char[] sSteam, char[] sFile, int maxlen)
{
    char steam[32];
    strcopy(steam, sizeof(steam), sSteam);
    ReplaceString(steam, sizeof(steam), "STEAM_0:0:", "");
    ReplaceString(steam, sizeof(steam), "STEAM_1:0:", "");
    ReplaceString(steam, sizeof(steam), "STEAM_0:1:", "");
    ReplaceString(steam, sizeof(steam), "STEAM_1:1:", "");

    char sDir[PLATFORM_MAX_PATH], sDate[16];
    FormatTime(sDate, sizeof(sDate), "%Y-%m");

    BuildPath(Path_SM, sDir, sizeof(sDir), "logs/details");
    if (!DirExists(sDir)) CreateDirectory(sDir, 511);

    BuildPath(Path_SM, sDir, sizeof(sDir), "logs/details/cmd");
    if (!DirExists(sDir)) CreateDirectory(sDir, 511);

    BuildPath(Path_SM, sDir, sizeof(sDir), "logs/details/cmd/%s", sDate);
    if (!DirExists(sDir)) CreateDirectory(sDir, 511);

    BuildPath(Path_SM, sFile, maxlen, "logs/details/cmd/%s/%s.log", sDate, steam);
}

stock bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client));
}

bool IsWhitelisted(const char[] cmd)
{
    // Проверка на префиксы
    if (cmd[0] == '!' || !StrContains(cmd, "sm_"))
        return true;

    // Выделяем только первую часть команды (до пробела)
    char baseCmd[64];
    BreakString(cmd, baseCmd, sizeof(baseCmd));

    // Проверка по списку
    for (int i = 0; i < sizeof(whitelist); i++)
    {
        if (StrEqual(baseCmd, whitelist[i], false))
            return true;
    }

    return false;
}