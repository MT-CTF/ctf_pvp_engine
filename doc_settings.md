# ctf mod

| name                       | default value | description                                                      |
| -------------------------- | ------------- | ---------------------------------------------------------------- |
| allocate_mode              | 0             | 0=off, 1=firstnonfullteam, 2=RandomOfSmallestTwo, 3=SmallestTeam |
| autoalloc_on_joinplayer    | true          | Trigger auto alloc on join player                                |
| default_diplo_state        | war           | war, alliance or peace                                           |
| diplomacy                  | true          | is diplomacy enabled                                             |
| friendly_fire              | true          | true if players can't hit other players on their team            |
| maximum_in_team            | -1            | player cap                                                       |
| players_can_change_team    | true          |                                                                  |
| hud                        | true          | Enable HUD                                                       |
| gui                        | true          | Enable GUI                                                       |
| gui.team                   | true          | Whether to show team gui (/team)                                 |
| gui.team.initial           | news          | Initial tab                                                      |
| gui.tab.diplo              | true          | Show diplo tab                                                   |
| gui.tab.news               | true          | Show news tab                                                    |
| gui.tab.settings           | true          | Show settings tab                                                |

# ctf_chat

| name                       | default value | description                                                      |
| -------------------------- | ------------- | ---------------------------------------------------------------- |
| chat.default               | global        | global or team                                                   |
| chat.global_channel        | true          |                                                                  |
| chat.team_channel          | true          |                                                                  |

# ctf_colors

| name                       | default value | description                                                      |
| -------------------------- | ------------- | ---------------------------------------------------------------- |
| colors.nametag             | true          | Whether to colour the name tagColour nametag                     |
| colors.nametag.tcolor      | false         | Base nametag colour on team colour                               |
| colors.skins               | false         | Team skins are coloured                                          |

# ctf_flag

| name                       | default value | description                                                      |
| -------------------------- | ------------- | ---------------------------------------------------------------- |
| flag.alerts                | true          | prompts like "X has captured your flag"                          |
| flag.alerts.neutral_alert  | true          | show prompt in neutral state, ie: "attack and defend!"           |
| flag.allow_multiple        | true          | teams can have multiple flags                                    |
| flag.capture_take          | false         | whether a player needs to return flag to base to capture         |
| flag.drop_time             | 420           | time in seconds before a player drops the flag they're holding   |
| flag.drop_warn_time        | 60            | warning time before drop                                         |
| flag.nobuild_radius        | 3             | area around flag where you can't build                           |
| flag.names                 | true          | enable naming flags                                              |
| flag.protect_distance      | 25            | area protection distance                                         |
| flag.waypoints             | true          | enable waypoints to flags                                        |
| flag.crafting              | false         | enable the crafting of flags                                     |      |
| gui.tab.flags              | true          | Show flags tab                                                   |
| gui.team.teleport_to_flag  | true          | Enable teleport to flag button in flags tab                      |
| gui.team.teleport_to_spawn | false         | Enable teleport to spawn button in flags tab                     |

# ctf_protect

| name                       | default value | description                                                      |
| -------------------------- | ------------- | ---------------------------------------------------------------- |
| node_ownership             | true          | whether node protection per team is enabled
