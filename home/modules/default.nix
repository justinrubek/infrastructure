{
  flake.homeModules = {
    "profiles" = ./profiles;
    "profiles/base" = ./profiles/base;
    "profiles/development" = ./profiles/development;
    "misc/home" = ./misc/home; # always runs for every configuration
  };
}
