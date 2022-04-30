let conf = ./spago.dhall

in conf // {
  sources = conf.sources # [ "test/**/*.purs" ],
  dependencies = 
   conf.dependencies 
   # [ "spec" 
     , "console"
     , "control"
     , "datetime"
     , "exceptions"
     , "functions"
     , "integers"
     , "lists"
     , "refs"
     , "tuples"
     ]
}