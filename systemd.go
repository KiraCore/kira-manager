package main

import "fmt"

type Unit struct {
	Description  string
	After        string
	CPUquota     uint8
	IOWeight     uint8
	SWAPsize     int
	Type         string
	User         string
	WorkingDir   string
	ExecPath     string
	Restart      string
	RestartTimer uint8
	NOFILE       int
	Wanted       string
}

const UNIT_TEMPL = `
[Unit]
Description={{.Description}}
After={{.After}}
[Service]
CPUQuota={{.CPUquota}}%
IOWeight={{.IOweight}}
MemorySwapMax={{.SWAPsize}}
Type={{.Type}}
User={{.User}}
WorkingDirectory={{.WorkingDir}}
ExecStart={{.ExecPath}}
Restart={{.Restart}}
RestartSec={{.RestartTimer}}
LimitNOFILE={{.NOFILE}}
[Install]
WantedBy={{.Wanted}}
{{end}}
`

func main() {
	fmt.Println("unit")
}
