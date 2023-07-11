#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_magicbox;
#include common_scripts\utility;

init() {
  thread on_player_connect();
}

on_player_connect() {
  while (true) {
    level waittill("connecting", player);
    player thread on_player_spawned();
  }
}

on_player_spawned() {
  level endon("game_end");
  level endon("game_ended");
  self endon("disconnect");

  level.config = array();
  level.config["box_hits"] = true;
  level.config["average"] = true;

  thread set_dvars();
  thread dvars_controller();

  for (;;) {
    self waittill("spawned_player");
    flag_wait("initial_blackscreen_passed");

    thread set_box_tracker();

    wait .05;
  }
}

/*

  DVARS

*/

init_dvar(dvar) {
  if (level.config[dvar]) {
    setDvar(dvar, 1);
  } else {
    setDvar(dvar, 0);
  }
}

set_dvars() {
  init_dvar("box_hits");
  init_dvar("average");
}

dvars_controller() {
  while (true) {
    // BOX HITS
    if (isDefined(level.box_hits_tracker)) {
      if (!getDvarInt("box_hits")) {
        level.box_hits_tracker.alpha = 0;
      } else if (getDvarInt("box_hits") == 1) {
        level.box_hits_tracker.alpha = 1;
      }
    }

    // RAYS AVERAGE
    if (isDefined(level.rayguns_average) && isDefined(level.rayguns_mark2_average)) {
      if (!getDvarInt("average")) {
        level.rayguns_average.alpha = 0;
        level.rayguns_mark2_average.alpha = 0;
      } else if (getDvarInt("average") == 1) {
        level.rayguns_average.alpha = 1;
        level.rayguns_mark2_average.alpha = 1;
      }
    }

    wait .05;
  }
}

/*

  UTILITY FUNCTIONS

*/

has_magic() {
  if (level.enable_magic) {
    return true;
  }

  return false;
}

is_firstroom_game() {
  if (level.start_round == 10) {
    return true;
  }

  return false;
}

is_survival_map() {
  if (level.scr_zm_ui_gametype_group == "zsurvival" || level.script == "zm_nuked") {
    return true;
  }

  return false;
}

is_nuketown() {
  if (level.script == "zm_nuked") {
    return true;
  }

  return false;
}

get_box_hit() {
  while (true) {
    self waittill("trigger");

    level.box_hits++;

    self waittill("chest_accessed");
  }
}

current_box_weapon() {
  return self.zbarrier.weapon_string;
}

check_rayguns() {
  while (true) {
    while (self current_box_weapon() != "ray_gun_zm" && self current_box_weapon() != "raygun_mark2_zm") {
      wait .05;
    }

    grabbed_weapon = self current_box_weapon();

    self waittill("user_grabbed_weapon");

    switch (grabbed_weapon) {
      case "ray_gun_zm":
        level.rayguns++;
        break;

      case "raygun_mark2_zm":
        level.rayguns_mark2++;
        break;
    }

    while (self current_box_weapon() == "ray_gun_zm" || self current_box_weapon() == "raygun_mark2_zm") {
      wait .05;
    }
  }
}

has_traded() {
  if ((level.rayguns + level.rayguns_mark2) >= 2) {
    return true;
  }

  return false;
}

weapon_average(weapon) {
  return int((level.box_hits / weapon) * 100) / 100;
}

/*

  HUD

*/

set_box_tracker() {
  if (!has_magic() || is_firstroom_game()) {
    return;
  }

  if (is_survival_map()) {
    // I don't know why but "wait" is needed otherwise it doesn't work on Nuketown
    if (is_nuketown()) {
      wait .05;
    }

    thread box_hits_tracker_hud();
    thread rayguns_average_hud();
  }
}

box_hits_tracker_hud() {
  level.box_hits_tracker = createServerFontString("big", 1.5);
  level.box_hits_tracker setPoint("TOPRIGHT", "TOPRIGHT", 58, 30);

  level.box_hits = 0;

  foreach(chest in level.chests) {
    chest thread get_box_hit();
  }

  while (true) {
    while (!level.box_hits) {
      wait .05;
    }

    level.box_hits_tracker.label = &"Box hits: ";

    level.box_hits_tracker setValue(level.box_hits);

    wait .05;
  }
}

rayguns_average_hud() {
  level.rayguns_average = createServerFontString("small", 1.1);
  level.rayguns_average setPoint("TOPRIGHT", "TOPRIGHT", 58, 48);
  
  level.rayguns_mark2_average = createServerFontString("small", 1.1);
  level.rayguns_mark2_average setPoint("TOPRIGHT", "TOPRIGHT", 58, 60);

  level.rayguns = 0;
  level.rayguns_mark2 = 0;

  foreach(chest in level.chests) {
    chest thread check_rayguns();
  }

  while (true) {
    while (!has_traded()) {
      wait .05;
    }

    level.rayguns_average.label = &"Ray Gun average: ";
    level.rayguns_mark2_average.label = &"Ray Gun Mark II average: ";

    level.rayguns_average setValue(weapon_average(level.rayguns));
    level.rayguns_mark2_average setValue(weapon_average(level.rayguns_mark2));

    wait .05;
  }
}