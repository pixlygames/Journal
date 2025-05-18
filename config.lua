Config = {}

-- General Settings
Config.EnableKeyMapping = true      -- Enable or disable the key mapping (F2 key)
Config.KeyCode = 289                -- F2 keycode

-- Discord Webhook for support.
Config.DiscordWebhook = "YOUR WEBHOOK"

-- Discord Webhook for promo codes.
Config.CashbackWebhook = "YOUR WEBHOOK"

-- Categories Content
Config.Categories = {
    {
        id = "missions",
        label = "Missions",
        icon = "fas fa-tasks"
    },
    {
        id = "howtoplay",
        label = "How to Play",
        icon = "fas fa-book"
    },
    {
        id = "store",
        label = "Store",
        icon = "fas fa-store"
    },
    {
        id = "announcements",
        label = "Announcements",
        icon = "fas fa-bullhorn"
    },
    {
        id = "help",
        label = "Help",
        icon = "fas fa-question-circle"
    },
    {
        id = "cashback",
        label = "Cashback",
        icon = "fas fa-percentage"
    },
    {
        id = "settings",
        label = "Settings",
        icon = "fas fa-cog"
    }
}

-- Missions with waypoints
Config.Missions = {
    {
        id = 1,
        title = "Connect wallet to get apartment & car",
        description = "Just create a Telegram wallet and get your first apartment in the city and a car.",
        image = "https://img.gta5-mods.com/q95/images/modern-hotel-room/724dc9-THUMB.jpg",
        video = "https://drive.google.com/file/d/1alOtZgIdaxR4cqUmEG9v_VlU21e234H_/view?usp=sharing",
        waypoint = {x = -294.76, y = -829.96, z = 32.2}
    },
    {
        id = 2,
        title = "Steal cars",
        description = "If you bring a car to us, we will reward you, but drive fast, another gang is looking for that car too.",
        image = "https://rockstarintel.com/wp-content/uploads/2024/02/a33fb9e0bea6e21dca177e7e239720010736962f.jpg",
        video = "https://drive.google.com/file/d/1M5HET19lRFaUPCm2-bro2HkY9xsvVUAW/view?usp=sharing",
        waypoint = {x = -305.66, y = -897.74, z = 31.08}
    },
    {
        id = 3,
        title = "Kill targets",
        description = "Take as many guns as you can, you will need them. Even better if you can take a partner to help.",
        image = "https://static0.gamerantimages.com/wordpress/wp-content/uploads/2022/11/gta-online-kill-players-passive-mode.jpg",
        video = "https://drive.google.com/file/d/1G01f9vlszsTijiOJdUVTNRLUvA3uxKRS/view?usp=sharing",
        waypoint = {x = -616.03, y = 186.98, z = 69.33}
    },
    {
        id = 4,
        title = "Sell drugs",
        description = "Get supplies, visit meth and coke labs or a weed farm, sell the product on the streets or call El Cartel.",
        image = "https://static1.srcdn.com/wordpress/wp-content/uploads/2023/02/how-where-to-buy-a-weed-farm-in-gta-online.jpg",
        video = "https://drive.google.com/file/d/1wmEICwOumYRGWA-39eDQ0SyGPhGBKi4X/view?usp=sharing",
        waypoint = {x = 419.68, y = -2060.0, z = 22.2}
    },
    {
        id = 5,
        title = "Sell product",
        description = "Collect drugs and weapons in the city, call El Cartel and sell them.",
        image = "https://static.wixstatic.com/media/22b8f8_c96e2db79b5d4701857f7a7234dca953~mv2.jpg/v1/fill/w_960,h_535,al_c,q_85,enc_avif,quality_auto/22b8f8_c96e2db79b5d4701857f7a7234dca953~mv2.jpg",
        video = "https://drive.google.com/file/d/187_HXJwD0Bi7OYIA5KLcnQvxyX30YcQH/view?usp=sharing",
        waypoint = {x = -3266.23, y = 843.52, z = 2.92}
    },
    {
        id = 6,
        title = "Jewelry store robbery",
        description = "Buy a shotgun and rob a jewelry store, but know that the cops are coming.",
        image = "https://cdn.discordapp.com/attachments/1356332904652996743/1373734293964193973/j.jpeg?ex=682b7d42&is=682a2bc2&hm=b839ba90513cb31ef8b3cea97db9553a8ac1701cd0fc849b4cbceea0dd3980a6&",
        video = "https://drive.google.com/file/d/1-MmdANSHyXOY3rSj32QU7eerQcLDlzPX/view?usp=sharing",
        waypoint = {x = -633.67, y = -238.96, z = 38.06}
    },
    {
        id = 7,
        title = "Visit Casino",
        description = "A chance to win a car and more — you'll need $5,000 just to sit at the table.",
        image = "https://oyster.ignimgs.com/mediawiki/apis.ign.com/grand-theft-auto-5/e/e4/GTAO_1.jpg",
        waypoint = {x = 922.42, y = 46.92, z = 81.11}
    },
    {
        id = 8,
        title = "Steam room",
        description = "This one's for you if you like it rough and have a spare $5,000.",
        image = "https://media.discordapp.net/attachments/1356332904652996743/1356335249071800370/steam_room2.jpeg?ex=67ec3122&is=67eadfa2&hm=9ba24734492a4a99eb71db35f9e763cf800807b7e7c0d6b06934f798e0ba60bb&=&format=webp&width=2636&height=1307",
        waypoint = {x = 1002.82, y = -2412.41, z = 30.51}
    },
    {
        id = 9,
        title = "Civil Jobs",
        description = "If you're just starting and don't want to break the law, it's the right choice.",
        image = "https://gtametro.wordpress.com/wp-content/uploads/2017/01/construction-workers-with-plans.jpg?w=1024",
        video = "https://drive.google.com/file/d/1ubTHXjuya8U5OuncXXhD0l2tn1vvucUZ/view?usp=sharing",
        waypoint = {x = -262.62, y = -965.97, z = 31.22}
    }
}

