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
        level.mark2++;
        break;
    }

    level.total_rayguns++;
  }
}

has_traded() {
  if (level.total_rayguns >= 2) {
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

set_hud_alpha(dvar, alpha) {
  if (getDvarInt(dvar) == 1) {
    self.alpha = alpha;
  } else {
    self.alpha = 0;
  }
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
    thread rayguns_average_hud();
    thread mark2_ratio_hud();
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
      level.box_hits_tracker set_hud_alpha("box_hits", .6);
      level.box_hits_tracker.label = &"No box hits";

      wait .05;
    }

    level.box_hits_tracker set_hud_alpha("box_hits", 1);
    level.box_hits_tracker.label = &"Box hits: ";

    level.box_hits_tracker setValue(level.box_hits);

    wait .05;
  }
}

rayguns_average_hud() {
  level.rayguns_average = createFontString("big", 1.1);
  level.rayguns_average thread set_hud_position(48);

  level.mark2_average = createFontString("big", 1.1);
  level.mark2_average thread set_hud_position(62);

  level.rayguns = 0;
  level.mark2 = 0;

  level.total_rayguns = 0;

  foreach(chest in level.chests) {
    chest thread check_rayguns();
  }

  while (true) {
    while (!has_traded()) {
      while (level.total_rayguns == 1) {
        level.rayguns_average set_hud_alpha("average", .6);
        level.rayguns_average.label = &"Waiting for first trade to calculate average";

        wait .05;
      }
      
      wait .05;
    }

    level.rayguns_average set_hud_alpha("average", 1);
    level.rayguns_average.label = &"Ray Gun average: ";

    level.rayguns_average setValue(average(level.rayguns));

    level.mark2_average set_hud_alpha("average", 1);
    level.mark2_average.label = &"Ray Gun Mark II average: ";

    level.mark2_average setValue(average(level.mark2));

    wait .05;
  }
}

mark2_ratio_hud() {
  level.mark2_ratio = createFontString("big", 1.1);
  level.mark2_ratio thread set_hud_position(76);

  while (true) {
    while (!has_traded() || !level.mark2) {
      wait .05;
    }
    
    level.mark2_ratio set_hud_alpha("ratio", 1);
    level.mark2_ratio.label = &"Ray Gun Mark II ratio: ";

    level.mark2_ratio setValue(round(1 / (level.rayguns / level.mark2)));

    wait .05;
  }
}