#!/bin/sh

cliphist list | wofi -S dmenu | cliphist decode | wl-copy
