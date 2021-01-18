# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased

### Changed

- Fix: Changed domain of Google API endpoint for signBlob from `content-iamcredentials.googleapis.com` to `iamcredentials.googleapis.com`
- Chores: Bump httpoison from 1.7.0 to 1.8.0
- Chores: Bump excoveralls from 0.13.3 to 0.13.4
- Chores: Bump credo from 1.5.3 to 1.5.4

## [0.4.2] - 2020-10-20

### Added
- Github Workflows and Dependabot configuration

### Changed
- URL encode the signature in V2 algorithm (#7, #16)
- Misc. Markdown format and module config changes for HTML doc generation

## [0.4.1] - 2020-10-20

### Added
- this changelog ;)

### Changed
- Better README.md and add README.md to hex docs
- Changes regarding support for Elixir 1.11

## [0.4.0] - 2020-05-04

### Added
- Support for signing strings via IAM REST API ([#6](https://github.com/alexandrubagu/gcs_signed_url/pull/6)]

### Removed

### Changed
