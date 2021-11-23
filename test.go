package main

import (
	"bytes"
	"io"
	"os"
	"os/exec"
)

func InstallDocker() (err error) {
	var buff bytes.Buffer
	req := exec.Command("apt-get", "install", "apt-transport-https", "ca-certificates", "curl", "software-properties-common", "-y")
	err = req.Run()

	gpg := exec.Command("curl", "-fsSL", "https://download.docker.com/linux/ubuntu/gpg")
	add_gpg := exec.Command("apt-key", "add", "-")
	r, w := io.Pipe()
	gpg.Stdout = w
	add_gpg.Stdin = r
	add_gpg.Stdout = &buff
	gpg.Start()
	add_gpg.Start()
	gpg.Wait()
	w.Close()
	r.Close()
	add_gpg.Wait()
	io.Copy(os.Stdout, &buff)
	return err
}
func main() {
	InstallDocker()
}
