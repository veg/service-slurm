#!/usr/bin/env bash

# Script to handle conditional startup of REST API or CLI interface for Slurm

# Start Munge authentication service
gosu munge /usr/sbin/munged

# Wait for slurmctld to be available
until 2>/dev/null >/dev/tcp/slurmctld/6817
do
    echo "-- slurmctld is not available. Sleeping ..."
    sleep 2
done
echo "-- slurmctld is now active ..."

# Setup Slurm account for REST API (needed for both modes)
sacctmgr -i add account rest 
sacctmgr -i add user rest account=rest

# Check interface mode and start appropriate services
if [ "${SLURM_INTERFACE}" = "rest" ] || [ -z "${SLURM_INTERFACE}" ]; then
    echo "-- Starting Slurm in REST API mode"

    # Start slurmrestd
    SLURM_JWT=daemon SLURMRESTD_DEBUG=5 exec gosu rest /usr/sbin/slurmrestd 0.0.0.0:9200
else
    echo "-- Starting Slurm in CLI mode"
    
    # Start SSH server for CLI access
    if [ -f "/etc/ssh/sshd_config" ]; then
        echo "-- Starting SSH server"
        /usr/share/bin/setup-ssh.sh
    else
        echo "-- WARNING: SSH server not installed. CLI mode will be limited to container access only."
    fi
    
    # Start slurmd
    exec /usr/sbin/slurmd -Dvvv
fi
