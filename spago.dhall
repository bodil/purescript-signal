{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "signal"
, license = "Apache-2.0"
, repository = "https://github.com/bodil/purescript-signal"
, dependencies =
  [ "aff"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "maybe"
  , "prelude"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
