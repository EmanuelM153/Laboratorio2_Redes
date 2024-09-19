{ pkgs, fetchurl, fetchgit, fetchhg, lib }:

self: python3Packages: {
  "cppyy" = python3Packages.buildPythonPackage rec {
    pname = "cppyy";
    version = "3.1.2";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-eTfRhK8C4VEPRNVlXgvMPGp4iO9bPwbD3Qm6k9HB8Zs=";
    };
    dontUseCmakeBuildDir = true;
  };

  "cppyy-cling" = python3Packages.buildPythonPackage rec {
    pname = "cppyy-cling";
    version = "6.30.0";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-XZ4FUaTLYY6zOSABs9wsYpTwIlfwL81NhomZugT5KvE=";
    };
    dontUseCmakeBuildDir = true;
    doCheck = false;
    nativeBuildInputs = [ pkgs.cmake ];
  };
}
