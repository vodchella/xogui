# XoGui

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/vodchella/xogui)](https://github.com/vodchella/xogui/releases)
[![CI](https://github.com/vodchella/xogui/actions/workflows/release.yml/badge.svg)](https://github.com/vodchella/xogui/actions/workflows/release.yml)
[![Zen C](https://img.shields.io/badge/Zen_C-0.4.4-blue)](https://github.com/zenc-lang/zenc)
[![raylib](https://img.shields.io/badge/raylib-5.5-blue)](https://github.com/raysan5/raylib)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**XoGui** is a Linux utility that provides a graphical user interface for playing tic-tac-toe (five in a row on a 10×10 board) with support for connecting different game engines via the [GTP](https://github.com/vodchella/xoml/blob/master/GTP.md) protocol.

It is distributed together with the [XOml](https://github.com/vodchella/xoml) engine.

The application is written in [Zen C](https://github.com/zenc-lang/zenc) and uses the [raylib](https://github.com/raysan5/raylib) graphics library.

## How to play

- Unpack the archive downloaded from the [Releases](https://github.com/vodchella/xogui/releases) section (or build it yourself from the source), and run `./xogui`.

## How to build

- Configure the environment variables as shown in the [example](.envrc.local.sample), specifying the actual paths to your `cc` compiler, `Zen C` installation, and `raylib` installation.
- Run `make` for build or `make run` for build and run.
