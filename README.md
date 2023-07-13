# T6 Box hits/average tracker

Box hits tracker & average calculator for Call of Duty: Black Ops II.

> * *Enabled on survival maps only (Depot, Town, Farm & Nuketown).*
> * *Disabled for No Magic & First Room games.*

## Installation

### Redacted

Download [box_hits_tracker.gsc](https://github.com/SamRemix/box-hits-tracker/blob/main/box_hits_tracker.gsc) and put it in `Redacted_LAN\data\scripts` folder.

### Plutonium

Download [box_hits_tracker_compiled.gsc](https://github.com/SamRemix/box-hits-tracker/blob/main/box_hits_tracker_compiled.gsc) and put it in `Plutonium\storage\t6\scripts\zm` folder.

## Features

- Box hits tracker *(appears on first hit)*
- Ray Guns average *(appears after the first trade)*
- Ray Gun Mark II ratio *(appears after the first trade)*

### Dvars

| HUD element           | Dvar               | Default  |
| :-------------------- | :----------------- | :------- |
| Box hits tracker      | `box_hits` + `0 1` | Enabled  |
| Ray Guns average      | `average` + `0 1`  | Enabled  |
| Ray Gun Mark II ratio | `ratio` + `0 1`    | Disabled |

### Notes

If you want to play First Room with box on Farm, there are 2 possibilities:

- Set the starting round to 0 or 5.
- Download the source code from [v1.0](https://github.com/SamRemix/box-hits-tracker/releases/tag/v1.0) and copy the `.gsc` file into your game's script folder.