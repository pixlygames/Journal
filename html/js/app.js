$(function() {
    // Variables
    let journalData = {};
    // Get the resource name dynamically
    const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'journal'; // Fallback for testing in browser
    
    // Listen for NUI messages from the FiveM client
    window.addEventListener('message', function(event) {
        const data = event.data;
        const action = data.action;
        const buttonContainer = document.getElementById('button-container'); // Get button container element
        
        if (action === 'open') {
            $('#journal-app').removeClass('hidden');
            loadJournalData();
        } else if (action === 'close') {
            $('#journal-app').addClass('hidden');
        } else if (action === 'showButton' && buttonContainer) {
            // Handle button visibility
            buttonContainer.style.display = 'block';
        } else if (action === 'hideButton' && buttonContainer) {
            buttonContainer.style.display = 'none';
        }
    });
    
    // Load Journal Data
    function loadJournalData() {
        $.post('https://journal/loadData', {}, function(data) {
            journalData = data;
            
            // Setup categories menu
            setupMenu(journalData.categories);
            
            // Load content for each tab
            loadMissions(journalData.missions);
            loadHowToPlay(journalData.howToPlay);
            loadStore(journalData.store);
            loadAnnouncements(journalData.announcements);
            
            // Initialize settings
            initSettings(journalData.settings);
            
            // Setup Cashback functionality
            setupCashback();
        });
    }
    
    // Setup Cashback functionality
    function setupCashback() {
        $('#apply-coupon').on('click', function() {
            const couponCode = $('#coupon-code').val().trim();
            
            if (couponCode !== '') {
                // Add loading state
                const button = $(this);
                const originalText = button.text();
                button.html('<i class="fas fa-spinner fa-spin"></i> Applying...');
                button.prop('disabled', true);
                
                $.post('https://journal/submitCoupon', JSON.stringify({
                    coupon: couponCode
                }));
                
                // Reset form after short delay and show success message
                setTimeout(function() {
                    button.html('<i class="fas fa-check"></i> Applied');
                    $('#cashback-result').removeClass('hidden');
                    
                    setTimeout(function() {
                        button.html(originalText);
                        button.prop('disabled', false);
                    }, 3000);
                }, 1000);
            } else {
                // Show error if coupon code is empty
                $('#coupon-code').css('border-color', '#FF4757');
                $('#coupon-code').attr('placeholder', 'Please enter a coupon code');
                
                setTimeout(function() {
                    $('#coupon-code').css('border-color', '');
                    $('#coupon-code').attr('placeholder', 'Enter your coupon code (e.g. Zez2025)');
                }, 3000);
            }
        });
    }
    
    // Setup Categories Menu
    function setupMenu(categories) {
        const menuContainer = $('#menu');
        menuContainer.empty();
        
        categories.forEach(function(category) {
            const menuItem = $(`
                <div class="menu-item" data-tab="${category.id}">
                    <i class="${category.icon}"></i>
                    <span>${category.label}</span>
                </div>
            `);
            
            menuContainer.append(menuItem);
        });
        
        // Set the first menu item as active
        $('.menu-item').first().addClass('active');
        
        // Add click event to menu items
        $('.menu-item').on('click', function() {
            const tabId = $(this).data('tab');
            
            // Update active menu item
            $('.menu-item').removeClass('active');
            $(this).addClass('active');
            
            // Show the corresponding tab with animation
            $('.tab-content').addClass('hidden');
            $(`#${tabId}-tab`).removeClass('hidden');
        });
    }
    
    // Initialize Settings
    function initSettings(settings) {
        // Set F2 Prompt toggle based on settings
        $('#toggle-prompt').prop('checked', settings.ShowF2Prompt);
        
        // Add event listener for toggle
        $('#toggle-prompt').on('change', function() {
            const isChecked = $(this).is(':checked');
            
            // Send NUI callback to update the setting
            $.post('https://journal/togglePrompt', JSON.stringify({
                showPrompt: isChecked
            }));
        });
    }
    
    // Load Missions Content
    function loadMissions(missions) {
        const container = $('#missions-container');
        container.empty();
        
        if (missions.length === 0) {
            container.html('<div class="no-content">No missions available at this time.</div>');
            return;
        }
        
        missions.forEach(function(mission) {
            const hasVideo = mission.video && mission.video !== "";
            const missionCard = $(`
                <div class="mission-card">
                    <img src="${mission.image}" alt="${mission.title}" class="mission-img">
                    <div class="mission-content">
                        <h3 class="mission-title">${mission.title}</h3>
                        <p class="mission-description">${mission.description}</p>
                        <div class="mission-buttons">
                            <button class="mission-btn waypoint-btn" data-mission="${mission.id}">
                                <i class="fas fa-map-marker-alt"></i> Set Waypoint
                            </button>
                            ${hasVideo ? `
                                <button class="mission-btn video-btn" data-video="${mission.video}">
                                    <i class="fas fa-play"></i> Watch Video
                                </button>
                            ` : ''}
                        </div>
                    </div>
                </div>
            `);
            
            container.append(missionCard);
        });
        
        // Add click event for waypoint buttons
        $('.waypoint-btn').on('click', function() {
            const missionId = parseInt($(this).data('mission'));
            
            // Adding a visual feedback
            const button = $(this);
            button.html('<i class="fas fa-check"></i> Waypoint Set');
            button.css('background-color', 'rgba(0, 200, 0, 0.7)');
            
            setTimeout(function() {
                button.html('<i class="fas fa-map-marker-alt"></i> Set Waypoint');
                button.css('background-color', '');
            }, 2000);
            
            $.post('https://journal/setWaypoint', JSON.stringify({
                missionId: missionId
            }));
        });
        
        // Add click event for video buttons
        $('.video-btn').on('click', function() {
            const videoUrl = $(this).data('video');
            openVideoModal(videoUrl);
        });
    }
    
    // Load How To Play Content
    function loadHowToPlay(guides) {
        const container = $('#guide-container');
        container.empty();
        
        if (guides.length === 0) {
            container.html('<div class="no-content">No guides available at this time.</div>');
            return;
        }
        
        guides.forEach(function(guide) {
            const hasVideo = guide.video && guide.video !== "";
            const guideCard = $(`
                <div class="guide-card">
                    <img src="${guide.image}" alt="${guide.title}" class="guide-img">
                    <div class="guide-content">
                        <h3 class="guide-title">${guide.title}</h3>
                        <p class="guide-description">${guide.description}</p>
                        ${hasVideo ? `
                            <button class="mission-btn video-btn" data-video="${guide.video}">
                                <i class="fas fa-play"></i> Watch Tutorial
                            </button>
                        ` : ''}
                    </div>
                </div>
            `);
            
            container.append(guideCard);
        });
        
        // Add click event for video buttons
        $('.video-btn').on('click', function() {
            const videoUrl = $(this).data('video');
            openVideoModal(videoUrl);
        });
    }
    
    // Load Store Content
    function loadStore(items) {
        const container = $('#store-container');
        container.empty();
        
        if (items.length === 0) {
            container.html('<div class="no-content">No store items available at this time.</div>');
            return;
        }
        
        items.forEach(function(item) {
            const hasVideo = item.video && item.video !== "";
            const hasWebpage = item.webpage && item.webpage !== "";
            
            const storeCard = $(`
                <div class="store-card">
                    <img src="${item.image}" alt="${item.title}" class="store-img">
                    <div class="store-content">
                        <h3 class="store-title">${item.title}</h3>
                        <p class="store-description">${item.description}</p>
                        <div class="store-buttons">
                            ${hasVideo ? `
                                <button class="mission-btn video-btn" data-video="${item.video}">
                                    <i class="fas fa-play"></i> Watch Preview
                                </button>
                            ` : ''}
                            ${hasWebpage ? `
                                <button class="mission-btn webpage-btn" data-webpage="${item.webpage}">
                                    <i class="fas fa-globe"></i> Open Webpage
                                </button>
                            ` : ''}
                        </div>
                    </div>
                </div>
            `);
            
            container.append(storeCard);
        });
        
        // Add click event for video buttons
        $('.video-btn').on('click', function() {
            const videoUrl = $(this).data('video');
            openVideoModal(videoUrl);
        });
        
        // Add click event for webpage buttons
        $('.webpage-btn').on('click', function() {
            const webpageUrl = $(this).data('webpage');
            openWebpageModal(webpageUrl);
        });
    }
    
    // Load Announcements Content
    function loadAnnouncements(announcements) {
        const container = $('#announcements-container');
        container.empty();
        
        if (announcements.length === 0) {
            container.html('<div class="no-content">No announcements available at this time.</div>');
            return;
        }
        
        announcements.forEach(function(announcement) {
            const hasVideo = announcement.video && announcement.video !== "";
            const announcementCard = $(`
                <div class="announcement-card">
                    <img src="${announcement.image}" alt="${announcement.title}" class="announcement-img">
                    <div class="announcement-content">
                        <p class="announcement-date">${announcement.date}</p>
                        <h3 class="announcement-title">${announcement.title}</h3>
                        <p class="announcement-description">${announcement.description}</p>
                        ${hasVideo ? `
                            <button class="mission-btn video-btn" data-video="${announcement.video}">
                                <i class="fas fa-play"></i> Watch Video
                            </button>
                        ` : ''}
                    </div>
                </div>
            `);
            
            container.append(announcementCard);
        });
        
        // Add click event for video buttons
        $('.video-btn').on('click', function() {
            const videoUrl = $(this).data('video');
            openVideoModal(videoUrl);
        });
    }
    
    // Open Video Modal
    function openVideoModal(videoUrl) {
        let embedUrl = videoUrl;
        
        // Process Google Drive URL
        if (videoUrl.includes('drive.google.com/file/d/')) {
            // Extract the file ID from the Google Drive URL
            const fileIdMatch = videoUrl.match(/\/d\/([^/]+)/);
            if (fileIdMatch && fileIdMatch[1]) {
                const fileId = fileIdMatch[1];
                embedUrl = `https://drive.google.com/file/d/${fileId}/preview`;
            }
        }
        
        const modal = $(`
            <div class="video-modal">
                <div class="video-container">
                    <span class="close-video">&times;</span>
                    <iframe class="video-iframe" src="${embedUrl}" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" allow="autoplay; fullscreen"></iframe>
                </div>
            </div>
        `);
        
        $('body').append(modal);
        
        // Add click event to close the modal
        $('.close-video').on('click', function() {
            $('.video-modal').remove();
        });
        
        // Close modal when clicking outside the video container
        $('.video-modal').on('click', function(e) {
            if ($(e.target).hasClass('video-modal')) {
                $('.video-modal').remove();
            }
        });
        
        // Close modal when pressing ESC key
        $(document).on('keydown', function(e) {
            if (e.key === "Escape") {
                $('.video-modal').remove();
            }
        });
    }
    
    // Open Webpage Modal
    function openWebpageModal(webpageUrl) {
        // Get width and height from journalData settings
        const width = journalData.webpageSettings ? journalData.webpageSettings.DefaultWidth : "80%";
        const height = journalData.webpageSettings ? journalData.webpageSettings.DefaultHeight : "70%";
        const position = journalData.webpageSettings ? journalData.webpageSettings.Position : "center";
        const bgColor = journalData.webpageSettings ? journalData.webpageSettings.BackgroundColor : "rgba(0, 0, 0, 0.85)";
        
        // Create positional class
        let positionClass = "position-center";
        if (position === "left") positionClass = "position-left";
        if (position === "right") positionClass = "position-right";
        
        // Check if dark theme is enabled
        const darkThemeEnabled = journalData.webpageSettings && journalData.webpageSettings.DarkTheme;
        
        // Modify URL to force dark theme if enabled
        let modifiedUrl = webpageUrl;
        if (darkThemeEnabled && webpageUrl.includes('getgems.io')) {
            // Add a URL parameter to set dark theme
            const urlSeparator = webpageUrl.includes('?') ? '&' : '?';
            modifiedUrl = `${webpageUrl}${urlSeparator}_theme=dark`;
        }
        
        const modal = $(`
            <div class="webpage-modal" style="background-color: ${bgColor}">
                <div class="webpage-container ${positionClass}" style="width: ${width}; height: ${height};">
                    <div class="webpage-header">
                        <span class="webpage-title">${webpageUrl}</span>
                        <div class="webpage-controls">
                            <span class="back-webpage"><i class="fas fa-arrow-left"></i></span>
                            <span class="fullscreen-webpage"><i class="fas fa-expand"></i></span>
                            <span class="close-webpage"><i class="fas fa-times"></i></span>
                        </div>
                    </div>
                    <iframe class="webpage-iframe" id="webpage-iframe" src="${modifiedUrl}" allowfullscreen="true"></iframe>
                </div>
            </div>
        `);
        
        $('body').append(modal);
        
        let isFullscreen = false;
        
        // Toggle fullscreen mode
        $('.fullscreen-webpage').on('click', function() {
            isFullscreen = !isFullscreen;
            
            if (isFullscreen) {
                $('.webpage-container').css({
                    'width': '100%',
                    'height': '100%',
                    'max-width': '100%',
                    'max-height': '100%',
                    'margin': '0',
                    'position': 'fixed',
                    'top': '0',
                    'left': '0',
                    'border-radius': '0'
                });
                $(this).html('<i class="fas fa-compress"></i>');
            } else {
                $('.webpage-container').css({
                    'width': width,
                    'height': height,
                    'max-width': '',
                    'max-height': '',
                    'margin': '',
                    'position': '',
                    'top': '',
                    'left': '',
                    'border-radius': ''
                }).removeClass('fullscreen').addClass(positionClass);
                $(this).html('<i class="fas fa-expand"></i>');
            }
        });
        
        // Add click event for back button
        $('.back-webpage').on('click', function() {
            const iframe = document.getElementById('webpage-iframe');
            
            try {
                if (iframe && iframe.contentWindow) {
                    iframe.contentWindow.history.back();
                }
            } catch (e) {
                console.log('Error navigating back:', e);
                
                // Alternative method: reload iframe with previous URL
                // This is a fallback in case direct history manipulation fails
                try {
                    if (iframe.contentWindow.location.href !== modifiedUrl) {
                        iframe.contentWindow.location.href = iframe.contentWindow.location.href;
                    }
                } catch (e2) {
                    console.log('Alternative navigation failed:', e2);
                }
                
                // Visual feedback when back navigation fails
                $(this).css('color', 'rgba(255, 255, 255, 0.3)');
                setTimeout(() => {
                    $(this).css('color', '');
                }, 500);
            }
        });
        
        // Add click event to close the modal
        $('.close-webpage').on('click', function() {
            $('.webpage-modal').remove();
        });
        
        // Close modal when pressing ESC key
        $(document).on('keydown.webpageModal', function(e) {
            if (e.key === "Escape") {
                $('.webpage-modal').remove();
                $(document).off('keydown.webpageModal');
            }
        });
        
        // Apply dark theme to the iframe immediately before it loads
        if (darkThemeEnabled) {
            // Create a dark overlay that will be shown during loading
            const darkOverlay = $('<div class="webpage-loading-overlay"></div>');
            $('.webpage-container').append(darkOverlay);
            
            // Remove the overlay when the iframe loads
            $('#webpage-iframe').on('load', function() {
                // Remove the loading overlay
                $('.webpage-loading-overlay').fadeOut(300, function() {
                    $(this).remove();
                });
                
                try {
                    const iframe = document.getElementById('webpage-iframe');
                    const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
                    
                    // Force dark theme using document.body.dataset.colorScheme
                    const script = document.createElement('script');
                    script.textContent = `
                        try {
                            // Set the savedAppTheme to dark (this is used by getgems.io)
                            localStorage.setItem('savedAppTheme', 'dark');
                            
                            // Set the body attribute
                            document.body.dataset.colorScheme = 'dark';
                            
                            // Force dark theme in case the site uses other mechanisms
                            const darkModeStyleTag = document.createElement('style');
                            darkModeStyleTag.innerHTML = 'html,body { color-scheme: dark !important; }';
                            document.head.appendChild(darkModeStyleTag);
                            
                            // Force dark theme using meta tag
                            let metaThemeColor = document.querySelector('meta[name="theme-color"]');
                            if (!metaThemeColor) {
                                metaThemeColor = document.createElement('meta');
                                metaThemeColor.name = 'theme-color';
                                document.head.appendChild(metaThemeColor);
                            }
                            metaThemeColor.content = '#121212';
                        } catch(e) {
                            console.error('Error applying dark theme:', e);
                        }
                    `;
                    iframeDoc.body.appendChild(script);
                } catch (e) {
                    console.log('Could not apply dark theme - cross-origin restrictions');
                }
            });
        }
    }
    
    // Close button event
    $('#close-button').on('click', function() {
        $('#journal-app').addClass('hidden');
        $.post('https://journal/close', {});
    });
    
    // Submit help request
    $('#submit-help').on('click', function() {
        const message = $('#help-message').val().trim();
        
        if (message !== '') {
            // Add loading state
            const button = $(this);
            const originalText = button.text();
            button.html('<i class="fas fa-spinner fa-spin"></i> Sending...');
            button.prop('disabled', true);
            
            $.post('https://journal/submitHelp', JSON.stringify({
                message: message
            }));
            
            // Reset form after short delay
            setTimeout(function() {
                $('#help-message').val('');
                button.html('<i class="fas fa-check"></i> Sent!');
                
                setTimeout(function() {
                    button.html(originalText);
                    button.prop('disabled', false);
                }, 1500);
            }, 1000);
        } else {
            // Show error if message is empty
            $('#help-message').css('border-color', '#FF4757');
            $('#help-message').attr('placeholder', 'Please enter a message before submitting');
            
            setTimeout(function() {
                $('#help-message').css('border-color', '');
                $('#help-message').attr('placeholder', 'Describe your issue or question...');
            }, 3000);
        }
    });
    
    // Close journal when pressing ESC key
    $(document).on('keydown', function(e) {
        if (e.key === "Escape") {
            $('#journal-app').addClass('hidden');
            $.post('https://journal/close', {});
        }
    });
    
    // CSS Class for empty sections
    $("<style>")
        .prop("type", "text/css")
        .html(`
            .no-content {
                padding: 20px;
                text-align: center;
                background-color: rgba(0, 0, 0, 0.7);
                border-radius: 6px;
                color: #b0b0b0;
                margin: 20px 0;
                border: 1px solid rgba(255, 255, 255, 0.1);
            }
        `)
        .appendTo("head");
}); 