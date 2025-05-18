# Journal System for FiveM QBCore Servers

A fully customizable journal system for QBcore that helps server administrators provide guides, missions, announcements, help, and store information to players in an elegant UI.
[Watch](https://youtu.be/AWJz5CQFkyE?feature=shared) video.

## Features

- **Fully Customizable Categories**: Add, modify, or remove categories through the config file
- **Custom Waypoints**: Set GPS waypoints for mission locations
- **Media Support**: Add images and videos to enhance guides and mission descriptions
- **External Links**: Link to external websites for store items or PIXLY store
- **Help Request System**: Players can submit help requests that get sent to a Discord webhook
- **Cashback/Coupon System**: Support for promo code redemption with Discord notifications
- **User Settings**: Players can toggle UI elements to their preference
- **Easy Access**: Open with F2 key (customizable) or through the floating button prompt
- **Responsive Design**: Clean and modern UI that fits any screen resolution

## Installation

1. Download the resource
2. Place the `journal` folder in your `resources/[add-scripts]` directory
3. (Optional) integrate our asset marketplace [NFTconnect](https://pixly.games/nftconnect) you will automatically receive 50% of all sales made by players on your server, Journal already supports it.
4. Add `ensure journal` to your server.cfg
5. Customize the `config.lua` file to match your server's needs
6. Restart your server

## Configuration

The journal system is highly customizable through the `config.lua` file:

### General Settings

```lua
Config.EnableKeyMapping = true      -- Enable or disable the F2 key mapping
Config.KeyCode = 289                -- F2 keycode (change to any key you prefer)
```

### Discord Webhooks

```lua
Config.DiscordWebhook = "your_discord_webhook_url"  -- For help requests
Config.CashbackWebhook = "your_cashback_webhook_url"  -- For coupon redemptions
```

### Customizing Categories

You can add, modify, remove, or reorder categories:

```lua
Config.Categories = {
    {
        id = "missions",
        label = "Missions",
        icon = "fas fa-tasks"
    },
    -- Add more categories or modify existing ones
}
```

To remove a category, simply delete its entry from the array.
To make a category not visible without deleting its content, remove it from the Categories array.

### Adding Missions with Waypoints

```lua
Config.Missions = {
    {
        id = 1,
        title = "Mission Title",
        description = "Mission description text",
        image = "URL_to_image",
        video = "URL_to_video",  -- Optional
        waypoint = {x = 123.45, y = 678.90, z = 45.67}  -- Map coordinates for the waypoint
    },
    -- Add more missions
}
```

### Adding How-To-Play Guides

```lua
Config.HowToPlay = {
    {
        id = 1,
        title = "Guide Title",
        description = "Guide description",
        image = "URL_to_image",
        video = "URL_to_video"  -- Optional
    },
    -- Add more guides
}
```

### Setting Up Store Items

```lua
Config.Store = {
    {
        id = 1,
        title = "Store Item",
        description = "Item description",
        image = "URL_to_image",
        video = "URL_to_video",  -- Optional
        webpage = "URL_to_external_page"  -- Optional, opens an external webpage
    },
    -- Add more store items
}
```

### Adding Announcements

```lua
Config.Announcements = {
    {
        id = 1,
        title = "Announcement Title",
        date = "YYYY-MM-DD",
        description = "Announcement text",
        image = "URL_to_image",  -- Optional
        video = "URL_to_video"  -- Optional
    },
    -- Add more announcements
}
```

### UI Settings

```lua
Config.WebpageSettings = {
    DefaultWidth = "80%",       -- Default width of external webpages
    DefaultHeight = "70%",      -- Default height of external webpages
    Position = "center",        -- Position: "center", "left", "right"
    BackgroundColor = "rgba(0, 0, 0, 0.85)", -- Background color
    DarkTheme = true            -- Enable dark theme for webpages
}

Config.Settings = {
    ShowF2Prompt = true  -- Controls visibility of the floating F2 button
}
```

## Store, Help and Cashback Systems

The journal includes 3 special features:

1. **Store**: By default it leads to PIXLY store, if you integrate our asset marketplace [NFTconnect](https://pixly.games/nftconnect) you will automatically receive 50% of all sales made by players on your server.
2. **Help System**: Players can submit help requests that are sent to a Discord webhook (CONFIGURE IT) for staff to review, their CitizenID is included automatically.
3. **Cashback/Ptomo codes system**: Players can enter promo codes, which are sent to a Discord webhook for verification and processing. By default, info goes to PIXLY. If you've integrated NFTconnect, your players can receive a 5% cashback for entering promo codes.

## User Settings

Players can toggle the visibility of the F2 prompt button through the Settings tab in the journal. This setting is saved per player.

## Permissions

This resource is designed for all players and does not require special permissions to use.

## Support

If you encounter any issues during setup or have questions, please visit Discord or see website for contact information:

## Credits

Created by Pixly Games

## License

MIT license.
