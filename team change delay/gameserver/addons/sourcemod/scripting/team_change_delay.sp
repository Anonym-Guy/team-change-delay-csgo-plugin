#include <sourcemod>
#include <sdktools>
#include <autoexecconfig>

ConVar delay_time;
ConVar hint_message;
ConVar message;
ConVar prefix;
ConVar sound;


public Plugin myinfo = 
{
	name = "Team Change Delay",
	author = "Fraq",
	description = "Delay between team changes",
	version = "1.0"
};

public void OnPluginStart()
{
    AddCommandListener(Command_JoinTeam, "jointeam");
    AutoExecConfig_SetFile("team_change_delay");
    delay_time= AutoExecConfig_CreateConVar("delay_time", "5", "Time delay between team changes in seconds");
    hint_message= AutoExecConfig_CreateConVar("hint_message", "yes", "To have the hint message turned on or off");
    message = AutoExecConfig_CreateConVar("message", "yes", "To turn the chat message on or off");
    prefix  = AutoExecConfig_CreateConVar("plugin_chat_prefix", "TeamChange", "Prefix that will before messages, if you have enabled chat messages");
    sound  = AutoExecConfig_CreateConVar("sound_effect", "yes", "Sound effect when the player clicks on the team and the time has not yet elapsed");
    AutoExecConfig_ExecuteFile();
}

public OnMapStart(){
	AddFileToDownloadsTable("sound/effect/effect.mp3");
	PrecacheSound("effect/effect.mp3",true);
}

bool changed[MAXPLAYERS + 1];

public OnClientPutInServer(int client){
	changed[client] = false;
}

public Action timer(Handle Timer,int userid){
	int client = GetClientOfUserId(userid);
	changed[client] = false;
}


public Action Command_JoinTeam(int client, char[] command, int args)
{
    if (changed[client] == false)
	{	
        changed[client] = true;
	}

	else if (changed[client] == true) 
	{	
		float time;
		char text[99];
		char is_hint_message_on[4];
		char is_message_on[4];
		char chat_prefix[99];
		char is_sound_on[4];

		delay_time.GetString(text,sizeof(text));
		message.GetString(is_message_on,sizeof(is_message_on));
		prefix.GetString(chat_prefix,sizeof(chat_prefix));
		sound.GetString(is_sound_on,sizeof(is_sound_on));
		time = delay_time.FloatValue;
		hint_message.GetString(is_hint_message_on, sizeof(is_hint_message_on))
		
		if (StrEqual("yes", is_sound_on))
		{
			EmitSoundToClient(client,"effect/effect.mp3");
		}

		if (StrEqual("yes", is_hint_message_on))
		{
			PrintHintText(client,"Wait %s seconds to change the team",text);
		}
		
		if (StrEqual("yes", is_message_on))
		{
			PrintToChat(client," \x04[%s]\x0C Wait %s seconds to change the team",chat_prefix,text);
		}

		CreateTimer(time, timer,GetClientUserId(client))
		
		return Plugin_Handled;
		
	}
    return Plugin_Continue;
}
