#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_magicbox;
#include common_scripts\utility;

init() {
  level thread onplayerconnect();
}

onplayerconnect() {
  level waittill("connecting", player);
  player thread onplayerspawned();
}

onplayerspawned() {
  level endon("game_end");
  level endon("game_ended");
  self endon("disconnect");

  level.config = array();
  level.config["box_hits"] = true;
  level.config["average"] = true;

  thread set_dvars();
  level thread dvars_controller();

  for (;;) {
    self waittill("spawned_player");

    flag_wait("initial_blackscreen_passed");

    if (is_survival_map()) {
      self thread box_hits_tracker_hud();
      self thread rayguns_average_hud();
    }

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
  while (1) {
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

is_survival_map() {
  if (level.scr_zm_ui_gametype_group == "zsurvival" || level.script == "zm_nuked") {
    return true;
  }

  return false;
}

get_box_hit() {
  while (1) {
    while (self.zbarrier getzbarrierpiecestate(2) != "opening") {
      wait .05;
    }

    level.box_hits++;

    while (self.zbarrier getzbarrierpiecestate(2) == "opening") {
      wait .05;
    }
  }
}

is_raygun() {
  while (1) {
    while (self.zbarrier.weapon_string != "ray_gun_zm") {
      wait .05;
    }

    self waittill("user_grabbed_weapon");

    level.rayguns++;

    while (self.zbarrier.weapon_string == "ray_gun_zm") {
      wait .05;
    }
  }
}

is_raygun_mark2() {
  while (1) {
    while (self.zbarrier.weapon_string != "raygun_mark2_zm") {
      wait .05;
    }

    self waittill("user_grabbed_weapon");
    
    level.rayguns_mark2++;

    while (self.zbarrier.weapon_string == "raygun_mark2_zm") {
      wait .05;
    }
  }
}

weapon_average(weapon) {
  return int((level.box_hits / weapon) * 100) / 100;
}

/*

  HUD

*/

box_hits_tracker_hud() {
  level.box_hits_tracker = createServerFontString("big", 1.5);
  level.box_hits_tracker setPoint("TOPRIGHT", "TOPRIGHT", 58, 30);

  level.box_hits = 0;

  foreach(chest in level.chests) {
    chest thread get_box_hit();
  }

  while (1) {
    while (!level.box_hits) {
      wait .05;
    }

    level.box_hits_tracker.label = &"Box hits: ";

    level.box_hits_tracker setValue(level.box_hits);

    wait .05;
  }
}

rayguns_average_hud() {
  level.rayguns_average = createServerFontString("big", 1.1);
  level.rayguns_average setPoint("TOPRIGHT", "TOPRIGHT", 58, 48);
  
  level.rayguns_mark2_average = createServerFontString("big", 1.1);
  level.rayguns_mark2_average setPoint("TOPRIGHT", "TOPRIGHT", 58, 62);

  level.rayguns = 0;
  level.rayguns_mark2 = 0;

  foreach(chest in level.chests) {
    chest thread is_raygun();
    chest thread is_raygun_mark2();
  }

  while (1) {
    while ((level.rayguns + level.rayguns_mark2) < 2) {
      wait .05;
    }

    level.rayguns_average.label = &"Ray Guns average: ";
    level.rayguns_mark2_average.label = &"Ray Guns Mark II average: ";

    level.rayguns_average setValue(weapon_average(level.rayguns));
    level.rayguns_mark2_average setValue(weapon_average(level.rayguns_mark2));

    wait .05;
  }
}