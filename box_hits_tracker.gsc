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
  level endon("end_game");
  self endon("disconnect");

  level.dvars = [];
  level.dvars["side"] = "right";
  level.dvars["box_hits"] = true;
  level.dvars["average"] = true;
  level.dvars["ratio"] = false;

  thread set_dvars();

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

set_dvars() {
  level endon("end_game");

  foreach (key in getArrayKeys(level.dvars)) {
    value = level.dvars[key];

    if (isString(value)) {
      setDvar(key, value);
    } else if (value) {
      setDvar(key, 1);
    } else {
      setDvar(key, 0);
    }
  }
}

/*

  UTILITIES

*/

is_nuketown() {
  if (level.script == "zm_nuked") {
    return true;
  }

  return false;
}

is_survival_map() {
  if (level.scr_zm_ui_gametype_group == "zsurvival" || is_nuketown()) {
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

is_raygun(weapon) {
  if (weapon != "ray_gun_zm" && weapon != "raygun_mark2_zm") {
    return false;
  }

  return true;
}

check_rayguns() {
  while (true) {
    while (!is_raygun(self.zbarrier.weapon_string)) {
      wait .05;
    }

    grabbed_weapon = self.zbarrier.weapon_string;

    self waittill("user_grabbed_weapon");

    switch (grabbed_weapon) {
      case "ray_gun_zm":
        level.rayguns++;
        break;

      case "raygun_mark2_zm":
        level.mark2s++;
        break;
    }

    level.total_rayguns++;
  }
}

has_traded() {
  if (level.total_rayguns < 2) {
    return false;
  }

  return true;
}

round(number) {
  return int((number) * 100) / 100;
}

average(raygun) {
  return round(level.box_hits / raygun);
}

set_hud_position(y) {
  while (true) {
    POSITION = "TOP" + toUpper(getDvar("side"));
    x = 58;

    if (getDvar("side") == "left") {
      x = x * -1;
    }

    self setPoint(POSITION, POSITION, x, y);

    wait .05;
  }
}

set_hud(dvar, alpha, message) {
  if (getDvarInt(dvar) == 1) {
    self.alpha = alpha;
  } else {
    self.alpha = 0;
  }

  self.label = message;
}

/*

  HUD

*/

set_box_tracker() {
  if (is_survival_map()) {
    // Disabled for no magic games
    if (!level.enable_magic) {
      return;
    }

    // I don't know why "wait" is needed otherwise it doesn't work on Nuketown
    while (is_nuketown()) {
      wait .05;
    }

    thread box_hits_tracker_hud();
    thread rayguns_averages_hud();
    thread mark2s_ratio_hud();
  }
}

box_hits_tracker_hud() {
  level.box_hits_tracker = createFontString("big", 1.5);
  level.box_hits_tracker thread set_hud_position(30);

  level.box_hits = 0;

  foreach(chest in level.chests) {
    chest thread get_box_hit();
  }

  while (true) {
    while (!level.box_hits) {
      level.box_hits_tracker set_hud("box_hits", .6, &"No box hits");

      wait .05;
    }

    level.box_hits_tracker set_hud("box_hits", 1, &"Box hits: ");
    level.box_hits_tracker setValue(level.box_hits);

    wait .05;
  }
}

/*

  HUD - Averages

*/

rayguns_averages_hud() {
  level.rayguns_average = createFontString("big", 1.1);
  level.rayguns_average thread set_hud_position(48);

  level.mark2s_average = createFontString("big", 1.1);
  level.mark2s_average thread set_hud_position(62);

  level.rayguns = 0;
  level.mark2s = 0;

  level.total_rayguns = 0;

  foreach(chest in level.chests) {
    chest thread check_rayguns();
  }

  while (true) {
    while (!has_traded()) {
      while (level.total_rayguns == 1) {
        level.rayguns_average set_hud("average", .6, &"Waiting for first trade to calculate average");

        wait .05;
      }
      
      wait .05;
    }

    if (!level.rayguns) {
      level.rayguns_average set_hud("average", .6, &"No average for Ray Guns");
    } else {
      level.rayguns_average set_hud("average", 1, &"Ray Guns average: ");
      level.rayguns_average setValue(average(level.rayguns));
    }

    if (!level.mark2s) {
      level.mark2s_average set_hud("average", .6, &"No average for Ray Guns Mark II");
    } else {
      level.mark2s_average set_hud("average", 1, &"Ray Guns Mark II average: ");
      level.mark2s_average setValue(average(level.mark2s));
    }

    wait .05;
  }
}

/*

  HUD - Ratio

*/

mark2s_ratio_hud() {
  level.mark2_ratio = createFontString("big", 1.1);
  level.mark2_ratio thread set_hud_position(124);

  while (true) {
    while (!has_traded() || !level.mark2s) {
      wait .05;
    }
    
    level.mark2_ratio set_hud("ratio", 1, &"Ray Guns Mark II ratio: ");
    level.mark2_ratio setValue(round(1 / (level.rayguns / level.mark2s)));

    wait .05;
  }
}