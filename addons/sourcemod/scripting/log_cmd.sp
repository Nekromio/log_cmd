#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name = "[Logs] Client Command",
    author = "Nek.'a 2x2 | vk.com/nekromio || t.me/sourcepwn",
    description = "Логирование консольных команд игроков",
    version = "1.0.0 101",
    url = "ggwp.site || vk.com/nekromio || t.me/sourcepwn"
};

ArrayList hWhitelist;

public void OnPluginStart()
{
    hWhitelist = new ArrayList(ByteCountToCells(128));
    LoadWhitelistFromFile();

    AddCommandListener(Cmd_Listener);
}

void LoadWhitelistFromFile()
{
    char sDir[PLATFORM_MAX_PATH], path[PLATFORM_MAX_PATH];

    BuildPath(Path_SM, sDir, sizeof(sDir), "data/logs");

    if (!DirExists(sDir))
        CreateDirectory(sDir, 511);

    BuildPath(Path_SM, path, sizeof(path), "data/logs/cmd_whitelist.ini");

    if (!FileExists(path))
    {
        LogError("Файл whitelist не найден: %s", path);
        return;
    }

    File file = OpenFile(path, "r");
    if (file == null)
    {
        LogError("Не удалось открыть файл whitelist: %s", path);
        return;
    }

    char line[64];
    while (!IsEndOfFile(file) && ReadFileLine(file, line, sizeof(line)))
    {
        TrimString(line);
        if (line[0] == '\0' || line[0] == '/' || line[0] == '#')
            continue;

        hWhitelist.PushString(line);
    }

    delete file;
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
    LogToFileOnly(sFile, "[%N] (%s) [%s] -> %s", client, steam, sIP, fullCmd);

    if (!IsWhitelisted(command))
    {
        char sDate[16], sDir[PLATFORM_MAX_PATH], sOddFile[PLATFORM_MAX_PATH];
        FormatTime(sDate, sizeof(sDate), "%Y-%m");
        BuildPath(Path_SM, sDir, sizeof(sDir), "logs/details/cmd/%s", sDate);
        if (!DirExists(sDir)) CreateDirectory(sDir, 511);

        BuildPath(Path_SM, sOddFile, sizeof(sOddFile), "logs/details/cmd/%s/oddly.log", sDate);
        LogToFileOnly(sOddFile, "[%N] (%s) [%s] -> %s", client, steam, sIP, fullCmd);
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
    return 0 < client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client);
}

bool IsWhitelisted(const char[] cmd)
{
    if (cmd[0] == '!' || !StrContains(cmd, "sm_"))
        return true;

    char baseCmd[64];
    BreakString(cmd, baseCmd, sizeof(baseCmd));

    for (int i = 0; i < hWhitelist.Length; i++)
    {
        char entry[64];
        hWhitelist.GetString(i, entry, sizeof(entry));

        if (StrEqual(baseCmd, entry, false))
            return true;
    }

    return false;
}

public void LogToFileOnly(const char[] file, const char[] format, any ...)
{
    char buffer[512];
    VFormat(buffer, sizeof(buffer), format, 3);

    char sDate[32];
    FormatTime(sDate, sizeof(sDate), "%Y:%m:%d %H:%M:%S");

    char final[600];
    Format(final, sizeof(final), "%s | %s", sDate, buffer);

    File f = OpenFile(file, "a");
    if (f != null)
    {
        WriteFileLine(f, final);
        delete f;
    }
    else
    {
        LogError("Failed to open file: %s", file);
    }
}