#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cs_teams_api>
#include <jailbreak>

new g_iPlayerVoice[33];
enum MENU_SIMON
{
  MENU_TRANSFER,
  MENU_GIVEMIC,
  MENU_DAYS,
  MENU_GAMES,
  MENU_ALLOWNADES,
  MENU_REVERSE,
  MENU_BLIND
}

const g_szMenuNames[][] =
{
  "JAIL_TRANSFER",
  "JAIL_GIVEMIC",
  "JAIL_DAYMENU",
  "JAIL_ALLOWNADES",
  "JAIL_GAMEMENU",
  "JAIL_REVERSE",
  "JAIL_BLIND"
};

public plugin_init()
{
  register_plugin("[JAIL] Simon menu", JAIL_VERSION, JAIL_AUTHOR);

  set_client_commands("menu", "cmd_show_menu");
  set_client_commands("transfer", "transfer_show_menu");
  set_client_commands("reverse", "reverse_gameplay");
  set_client_commands("mic", "give_mic");
  set_client_commands("blind", "blind_show_menu");
}

public jail_gamemode(mode)
{
  if(mode == GAME_STARTED)
  {
    new num, id;
    static players[32];
    get_players(players, num);

    for(--num; num >= 0; num--)
    {
      id = players[num];
      g_iBlindState[id] = 0;
    }
  }
}

