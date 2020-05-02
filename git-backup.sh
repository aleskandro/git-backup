#!/bin/bash
#
# This script is thought for those guys who are sometimes referred to as paranoid :)
# Or those who lost a lot of not committed changes, secrets and other
# stuff in their repositories because of data loss also if they already had a good backup strategy.

# I wrote it for personal use. I use to sync my workstations with a remote server, which is in charge of
# exploiting the proper backup strategy and rotation scheme over different kinds of storage.
# However, "(r)syncing" a lot of git repositories, full of very small files, over the network,
# can have huge overheads (e.g., IO overhead due to the stat() system call).

# Git remotes can lack different data from your local repositories:
# secrets/env files, e.g., stashed or not staged files, local branches/commits.

# This script makes a backup of git repositories in a directory that must be included in an external backup tool with
# the proper strategy. It makes a backup only if the repository directory has been edited since the last one.
# It stores the backup in a tar.gz file that should be used later by some other guy like rsync.
# As simple as possible, but useful. It doesn't use any git command: there's no
# useful one to my knowledge that can help backuping the files described above
# while avoiding others that can be useless as `node_modules` or `build` files.

# Put it in your anacron/cron/systemd scripts or use it as a standalone

# git-backup.sh <git-repositories-containing-dir> <output-backup-dir>
#
# $1 is a folder containing git repositories
# $2 is the folder on which save backups
# if $1 matches the .env pattern it is considered as a file containing the two variables below

function fatal {
    echo $1 1>&2
    exit -1
}

if [[ "$1" =~ ".env" ]]; then
    . $HOME/.git-backup/$1 || exit -1
else
    test -n "$1" -a -n "$2" || fatal "git-backup | Usage: git-backup <git-repositories-containing-dir> <output-backup-dir>"
    test -d "$1" || fatal "git-backup | You must supply an exsistent directory path containing git repositories" 
    test -d "$2" || fatal "git-backup | You must supply an exsistent directory path for output backup storage"
    test -d "$1/.git" && fatal "git-backup | You provided a git repository. git-backup expects its parent dir"

    CONTAINER_DIR=$1
    OUTPUT_DIR=$2
fi

echo "<6>Working for backups from $CONTAINER_DIR (Output dir: $OUTPUT_DIR)"
ls -1d "$CONTAINER_DIR"/*/ | while read REPO
do
    echo "<6>--- Working on ${REPO}"
    REPO_NAME=$(basename "$REPO")
    BACKUP_FILE="$OUTPUT_DIR/$REPO_NAME.tar.gz"
    LAST_EDIT_TIME=$(find "$REPO" -printf "%T@\n" | sort | tail -1 | cut -f1 -d.)
    LAST_BCKP_TIME=$(stat -c "%Y" "$BACKUP_FILE" 2>/dev/null || echo "-1" | cut -f1 -d. )
    echo "<7>-|----- Repository last edit: $(date -d @$LAST_EDIT_TIME)"
    echo "<7>-|----- Repository last backup: $(date -d @$LAST_BCKP_TIME)"
    [ $LAST_BCKP_TIME -lt $LAST_EDIT_TIME ] && echo "<1>--- Creating new backup for $REPO_NAME" || echo "<5>--- Backup already updated"
    echo "<6>---------"
    [ $LAST_BCKP_TIME -lt $LAST_EDIT_TIME ] && tar -cjpf "$BACKUP_FILE" -C "$CONTAINER_DIR" "$REPO_NAME" &
done

wait


