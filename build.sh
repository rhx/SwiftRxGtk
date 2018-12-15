#!/bin/sh
#
# Wrapper around `swift build' that uses pkg-config in config.sh
# to determine compiler and linker flags
#
. ./config.sh
export PACKAGES=.build/checkouts
[ -e $PACKAGES ] || export PACKAGES=Packages
gtk=`echo $PACKAGES/*Gtk*/Sources/Gtk/Gtk-3.0.swift`
[ -e $gtk ] || ./generate-wrapper.sh
exec swift build $CCFLAGS $LINKFLAGS "$@"
