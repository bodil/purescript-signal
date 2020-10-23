{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "signal"
, license = "Apache-2.0"
, repository = "https://github.com/bodil/purescript-signal"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "foldable-traversable"
  , "functions"
  , "js-timers"
  , "lists"
  , "maybe"
  , "prelude"
  , "psci-support"
  , "refs"
  , "test-unit"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
