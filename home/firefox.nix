{ config, pkgs, ... }:

let
  extension = url: {
    installation_mode = "force_installed";
    install_url = url;
    private_browsing = false;
  };

  amo = slug: extension
    "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
in

{
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;
      settings = {
        # Startup
        "browser.startup.homepage"                                   = "about:home";
        "browser.startup.page"                                       = 1;
        "browser.newtabpage.activity-stream.default.sites"           = "";

        # UI
        "browser.compactmode.show" = true;
        "browser.uidensity"        = 1;

        # AI / ML - master switch and individual features
        "browser.ml.enable"                               = false;
        "browser.ml.chat.enabled"                         = false;
        "browser.ml.chat.sidebar"                         = false;
        "browser.ml.chat.shortcuts"                       = false;
        "browser.ml.chat.openSidebarOnProviderChange"     = false;

        # Firefox Suggest (AI-powered address bar suggestions)
        "browser.urlbar.quicksuggest.enabled"                    = false;
        "browser.urlbar.quicksuggest.dataCollection.enabled"     = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored"       = false;
        "browser.urlbar.suggest.quicksuggest.sponsored"          = false;
        "browser.urlbar.recentsearches.featureGate"              = false;
        "browser.urlbar.trending.featureGate"                    = false;

        # AI tab group naming
        "browser.tabs.groups.smartGroupName.enabled" = false;

        # Translation suggestions
        "browser.translations.automaticallyPopup" = false;

        # Personalised recommendations on new tab
        "browser.newtabpage.activity-stream.feeds.recommendationprovider"       = false;
        "browser.newtabpage.activity-stream.discoverystream.personalization.enabled" = false;

        # Sponsored content on new tab
        "browser.newtabpage.activity-stream.showSponsored"         = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

        # Privacy
        "browser.contentblocking.category"                  = "strict";
        "privacy.globalprivacycontrol.enabled"               = true;
        "privacy.globalprivacycontrol.functionality.enabled" = true;
        "permissions.default.geo"                            = 2;
        "dom.security.credentialmanagement.identity.enabled" = false;

        # Passwords and autofill
        "signon.rememberSignons"                      = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # Telemetry and studies
        "datareporting.healthreport.uploadEnabled"     = false;
        "datareporting.policy.dataSubmissionEnabled"   = false;
        "datareporting.usage.uploadEnabled"            = false;
        "toolkit.telemetry.enabled"                    = false;
        "toolkit.telemetry.unified"                    = false;
        "app.shield.optoutstudies.enabled"             = false;
        "app.normandy.enabled"                         = false;

        # HTTPS only (all windows including private)
        "dom.security.https_only_mode"     = true;
        "dom.security.https_only_mode_pbm" = true;

        # DNS over HTTPS - mode 2 = increased protection
        "network.trr.mode" = 2;
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            "nav-bar" = [
              "home-button"
              "back-button"
              "forward-button"
              "stop-reload-button"
              "urlbar-container"
              "downloads-button"
              "unified-extensions-button"
              "PanelUI-button"
            ];
            "unified-extensions-area" = [
              "frankerfacez_frankerfacez_com-browser-action"
              "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
              "_25cddbee-458b-4e9f-984d-dbf35511f124_-browser-action"
              "_20f79db9-a1ed-4213-bb6a-002a6b8b6c59_-browser-action"
              "moz-addon-prod_7tv_app-browser-action"
              "_windscribeff-browser-action"
              "ublock0_raymondhill_net-browser-action"
            ];
            "toolbar-menubar" = [ "menubar-items" ];
            "TabsToolbar"     = [ "tabbrowser-tabs" "new-tab-button" ];
            "vertical-tabs"   = [];
            "PersonalToolbar" = [ "personal-bookmarks" ];
            "widget-overflow-fixed-list" = [];
          };
          seen = [
            "save-to-pocket-button"
            "developer-button"
            "screenshot-button"
            "ublock0_raymondhill_net-browser-action"
            "frankerfacez_frankerfacez_com-browser-action"
            "moz-addon-prod_7tv_app-browser-action"
            "_windscribeff-browser-action"
            "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
            "_25cddbee-458b-4e9f-984d-dbf35511f124_-browser-action"
            "_20f79db9-a1ed-4213-bb6a-002a6b8b6c59_-browser-action"
          ];
          dirtyAreaCache = [
            "nav-bar"
            "PersonalToolbar"
            "toolbar-menubar"
            "TabsToolbar"
            "unified-extensions-area"
            "vertical-tabs"
          ];
          currentVersion = 24;
          newElementCount = 0;
        };
      };
    };

    policies = {
      SearchEngines.Default = "DuckDuckGo";
      DisableTelemetry      = true;
      DisableFirefoxStudies = true;
      PasswordManagerEnabled = false;
      HttpsOnlyMode         = "force_enabled";

      ExtensionSettings = {
      "moz-addon-prod@7tv.app"                 = amo "7tv";
      "{25cddbee-458b-4e9f-984d-dbf35511f124}" = amo "betterttv";
      "frankerfacez@frankerfacez.com"          = amo "frankerfacez";
      "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = amo "return-youtube-dislikes";
      "@windscribeff"                          = amo "windscribe";
      "{20f79db9-a1ed-4213-bb6a-002a6b8b6c59}" = amo "youtube-thumbnail-size-fixer";

      # uBlock Origin - also allowed in private browsing
      "uBlock0@raymondhill.net" = (amo "ublock-origin")
        // { private_browsing = true; };
      };
    };
  };
}
