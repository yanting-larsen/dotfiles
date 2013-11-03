module Config
     ( myFont
     , myXPConfig
     , myModMask
     , myTerminal
     , myFocusFollowsMouse
     , myClickJustFocuses
     , myBorderWidth
     , myWindowSpacing
     , myNormalBorderColor
     , myFocusedBorderColor
     , myDmenuOptions
     ) where

import XMonad
import XMonad.Prompt

myModMask = mod4Mask
myTerminal = "termite"

myFocusFollowsMouse = True
myClickJustFocuses = False

myBorderWidth :: Dimension
myBorderWidth = 1

myWindowSpacing :: Int
myWindowSpacing = 2

myFont = "Source Code Pro-12"

-- Colors
myNormalBorderColor  = colorWhite
myFocusedBorderColor = myFGColor
myFocusedFGColor     = colorGrey
myFocusedBGColor     = colorWhite

myFGColor   = "#2a2e6e"
myBGColor   = "#f5f5f5"

colorBlack  = "#151515"
colorRed    = "#c35532"
colorGreen  = "#7da028"
colorYellow = "#c19a48"
colorBlue   = "#008ebd"
colorPurple = "#9474b6"
colorCyan   = "#00adbe"
colorWhite  = "#b0b0b0"
colorGrey   = "#505050"

myDmenuOptions =  "-fn '" ++ myFont ++ "'"
              ++ " -nf '" ++ myFGColor ++ "'"
              ++ " -nb '" ++ myBGColor ++ "'"
              ++ " -sf '" ++ myFocusedFGColor ++ "'"
              ++ " -sb '" ++ myFocusedBGColor ++ "'"

myXPConfig =
    defaultXPConfig
    { font              = "xft:" ++ myFont
    , fgColor           = myFGColor
    , bgColor           = myBGColor
    , fgHLight          = myFocusedFGColor
    , bgHLight          = myFocusedBGColor
    , borderColor       = myNormalBorderColor
    , promptBorderWidth = 1
    , height            = 23
    , position          = Top
    , historySize       = 100
    , historyFilter     = deleteConsecutive
    }
