package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
)

const (
	KM_VERSION string = "KM2.0.0"
)

func CheckCmd(cmd_name string) bool {
	if _, err := exec.LookPath(cmd_name); err != nil {

		return false
	}
	return true
}
func InstallDocker() (err error) {
	var buff bytes.Buffer
	req := exec.Command("apt-get", "install", "apt-transport-https", "ca-certificates", "curl", "software-properties-common", "-y")
	err = req.Run()

	gpg := exec.Command("curl", "-fsSL", "https://download.docker.com/linux/ubuntu/gpg")
	add_gpg := exec.Command("apt-key", "add", "-")
	r, w: = io.Pipe()
	gpg.Stdout = w
	add_gpg.Stdin = r
	add_gpg = &buff
	gpg.Start()
	add_gpg.Start()
	gpg.Wait()
	w.Close()
	add_gpg.Wait()
	io.Copy(os.Stdout, &buff)
}

func SetupNode(name string) (err error) {
	if CheckCmd("docker") != true {
		err := InstallDocker()
	}
}

func Menu() (choice string) {
	var stderr bytes.Buffer
	menu := exec.Command("whiptail", "--title", KM_VERSION, "--menu", "Please, choose the node you want to install", "16", "60", "2",
		"1.", "Setup validator node",
		"2.", "Setup sentry node",
	)

	menu.Stdout = os.Stdout // redirect stdout
	menu.Stderr = &stderr   // whiptail writes choice in stderr

	err := menu.Run()
	if err != nil {
		log.Printf("Failed to start whiptail menu %s. ", err)
	}
	errStr := string(stderr.Bytes())
	fmt.Printf("in: %s\n", errStr)
	defer menu.Wait()
	return errStr

}
func main() {
	os.Setenv("TERM", "ansi")
	switch input := Menu(); input {
	case "1.":
		fmt.Println("installing validator")
	case "2.":
		fmt.Println("inslling sentry")
	}

}