public cmd_show_menu(id)
{
  if(is_user_alive(id) && my_check(id))
  {
    static menu, option[64], num[3];
    formatex(option, charsmax(option), "%L", id, "JAIL_MENUMENU");
    menu = menu_create(option, "show_menu_handle");

    new cvar = get_pcvar_num(get_cvar_pointer("jail_prisoner_grenade");

    for(new i = 0; i < MENU_SIMON; i++)
    {
      if(i == MENU_ALLOWNADES && cvar) continue;

      formatex(num, charsmax(num), "%d", i);
      if(i == MENU_REVERSE)
        formatex(option, charsmax(option), "%L", id, g_szMenuNames[i], id, jail_get_globalinfo(GI_REVERSE) ? "JAIL_PRISONERS" : "JAIL_GUARDS");
      else formatex(option, charsmax(option), "%L", id, g_szMenuNames[i]);
      menu_additem(menu, option, num, 0);
    }

    menu_display(id, menu);
  }
}

public show_menu_handle(id, menu, item)
{
  if(item == MENU_EXIT || !is_user_alive(id) || !my_check(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new access, callback, num[3];
  menu_item_getinfo(menu, item, access, num, charsmax(num), _, _, callback);
  menu_destroy(menu);

  new pick = str_to_num(num);
  switch(pick)
  {
    case MENU_TRANSFER:	transfer_show_menu(id);
    case MENU_GIVEMIC: give_mic(id);
    case MENU_DAYS: client_cmd(id, "jail_days");
    case MENU_GAMES: client_cmd(id, "jail_games");
    case MENU_ALLOWNADES: nades_show_menu(id);
    case MENU_REVERSE: reverse_gameplay(id);
    case MENU_BLIND: blind_show_menu(id);
  }

  return PLUGIN_HANDLED;
}

public give_mic(id)
{
  show_player_menu(id, 1, "ae", "MIC_transfer_show_menu_handle");
}

public reverse_gameplay(id)
{
  jail_set_globalinfo(GI_REVERSE, !jail_get_globalinfo(GI_REVERSE));
  cmd_show_menu(id);
  static name[32];
  get_user_name(id, name, charsmax(name));
  ColorChat(0, NORMAL, "%s %L", JAIL_TAG, LANG_SERVER, "JAIL_REVERSE_C", name, LANG_SERVER, jail_get_globalinfo(GI_REVERSE) ? "JAIL_PRISONERS" : "JAIL_GUARDS");
}

public blind_show_menu(id)
{
  show_player_menu(id, 1, "ae", "blind_show_menu_handle");
}

public transfer_show_menu(id)
{
  static menu, option[64];
  formatex(option, charsmax(option), "%L", id, "JAIL_MENUMENU");
  menu = menu_create(option, "transfer_show_menu_handle");

  formatex(option, charsmax(option), "To T");
  menu_additem(menu, option, "0", 0);
  formatex(option, charsmax(option), "To CT");
  menu_additem(menu, option, "1", 0);

  menu_display(id, menu);
}

public nades_show_menu(id)
{
  if(is_user_alive(id))
  {
    static menu, option[64];
    formatex(option, charsmax(option), "%L", id, "JAIL_ALLOWNADES");
    menu = menu_create(option, "nades_show_menu_handle");

    formatex(option, charsmax(option), "All T");
    menu_additem(menu, option, "0", 0);
    formatex(option, charsmax(option), "Specific");
    menu_additem(menu, option, "1", 0);

    menu_display(id, menu);
  }
}

public blind_show_menu_handle(id, menu, item)
{
  if(item == MENU_EXIT || !is_user_alive(id) || !my_check(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new access, callback, num[3];
  menu_item_getinfo(menu, item, access, num, charsmax(num), _, _, callback);
  menu_destroy(menu);

  new userid = str_to_num(num);
  set_user_blind(userid, !g_iBlindState[userid]);

  static name[2][32];
  get_user_name(id, name[0], charsmax(name[]));
  get_user_name(userid, name[1], charsmax(name[]));
  ColorChat(0, NORMAL, "%s %L", JAIL_TAG, LANG_SERVER, "JAIL_BLIND_C", name[0], name[1]);

  return PLUGIN_HANDLED;
}

public transfer_show_menu_handle(id, menu, item)
{
  if(item == MENU_EXIT || !is_user_alive(id) || !my_check(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new access, callback, num[3];
  menu_item_getinfo(menu, item, access, num, charsmax(num), _, _, callback);
  menu_destroy(menu);

  new pick = str_to_num(num);
  show_player_menu(id, pick, "ae", "TR_transfer_show_menu_handle");

  return PLUGIN_HANDLED;
}

public nades_show_menu_handle(id, menu, item)
{
  if(item == MENU_EXIT || !is_user_alive(id) || !my_check(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new access, callback, num[3];
  menu_item_getinfo(menu, item, access, num, charsmax(num), _, _, callback);
  menu_destroy(menu);

  new pick = str_to_num(num);
  if(!pick)
  {
    static players[32], name[32];
    new num, i;
    get_players(players, num, "ae", "TERRORIST");

    for(--num; num >= 0; num--)
    {
      i = players[num];
      jail_set_playerdata(i, PD_REMOVEHE, !jail_get_playerdata(i, PD_REMOVEHE));
    }

    get_user_name(id, name, charsmax(name));
    ColorChat(0, NORMAL, "%s %L", JAIL_TAG, LANG_SERVER, "JAIL_ALLOWNADES_CA", name);
  }
  else show_player_menu(id, pick, "ae", "DO_nades_show_menu_handle");

  return PLUGIN_HANDLED;
}

public show_player_menu(id, pick, status, handle[])
{
  static name[32], data[3], newmenu;
  formatex(name, charsmax(name), "%L", id, "JAIL_MENUMENU");
  newmenu = menu_create(name, handle);
  static players[32];
  new inum, i;
  get_players(players, inum, status, pick ? "TERRORIST" : "CT");

  for(--inum; inum >= 0; inum--)
  {
    i = players[inum];
    if(jail_get_playerdata(i, PD_FREEDAY)) continue;
    get_user_name(i, name, charsmax(name));
    num_to_str(i, data, charsmax(data));
    menu_additem(newmenu, name, data, 0);
  }

  menu_display(id, newmenu);
}

public TR_transfer_show_menu_handle(id, menu, item)
{
  if(item == MENU_EXIT || !is_user_alive(id) || !my_check(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new access, callback, num[3];
  menu_item_getinfo(menu, item, access, num, charsmax(num), _, _, callback);
  menu_destroy(menu);

  new pick = str_to_num(num), CsTeams:team = cs_get_user_team(pick);
  static name[2][32];
  get_user_name(pick, name[0], charsmax(name[]));
  get_user_name(id, name[1], charsmax(name[]));

  if(team == CS_TEAM_T)
  {
    cs_set_player_team(pick, CS_TEAM_CT);
    ColorChat(0, NORMAL, "%s %L", JAIL_TAG, LANG_SERVER, "JAIL_TRANSFER_C", name[0], LANG_SERVER, "JAIL_GUARDS", name[1]);
  }
  else if(team == CS_TEAM_CT)
  {
    cs_set_player_team(pick, CS_TEAM_T);
    ColorChat(0, NORMAL, "%s %L", JAIL_TAG, LANG_SERVER, "JAIL_TRANSFER_C", name[0], LANG_SERVER, "JAIL_PRISONERS", name[1]);
  }
  strip_weapons(pick);
  ExecuteHamB(Ham_CS_RoundRespawn, pick);


  return PLUGIN_HANDLED;
}

public DO_nades_show_menu_handle(id, menu, item)
{
  if(item == MENU_EXIT || !is_user_alive(id) || !my_check(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new access, callback, num[3];
  menu_item_getinfo(menu, item, access, num, charsmax(num), _, _, callback);
  menu_destroy(menu);

  new pick = str_to_num(num);
  static name[2][32];
  get_user_name(pick, name[0], charsmax(name[]));
  get_user_name(id, name[1], charsmax(name[]));

  jail_set_playerdata(pick, PD_REMOVEHE, !jail_get_playerdata(pick, PD_REMOVEHE));
  ColorChat(0, NORMAL, "%s %L", JAIL_TAG, LANG_SERVER, "JAIL_ALLOWNADES_C", name[0], name[1]);

  return PLUGIN_HANDLED;
}

public MIC_transfer_show_menu_handle(id, menu, item)
{
  if(item == MENU_EXIT || !is_user_alive(id) || !my_check(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new access, callback, num[3];
  menu_item_getinfo(menu, item, access, num, charsmax(num), _, _, callback);
  menu_destroy(menu);

  new pick = str_to_num(num);
  if(jail_get_playerdata(pick, PD_TALK))
    print_voice_change(id, pick);
  else show_duration_menu(id, pick);
  return PLUGIN_HANDLED;
}

public show_duration_menu(id, pick)
{
  static name[32], data[3], newmenu;
  formatex(name, charsmax(name), "%L", id, "JAIL_MENUMENU");
  newmenu = menu_create(name, "show_duration_menu_handle");

  g_iPlayerVoice[id] = pick;
  menu_additem(newmenu, "For this round", "1", 0);
  menu_additem(newmenu, "For ever", "2", 0);

  menu_display(id, newmenu);
}

public show_duration_menu_handle(id, menu, item)
{
  if(item == MENU_EXIT || !is_user_alive(id) || !my_check(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new access, callback, num[3];
  menu_item_getinfo(menu, item, access, num, charsmax(num), _, _, callback);
  menu_destroy(menu);
  new pick = str_to_num(num);
  print_voice_change(id, g_iPlayerVoice[id]);
  if(pick == 2)
    jail_set_playerdata(g_iPlayerVoice[id], PD_TALK_FOREVER, true);

  g_iPlayerVoice[id] = 0;
}

print_voice_change(id, pick)
{
  static name[2][32];
  get_user_name(pick, name[0], charsmax(name[]));
  get_user_name(id, name[1], charsmax(name[]));
  jail_set_playerdata(pick, PD_TALK, !jail_get_playerdata(pick, PD_TALK));
  jail_set_playerdata(pick, PD_TALK_FOREVER, false);
  ColorChat(0, NORMAL, "%s %L", JAIL_TAG, LANG_SERVER, "JAIL_GIVEMIC_C", name[1], name[0]);
}

my_check(id)
{
  if(simon_or_admin(id) && !in_progress(id, GI_DAY) && !in_progress(id, GI_GAME))
    return 1;

  return 0;
}

set_user_blind(id, type)
{
  g_iBlindState[id] = type;
  if(type)
    type = 0x0004;
  else type = 0x0000;

  message_begin(MSG_ONE_UNRELIABLE, g_pMsgScreeFade, _, id);
  write_short(1 * 1<<12);
  write_short(4*1<<12);
  write_short(0x0000);
  write_byte(0);
  write_byte(0);
  write_byte(0);
  write_byte(255);
  message_end();
}