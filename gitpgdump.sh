#!/bin/sh
set -e

pgconfig="$1"
datafile="$2"
basedir="$(dirname "$datafile")"

if echo "$pgconfig"|grep -qE '^(postgresql|postgres):'; then
	:
else
	echo "Invalid pgconfig: $pgconfig" >&2
	exit 2
fi

if test -d "$basedir"; then
	:
else
	echo "No parent directory at $basedir" >&2
	exit 2
fi

if test -d "$basedir/.git"; then
	:
else
	echo "No git directory at $basedir/.git" >&2
	exit 2
fi

cd "$basedir"

if test -f "$datafile".sql; then
	start="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
	pg_dump "$pgconfig" -Z 0 -x -O -f "$datafile".sql.new
	end="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
	if cmp -s "$datafile".sql.new "$datafile".sql; then
		rm -f "$datafile".sql.new
	else
		mv -f "$datafile".sql "$datafile".sql.old
		mv -f "$datafile".sql.new "$datafile".sql
		rm -f "$datafile".sql.old
	fi
else
	start="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
	pg_dump "$pgconfig" -Z 0 -x -O -f "$datafile".sql
	end="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
	git add "$datafile".sql
fi

if git diff|wc -c|grep -q '^0$'; then
	echo 'build-dump.sh: Nothing changed. Ignoring commit.' >&2
	exit 1
else
	if git commit -q -a -m "New backup from $start"; then
		exit 0
	else
		echo 'build-dump.sh: Backup commit failed.' >&2
		exit 1
	fi
fi

