#!/bin/sh
set -e

pgconfig="$1"
datafile="$2"
basedir="$(dirname "$datafile")"

if echo "$pgconfig"|grep -qE '^(postgresql|postgres):'; then
	:
else
	echo "Invalid --pg: $pgconfig" >&2
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
	touch "$datafile".sql.new
	chmod 600 "$datafile".sql.new
	pg_dump "$pgconfig" -Z 0 -x -O -f "$datafile".sql.new
	end="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
	if cmp -s "$datafile".sql.new "$datafile".sql; then
		if test "xGITPGDUMP_DEBUG" != x; then
			echo "gipgdump.sh: debug: No changes." >&2
		fi

		rm -f "$datafile".sql.new
	else
		if test "xGITPGDUMP_DEBUG" != x; then
			echo "gipgdump.sh: debug: There was changes." >&2
		fi

		mv -f "$datafile".sql "$datafile".sql.old
		mv -f "$datafile".sql.new "$datafile".sql
		rm -f "$datafile".sql.old
	fi
else
	if test "xGITPGDUMP_DEBUG" != x; then
		echo "gipgdump.sh: debug: Backup was missing, creating initial backup." >&2
	fi

	start="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
	touch "$datafile".sql
	chmod 600 "$datafile".sql
	pg_dump "$pgconfig" -Z 0 -x -O -f "$datafile".sql
	end="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
	git add "$datafile".sql
fi

if git diff|wc -c|grep -q '^0$'; then
	echo 'gitpgdump: No real changed. Ignoring commit.' >&2
	exit 0
else
	if test "xGITPGDUMP_DEBUG" != x; then
		echo "gipgdump.sh: debug: Committing since there was changes: ""$(git diff)" >&2
	fi

	if git commit -q -a -m "New backup from $start"; then
		if test "xGITPGDUMP_DEBUG" != x; then
			echo "gipgdump.sh: debug: Backup successfully done." >&2
		fi
		exit 0
	else
		echo 'gitpgdump: Backup commit failed.' >&2
		exit 1
	fi
fi

