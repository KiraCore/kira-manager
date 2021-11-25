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

/*
type Menu struct{
}
type Init struct {
	*Menu
}
*/
func CheckCmd(cmd_name string) bool {
	if _, err := exec.LookPath(cmd_name); err != nil {
		return false
	}
	return true
}
func InstallDocker() (err error) {
	//Probalby will need to break for smaller peaces
	//Idea: args with exec.Command add to struct. Wrap execution of exec.Command to add counter. Counter can be used as a gauge in whiptail.
	var buff bytes.Buffer

	upd := exec.Command("apt-get", "update", "-y")
	if err = upd.Run(); err != nil {
		log.Fatalln("Failed to update")
	}

	req := exec.Command("apt-get", "install", "apt-transport-https", "ca-certificates", "curl", "software-properties-common", "-y")
	if err = req.Run(); err != nil {
		log.Fatalln("Failed to install required dependencies")
	}
	//Pipe for adding GPG
	gpg := exec.Command("curl", "-fsSL", "https://download.docker.com/linux/ubuntu/gpg")
	add_gpg := exec.Command("apt-key", "add", "-")
	r, w := io.Pipe()
	gpg.Stdout, add_gpg.Stdin = w, r
	add_gpg.Stdout = &buff
	gpg.Start()
	add_gpg.Start()
	gpg.Wait()
	w.Close()
	add_gpg.Wait()
	io.Copy(os.Stdout, &buff)

	add_repo := exec.Command("add-apt-repository", "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable")
	if err = add_repo.Run(); err != nil {
		log.Fatalln("Failed to add docker repositoriy ", err)
	}
	//upd = upd.Run()
	if err = upd.Run(); err != nil {
		log.Fatalln("Failed to update 2nd")
	}

	apt_cache := exec.Command("apt-cache", "policy", "docker-ce", "-y")
	if err = apt_cache.Run(); err != nil {
		log.Fatalln("Failed to update apt-cahe")
	}

	install_docker := exec.Command("apt-get", "install", "docker-ce", "-y")
	if err = install_docker.Run(); err != nil {
		log.Fatalln("Failed to update docker-ce")
	}
	return err
}

//IDEA: Should try to use named pypes to wrap whiptail
/*

func SetupNode(name string) (err error) {
	if CheckCmd("docker") != true {
		err := InstallDocker()
	}
}
*/
func Menu() (choice string) {
	var stderr bytes.Buffer
	menu := exec.Command("whiptail", "--title", KM_VERSION, "--menu", "Please, choose the node you want to install", "16", "60", "2",
		"1.", "Validator node",
		"2.", "Sentry node",
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
		if err := InstallDocker(); err != nil {
			log.Fatalln("Failed to install docker")
		}
	case "2.":
		fmt.Println("inslling sentry")
	}

}
