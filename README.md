# homebrew-dtn7

This is a macOS [homebrew](https://brew.sh) tap for dtn7. Currently only dtn7-go is supported.

## Install

As usual taps hosted at GitHub can be installed directly or through checking out the tap:

```bash
# Option 1: install directly
$ brew install dtn7/dtn7/dtn7-go
# Option 2: checkout tap and install 
$ brew tap dtn7/dtn7 https://github.com/dtn7/homebrew-dtn7
$ brew install dtn7-go
```

## dtn7-go

The dtn7-go formula installs both dtnd and dtn-tool, for compatibility reasons both are named according the formula: `dtn7-god`, `dtn7-go-tool`. 

A default configuration file [inspired by the example](https://github.com/dtn7/dtn7-go/blob/master/cmd/dtnd/configuration.toml) is created at `/usr/local/etc/dtn7-go/configuration.toml`.

dtn7-d's store, as well as the runtime logs will appear in `/usr/local/var/dtn7-go/`. 

A brew services configuration is created, which allows dtn7-god to be run at login. The service can be activated using `brew services start dtn7/dtn7/dtn7-go`.
