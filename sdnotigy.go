package main

import (
	"errors"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var ErrSdNotifyNoSocket = errors.New("No socket")

func Ready() error {
	return SdNotify("READY=1")
}

// Stopping sends STOPPING=1 to the systemd notify socket.
func Stopping() error {
	return SdNotify("STOPPING=1")
}

// Reloading sends RELOADING=1 to the systemd notify socket.
func Reloading() error {
	return SdNotify("RELOADING=1")
}

// Errno sends ERRNO=? to the systemd notify socket.
func Errno(errno int) error {
	return SdNotify(fmt.Sprintf("ERRNO=%d", errno))
}

// Status sends STATUS=? to the systemd notify socket.
func Status(status string) error {
	return SdNotify("STATUS=" + status)
}

// Watchdog sends WATCHDOG=1 to the systemd notify socket.
func Watchdog() error {
	return SdNotify("WATCHDOG=1")
}
func SdNotify(state string) error {
	name := os.Getenv("NOTIFY_SOCKET")
	if name == "" {
		return ErrSdNotifyNoSocket
	}

	conn, err := net.DialUnix("unixgram", nil, &net.UnixAddr{Name: name, Net: "unixgram"})
	if err != nil {
		return err
	}
	defer conn.Close()

	_, err = conn.Write([]byte(state))
	return err
}

func reload() {
	// Tells the service manager that the service is reloading its configuration.
	sdnotify.Reloading()

	log.Println("reloading...")
	time.Sleep(time.Second)
	log.Println("reloaded.")

	// The service must also send a "READY" notification when it completed reloading its configuration.
	sdnotify.Ready()
}

func main() {
	log.Println("starting...")
	time.Sleep(time.Second)
	log.Println("started.")

	// Tells the service manager that service startup is finished.
	sdnotify.Ready()

	go func() {
		tick := time.Tick(30 * time.Second)
		for {
			<-tick
			log.Println("watchdog reporting")
			sdnotify.Watchdog()
		}
	}()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGHUP, syscall.SIGINT, syscall.SIGTERM, syscall.SIGQUIT)
	for sig := range sigCh {
		if sig == syscall.SIGHUP {
			reload()
		} else {
			break
		}
	}

	// Tells the service manager that the service is beginning its shutdown.
	sdnotify.Stopping()

	log.Println("existing...")
	time.Sleep(time.Second)
}
