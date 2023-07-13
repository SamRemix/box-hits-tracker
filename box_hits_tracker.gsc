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
  level.config["ratio"] = false;

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
  init_dvar("ratio");
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

    // RATIO
    if (isDefined(level.ratio)) {
      if (!getDvarInt("ratio")) {
        level.ratio.alpha = 0;
      } else if (getDvarInt("ratio") == 1) {
        level.ratio.alpha = 1;
      }
    }

    wait .05;
  }
}

/*

  UTILITIES

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

check_rayguns() {
  while (true) {
    while (self.zbarrier.weapon_string != "ray_gun_zm" && self.zbarrier.weapon_string != "raygun_mark2_zm") {
      wait .05;
    }

    grabbed_weapon = self.zbarrier.weapon_string;

    self waittill("user_grabbed_weapon");

    switch (grabbed_weapon) {
      case "ray_gun_zm":
        level.rayguns++;
        break;

      case "raygun_mark2_zm":
        level.rayguns_mark2++;
        break;
    }
  }
}

has_traded() {
  if ((level.rayguns + level.rayguns_mark2) >= 2) {
    return true;
  }

  return false;
}

round(number) {
  return int((number) * 100) / 100;
}

average(raygun) {
  return round(level.box_hits / raygun);
}

/*

  HUD

*/

set_box_tracker() {
  if (is_survival_map()) {
    if (!has_magic() || is_firstroom_game()) {
      return;
    }

    // I don't know why but "wait" is needed otherwise it doesn't work on Nuketown
    if (is_nuketown()) {
      wait .05;
    }

    thread box_hits_tracker_hud();
    thread rayguns_average_hud();
    thread mark2_ratio_hud();
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

    level.rayguns_average setValue(average(level.rayguns));
    level.rayguns_mark2_average setValue(average(level.rayguns_mark2));

    wait .05;
  }
}

mark2_ratio_hud() {
  level.ratio = createServerFontString("small", 1.1);
  level.ratio setPoint("TOPRIGHT", "TOPRIGHT", 58, 72);

  while (true) {
    while (!has_traded() || !level.rayguns_mark2) {
      wait .05;
    }

    level.ratio.label = &"Mark II ratio: 1/";

    level.ratio setValue(round(level.rayguns / level.rayguns_mark2));

    wait .05;
  }
}