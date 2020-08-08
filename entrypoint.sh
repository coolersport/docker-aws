#!/bin/bash

if [[ -f "$BASH_SCRIPT" ]]; then
	. $BASH_SCRIPT
else
	exec "$@"
fi
