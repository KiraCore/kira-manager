package main

import (
	"flag"
	"log"

	"github.com/BurntSushi/toml"
	"github.com/mrlutik/kira-manager/internal/app/restserver"
)

var (
	configPath string
)

func init() {
	flag.StringVar(&configPath, "config-path", "configs/restserver.toml", "path to config file")
}
func main() {
	flag.Parse()

	config := restserver.NewConfig()
	_, err := toml.DecodeFile(configPath, config)
	if err != nil {
		log.Fatal(err)
	}
	s := restserver.New(config)
	if err := s.Start(); err != nil {
		log.Fatal(err)
	}
}
