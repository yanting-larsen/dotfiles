module Keys where

import XMonad
import XMonad.Prompt.Shell

import Control.Monad

import XMonad.Actions.FloatKeys
import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.GridSelect
import XMonad.Actions.Navigation2D
import XMonad.Actions.WithAll
import XMonad.Actions.Search
import XMonad.Actions.WindowGo
import XMonad.Actions.Warp
import XMonad.Actions.TagWindows

import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook

import XMonad.Layout.Reflect
import XMonad.Layout.MultiToggle
import XMonad.Layout.Minimize
import XMonad.Layout.GridVariants (ChangeMasterGridGeom (IncMasterCols, IncMasterRows))
import qualified XMonad.Layout.BoringWindows as BW

import qualified XMonad.Util.NamedScratchpad as NS

import qualified XMonad.StackSet as W
import qualified XMonad.Hooks.ManageDocks as MD

-- Data module
import Data.Maybe (isJust, listToMaybe)
import Data.Monoid
import qualified Data.Map as M

import XMonad.Util.ToggleFloat (toggleFloat)

import Config
import Utils
import Hooks
import Topics

myKeys :: [(String, X ())]
myKeys =
    -- Layout
    [ ("M-\\", sendMessage $ Toggle REFLECTX)
    , ("M-S-\\", sendMessage $ Toggle REFLECTY)
    , ("M-S--", sendMessage $ IncMasterCols 1)
    , ("M-S-=", sendMessage $ IncMasterCols (-1))
    , ("M-C--", sendMessage $ IncMasterRows 1)
    , ("M-C-=", sendMessage $ IncMasterRows (-1))
    , ("M-t", toggleFloat)
    -- Dynamic workspaces
    , ("M-; n", addWorkspacePrompt myXPConfig)
    , ("M-; r", renameWorkspace myXPConfig)
    , ("M-; k", killAll >> removeWorkspace >> createOrGoto "dashboard")
    -- Screen navigation
    , ("M-S-j", screenGo MD.D False >> bringMouse)
    , ("M-S-k", screenGo MD.U False >> bringMouse)
    -- Workspace navigation
    , ("M-<Tab>", toggleWS' ["NSP"])
    , ("M-]", moveTo Next nonEmptyWSNoNSP)
    , ("M-[", moveTo Prev nonEmptyWSNoNSP)
    , ("M-S-]", shiftTo Next nonEmptyWSNoNSP >> moveTo Next nonEmptyWSNoNSP)
    , ("M-S-[", shiftTo Prev nonEmptyWSNoNSP >> moveTo Prev nonEmptyWSNoNSP)
    , ("M-s", selectWS)
    , ("M-S-s", takeToWS)
    -- Window navigation
    , ("M-k", BW.focusUp)
    , ("M-j", BW.focusDown)
    , ("M-m", BW.focusMaster)
    , ("M-w", selectWindow)
    , ("M-S-w", bringWindow)
    , ("M-u", focusUrgent)
    , ("M-S-u", clearUrgents)
    , ("M-b", BW.markBoring)
    , ("M-S-b", BW.clearBoring)
    -- Window tagging
    , ("M-q", tagWindow)
    , ("M-S-q", bringTagged)
    -- Sticky global window
    , ("M-z", toggleGlobal)
    -- Grid select
    , ("<XF86LaunchB>", spawnApp)
    , ("<XF86LaunchA>", selectWindow)
    , ("S-<XF86LaunchA>", bringWindow)
    -- Scratchpads
    , ("M-`"                     , scratchToggle "scratchpad")
    , ("M-S-`"                   , resetSPWindows)
    , ("M-e"                     , scratchToggle "editor")
    , ("M-<XF86AudioLowerVolume>", scratchToggle "volume")
    , ("M-<XF86AudioRaiseVolume>", scratchToggle "volume")
    , ("M-a m"                   , scratchToggle "music")
    , ("M-'"                     , scratchToggle "dictionary")
    -- Shell prompt
    , ("M-p", programLauncher)
    , ("M-S-p", shellPrompt myXPConfig)
    -- Password prompt
    , ("M-S-8", passPrompt)
    -- Lock screen
    , ("M-<Esc>", spawn "lock" )
    -- Reload XMonad
    , ("M-S-<Esc>", spawn "xmonad --recompile; xmonad --restart")
    -- Display management
    , ("M-<F1>", spawn "autorandr --load mobile")
    , ("M-<F2>", spawn "autorandr --change --default mobile")
    -- Screenshot
    , ("M-<F11>", spawn "scrot -e 'mv $f ~/pictures/screenshots/'")
    , ("M-S-<F11>", spawn "scrot --multidisp -e 'mv $f ~/pictures/screenshots/'")
    , ("M-<F12>", spawn "scrot --focused -e 'mv $f ~/pictures/screenshots/'")
    , ("M-S-<F12>", spawn "sleep 0.3; scrot --select -e 'mv $f ~/pictures/screenshots/'")
    -- Notifications
    , ("M-8", spawn "notify-send -i network -t 4000 Network \"$(ip -4 -o addr show | cut -d' ' -f2,7)\"")
    , ("M-9", spawn "notify-send -i battery -t 2000 Battery \"$(acpi)\"")
    , ("M-0", spawn "notify-send -i dialog-information -t 2000 Date \"$(date '+%F%nW%V %A%n%T')\"")
    ]
    ++ [("M-g " ++ k, createOrGoto t) | (k,t) <- workspaces]
    ++ [("M-r " ++ k, f) | (k,f) <- utils]
    ++ [("M-/ " ++ key, promptSearch myXPConfig engine) | (key, engine) <- searches]
    ++ screenKeys ++ windowKeys ++ mediaKeys
  where
    workspaces =
        [ ("-", "dashboard")
        , ("n", "note")
        , ("c", "code")
        , ("w", "web")
        , ("m", "music")
        , ("v", "video")
        , ("p", "pdf")
        , ("f", "file")
        , ("s", "speak")
        , ("d", "doc")
        ]

    utils =
        [ ("a", spawnApp)
        , ("e", spawnEditor)
        , ("w", spawn myBrowser)
        , ("f", spawnFile)
        ]

    searches =
        [ ("g", google)
        , ("w", wikipedia)
        , ("d", dictionary)
        , ("t", thesaurus)
        , ("y", youtube)
        ]

    -- Work space selection
    nonEmptyWSNoNSP = WSIs $ nonEmptyWSExcept ["NSP"]
    nonEmptyWSExcept s = return (\w -> (W.tag w `notElem` s) && isJust (W.stack w))

    -- Scratchpad invocation
    scratchToggle = NS.namedScratchpadAction myScratchpads

    -- GridSelect actions
    spawnApp     = runSelectedAction (myGSConfig pink) myApps
    selectWindow = goToSelected (myGSConfig blue) >> windows W.swapMaster
    bringWindow  = bringSelected (myGSConfig orange)
    selectWS     = gridselectWorkspace (myGSConfig green) W.greedyView
    takeToWS     = gridselectWorkspace (myGSConfig purple) (\ws -> W.greedyView ws . W.shift ws)

    -- Reset scratchpads
    resetSPWindows =
      forM_ myScratchpads $ \scratch ->
      withWindowSet $ \s ->
      do
        sPWindows <- filterM (runQuery $ NS.query scratch) (W.allWindows s)
        wTrans <- forM sPWindows . runQuery $ NS.hook scratch
        windows . appEndo . mconcat $ wTrans

    -- Window tagging
    bringTagged = withTaggedGlobalP "tagged" shiftHere >> withTaggedGlobal "tagged" (delTag "tagged")
    tagWindow   = withFocused (addTag "tagged")

    -- Colors
    blue   = myColor "#25629f"
    green  = myColor "#629f25"
    orange = myColor "#9f6225"
    pink   = myColor "#9f2562"
    purple = myColor "#62259f"

-- Window manipulation
moveToSide :: Side -> X ()
moveToSide = hookOnFocused . doSideFloat

hookOnFocused :: ManageHook -> X ()
hookOnFocused hook = withFocused (windows . appEndo <=< runQuery hook)

-- Keys
screenKeys :: [(String, X ())]
screenKeys =
    [ mask ++ [key] ~> screenWorkspace s >>= flip whenJust (windows . action)
    | (key, s) <- zip "123" [0..]
    , (mask, action) <- [("M-", W.view), ("M-S-", W.shift)]
    ]

windowKeys :: [(String, X ())]
windowKeys =
    -- Moving and resizing window
    [ (c ++ m ++ k, withFocused $ f (d x))
    | (d, k) <- zip
      [\a->(a, 0), \a->(0, a), \a->(-a, 0), \a->(0, -a)]
      ["<R>", "<D>", "<L>", "<U>"]
    , (f, m) <- zip
      [keysMoveWindow, \d -> keysResizeWindow d (0, 0)]
      ["M-", "M-S-"]
    , (c, x) <- zip
      ["", "C-"]
      [20, 2]
    ]
    ++
    -- Bring window to position
    [ ("M-" ++ key, moveToSide side)
    | (key, side) <- zip
      [ "<Home>"     , "S-<Page_Up>"  , "<Page_Up>"
      , "S-<Home>"   , "<Insert>"     , "S-<End>"
      , "<Page_Down>", "S-<Page_Down>", "<End>"
      ]
      [ NW, NC, NE
      , CW, C , CE
      , SW, SC, SE
      ]
    ]

mediaKeys :: [(String, X ())]
mediaKeys =
    [ ("<XF86KbdBrightnessUp>", spawn "kbdlight up")
    , ("<XF86KbdBrightnessDown>", spawn "kbdlight down")
    ]

-- Menus
myApps :: [([Char], X ())]
myApps =
    [ ("Browser",      raiseApp  "web" myBrowser)
    , ("Editor",       raiseApp' myEditor)
    , ("LibreOffice",  raiseApp  "doc" "libreoffice")
    , ("Themes",       spawn     "lxappearance")
    ]
  where
    raiseApp ws a = raiseNextMaybe (spawnWS ws a) (appName ~? a)
    raiseApp' a = raiseNextMaybe (spawn a) (appName ~? a)
    myRaiseTerm a d = raiseNextMaybe (spawnWS a (termApp a d)) (roleName ~? a)
    termApp a d = myTerm ++ " -r " ++ a ++ " -d " ++ d
    -- Named Workspace Navigation
    spawnWS ws a = addWorkspace ws >> spawn a

-- Warp mouse
bringMouse :: X ()
bringMouse = warpToWindow (9/10) (9/10)
