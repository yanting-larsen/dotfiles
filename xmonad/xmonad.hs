import XMonad
import XMonad.Prompt
import System.Exit

-- Util
import XMonad.Util.EZConfig
import XMonad.Util.Run

-- Hooks
import XMonad.Hooks.DynamicHooks
import XMonad.Hooks.ManageHelpers

-- Actions
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.GridSelect
import XMonad.Actions.TopicSpace
import XMonad.Actions.WithAll

-- Layout
import XMonad.Layout.NoBorders

-- Custom
import Config
import Utils
import Hooks
import Topics

-- Keys
myKeys :: [(String, X())]
myKeys =
    -- Window Manager Keys
    [ ("M-n"            , refresh                       ) -- Re-draw window
    , ("M-a"            , addWorkspacePrompt myXPConfig ) -- Create a new workspace
    , ("M-S-a"          , renameWorkspace myXPConfig    ) -- Rename workspace
    , ("M-g"            , goToSelected defaultGSConfig  ) -- Grid select
    , ("M-S-s"          , promptedShift                 ) -- Move window
    , ("M-<Tab>"        , myToggleWS                    ) -- Toggle workspace,
    , ("M-r"            , spawn "xmonad --recompile"    ) -- Recompile XMonad
    , ("M-q"            , restartXMonad                 ) -- Restart XMonad
    , ("M-S-q"          , io (exitWith ExitSuccess)     ) -- Quit XMonad

    -- Workspace Keys
    , ("M-w 1"          , createOrGoto "dashboard"      )
    , ("M-w n"          , createOrGoto "note"           )
    , ("M-w c"          , createOrGoto "code"           )
    , ("M-w w"          , createOrGoto "web"            )
    , ("M-w m"          , createOrGoto "music"          )
    , ("M-w v"          , createOrGoto "video"          )
    , ("M-w p"          , createOrGoto "pdf"            )
    , ("M-w f"          , createOrGoto "file"           )
    , ("M-w s"          , createOrGoto "skype"          )
    , ("M-w <Backspace>", killAll >> removeWorkspace >>
                            createOrGoto "dashboard"    ) -- Removes current workspace

    -- Launch Keys
    , ("M-p"            , programLauncher               ) -- Launcher
    , ("M-x e"          , spawnEditor                   ) -- Launch editor
    , ("M-x w"          , spawn "chromium"              ) -- Launch browser
    , ("M-x f"          , spawnFile                     ) -- Browse files

    -- Media Keys
    , ("M-<Esc>", spawn "i3lock -i ~/Pictures/saltside.png -c 000000" ) -- Lock screen
    , ("M-`"                    , spawn "scrot"                       ) -- Screenshot
    , ("M-S-`"                  , spawn "sleep 0.2; scrot -s"         ) -- Partial screenshot
    , ("<XF86MonBrightnessUp>"  , spawn "xbacklight -inc 10"          ) -- Brighness up
    , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10"          ) -- Brighness down
    , ("<XF86AudioPlay>"        , spawn "ncmpcpp toggle"              ) -- Play/Pause track
    , ("<XF86AudioStop>"        , spawn "ncmpcpp stop"                ) -- Stop track
    , ("<XF86AudioNext>"        , spawn "ncmpcpp next"                ) -- Next track
    , ("<XF86AudioPrev>"        , spawn "ncmpcpp prev"                ) -- Previous track
    , ("<XF86AudioLowerVolume>" , spawn "amixer -q set Master 5%-"    ) -- Decrease volume
    , ("<XF86AudioRaiseVolume>" , spawn "amixer -q set Master 5%+"    ) -- Increase volume
    , ("<XF86AudioMute>"        , spawn "amixer -q set Master toggle" ) -- Mute volume
    ]

main = do
    xmonad $ defaultConfig
        { workspaces         = ["dashboard", "note"]
        , modMask            = myModMask
        , terminal           = myTerminal
        , focusFollowsMouse  = myFocusFollowsMouse
        , clickJustFocuses   = myClickJustFocuses
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , layoutHook         = smartBorders $ layoutHook defaultConfig
        , manageHook         = myManageHook
        } `additionalKeysP` myKeys
