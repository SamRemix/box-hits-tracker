# Box hits tracker & average calculator

Box hits tracker & Ray Gun average calculator for Call of Duty: Black Ops II.

> Enabled on survival maps only *(Depot, Town, Farm & Nuketown)*.

## Installation

### Redacted

Download [box_hits_tracker.gsc](https://github.com/SamRemix/box-hits-tracker/blob/main/box_hits_tracker.gsc) and put it in your scripts folder.

```
Redacted_LAN\data\scripts
```

### Plutonium

Download [box_hits_tracker-compiled.gsc](https://github.com/SamRemix/box-hits-tracker/blob/main/box_hits_tracker-compiled.gsc) and put it in your scripts folder.

```
Plutonium\storage\t6\scripts\zm
```

## Features

- Box hits tracker
- Ray Guns average
- Ray Gun Mark II ratio *(relative average of Ray Gun Mark II for 1 Ray Gun)*

> * *Ray Guns average* appear after the first trade.
> * *Ray Gun Mark II ratio* appear after the first trade if you got at least one Ray Gun Mark II.

| HUD element           |        Dvar        | Default |
| :-------------------- | :----------------: | :------ |
| Box hits tracker      | `box_hits` + `0 1` | Enabled |
| Ray Guns average      | `average` + `0 1`  | Enabled |
| Ray Gun Mark II ratio |  `ratio` + `0 1`   | Enabled |

> For novices, here's an example of use:
> * Open the console with `~` or `²`, type `average 0` to disable the feature and type `average 1` to re-enable it.

## Notes

You have the possibility to change the side of the HUD:

| HUD element      |         Dvar          | Default |
| :--------------- | :-------------------: | :------ |
| All HUD elements | `side` + `right left` | `right` |

## Contribution

If you notice any english mistake on the documentation or if you have any suggestions to improve or optimize the script, please [open an issue](https://github.com/SamRemix/box-hits-tracker/issues/new) or contact me:

* Discord: `samcpr`
* Twitter: `@samcpr__`