package pkghandler

import (
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
)

func pkgsFetch() (pkgs *[]uint8, err error) {
	cmd := exec.Command("dpkg-query", "--showformat=${Package} ${Version}\n", "--show")
	if out, err := cmd.StdoutPipe(); err != nil {
		return nil, fmt.Errorf("failed to connect to stdout: %v", err)
	} else {
		if err := cmd.Start(); err != nil {
			return nil, fmt.Errorf("failed to execute command: %v", err)
		} else {
			//fmt.Printf("command finished without errors. exit code: %v", err)
			pkgs, _ := io.ReadAll(out)
			return &pkgs, nil
		}
	}
}

func pkgSet(pkgs *[]uint8) (set map[string]string) {
	//testing: map vs struct
	set = make(map[string]string)
	for _, d := range strings.Split(string(*pkgs), "\n") {
		if d != "" {
			split := strings.Split(d, " ")
			set[split[0]] = split[1]
		}
	}
	return set
}

func pkgUpdate(pkg string, ver string) {
	/*testing*/
	s := []string{pkg, ver}
	cmd := exec.Command("echo", "\"apt-get install", strings.Join(s, "="), "-y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages\"")
	out, _ := cmd.StdoutPipe()
	cmd.Start()
	ctx, _ := io.ReadAll(out)
	fmt.Printf("%s", ctx)
}

func rebootCheck() bool {
	if _, err := os.Stat("/var/run/reboot-required"); err == nil {
		fmt.Printf("file exist, reboot required\n")
		return true
	} else if errors.Is(err, os.ErrNotExist) {
		fmt.Printf("file does not exist, reboot not required\n")
		return false
	} else {
		fmt.Printf("wave function collapse\n")
		return false
	}
}

func test() {
	rebootCheck()
	pkgUpdate("libblockdev-crypto2", "2.23-2ubuntu3")
	if pkgs, err := pkgsFetch(); err != nil {
		fmt.Printf("failed to fetch packages: %v", err)
	} else {
		set := pkgSet(pkgs)
		fmt.Printf("%v\n", set["libblockdev-crypto2"])
	}
}