-- How to Play content
Config.HowToPlay = {
    {
        id = 1,
        title = "Store",
        description = "How to buy cars and houses.",
        image = "https://media.discordapp.net/attachments/1356332904652996743/1358398610789765120/1.png?ex=67f3b2ca&is=67f2614a&hm=647dda35c22a1de8a3b308ec290762eed66c3b7953c9c59d3f5e8e605e4efb50&=&format=webp&quality=lossless&width=2520&height=1307",
        video = "https://drive.google.com/file/d/1gm8JzJQcZQUXSfkzjyqysNNohR0HeCc0/view?usp=sharing"
    },
    {
        id = 2,
        title = "Weapons",
        description = "How to get and use weapons.",
        image = "https://static0.gamerantimages.com/wordpress/wp-content/uploads/2023/07/grand-theft-auto-5-23-most-powerful-weapons-ranked.jpg",
        video = "https://drive.google.com/file/d/1aUuvvvOZzFf9fFn-kczmV5kTiS7wCVy1/view?usp=sharing"
    },
    {
        id = 3,
        title = "Buy house (in-game money)",
        description = "How to buy a house with in-game money.",
        image = "https://preview.redd.it/whats-your-favourite-house-in-gta-online-v0-3gtbollvjh9d1.jpeg?width=3840&format=pjpg&auto=webp&s=923e09bafe1ec85c0d2d1745f34c0be75341a055",
        video = "https://drive.google.com/file/d/1MoCcjaS36FsGyy_Y3JCPMCF7MGmKOAL7/view?usp=sharing"
    },
    {
        id = 4,
        title = "F1 interaction menu",
        description = "Press F1 to interact with the world.",
        image = "https://forum-cfx-re.akamaized.net/original/4X/c/8/9/c89853ce1195e08bcfdca638c0f1109fc99cc5f7.jpeg",
        video = "https://drive.google.com/file/d/1_APKRh_PLKePHM9286kpc1YXha-dRMCG/view?usp=sharing"
    }
}

-- Store content
Config.Store = {
    {
        id = 1,
        title = "Vehicle Shop",
        description = "Buy an NFT, connect your wallet and ride your new car.",
        image = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvSdSscFMZJIP3nBc-tPvm7grmm8FPyQBSzg&s",
        video = "",
        webpage = "https://getgems.io/collection/EQBmuQ8GKlpRja2lN6eXqhT1snEaqkmVOxh-lJ3elOFhxukl"
    },
    {
        id = 2,
        title = "Property Shop",
        description = "Buy an NFT, connect your wallet and get your new house.",
        image = "https://img.gta5-mods.com/q75/images/improved-malibu-mansion-missysnowie-bigshaqnoketchup/61937a-MalibuMansion1.jpg",
        video = "",
        webpage = "https://getgems.io/collection/EQD1tMV65CxBUxqGPcjlOB3Aqs9GNOhNdfm1jqDa-2nCpU18"
    },
    {
        id = 3,
        title = "Clothing Store",
        description = "Customize your character with the latest fashion.",
        image = "https://img.gta5-mods.com/q75/images/a-large-package-of-clothes-for-franklin/c57eeb-grand-theft-auto-v-sunset-artwork-lu-2048x1152.jpg",
        video = ""
    }
}

-- Webpage Settings
Config.WebpageSettings = {
    DefaultWidth = "80%",       -- Default width of the webpage when not in fullscreen
    DefaultHeight = "70%",      -- Default height of the webpage when not in fullscreen
    Position = "center",        -- Position of the webpage: "center", "left", "right"
    BackgroundColor = "rgba(0, 0, 0, 0.85)", -- Background color behind the webpage
    DarkTheme = true            -- Enable dark theme for webpages using the site's built-in theme settings
}

-- Announcements content
Config.Announcements = {
    {
        id = 1,
        title = "We are looking for all roles on server (admin, cop, etc.)",
        date = "2025-05-01",
        description = "Reach out in dicord YOUR DISCORD.",
        image = "https://assets-prd.ignimgs.com/2022/03/08/image-2022-03-08-111545-1646738145870.png",
        video = ""
    }
}

-- Settings
Config.Settings = {
    ShowF2Prompt = true -- This now controls the visibility of the floating button
} 