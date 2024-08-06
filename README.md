# Box hits tracker & average calculator

Box hits tracker & Ray Gun average calculator for Call of Duty: Black Ops II.

> Enabled on survival maps only *(Depot, Town, Farm & Nuketown)*.

## Installation

Download the script corresponding to your client and put it in your game script folder.

### Redacted

| [box_hits_tracker.gsc](https://github.com/SamRemix/box-hits-tracker/blob/main/box_hits_tracker.gsc) |
| :-------------------------------------------------------------------------------------------------: |

```
Redacted_LAN\data\scripts
```

### Plutonium

| [box_hits_tracker-compiled.gsc](https://github.com/SamRemix/box-hits-tracker/blob/main/box_hits_tracker-compiled.gsc) |
| :-------------------------------------------------------------------------------------------------------------------: |

```
Plutonium\storage\t6\scripts\zm
```

## Features

- Box hits tracker
- Ray Guns average
- Ray Gun Mark II ratio *(relative average of Ray Gun Mark II for 1 Ray Gun)*

> * *Ray Guns average* appear after the first trade.
> * *Ray Gun Mark II ratio* appear after the first trade if you got at least one Ray Gun Mark II.

| HUD element           |        Dvar        | Default  |
| :-------------------- | :----------------: | :------: |
| Box hits tracker      | `box_hits` + `0 1` | Enabled  |
| Ray Guns average      | `average` + `0 1`  | Enabled  |
| Ray Gun Mark II ratio |  `ratio` + `0 1`   | Disabled |

> HUD elements can be hidden or shown by changing the Dvar value. To do this, open the in-game console with `~` or `²` (on AZERTY keyboard) and enter the Dvar name followed by its value (you can also use the Redacted console or the Plutonium bootstrapper's console to enter Dvars).

## Notes

You have the possibility to change the side of the HUD:

| HUD element      |         Dvar          | Default |
| :--------------- | :-------------------: | :-----: |
| All HUD elements | `side` + `right left` | `right` |

## Contribution

If you would like to contribute to the code, you can [fork this repository](https://github.com/SamRemix/box-hits-tracker/fork) to make changes and then [open a pull request](https://github.com/SamRemix/box-hits-tracker/pulls).

Also, if you notice any issues while using the script, any english mistakes in the documentation or just have any suggestions to improve or optimize the script, please [open an issue](https://github.com/SamRemix/box-hits-tracker/issues) or contact me:

* Discord: `samcpr`
* Twitter: `@samcpr__`