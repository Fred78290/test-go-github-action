package main

import (
	"os"

	flags "github.com/jessevdk/go-flags"
	klog "k8s.io/klog/v2"
)

var phVersion = "v0.0.0-unset"
var phBuildDate = ""

// Options arguments
type Options struct {
}

func mainExitCode(arguments []string) int {
	args := Options{}

	_, err := flags.ParseArgs(&args, arguments)

	if err != nil {
		if err.(*flags.Error).Type == flags.ErrHelp {
			return 0
		}

		klog.Errorf("Failed %v", err)

		return -1
	}

	klog.Infof("Version:%s, build: %s", phVersion, phBuildDate)

	return 0
}

func main() {
	arguments := os.Args[1:]

	os.Exit(mainExitCode(arguments))
}
