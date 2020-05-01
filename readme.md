# Git-Backup

   This script is thought for those guys who are sometimes referred to as paranoid :)
   Or those who lost a lot of not committed changes, secrets and other
   stuff in their repositories because of data loss also if they already had a good backup strategy.

   I wrote it for personal use. I use to sync my workstations with a remote server, which is in charge of
   exploiting the proper backup strategy and rotation scheme over different kinds of storage.
   However, "(r)syncing" a lot of git repositories, full of very small files, over the network,
   can have huge overheads (e.g., IO overhead due to the stat() system call).

   Git remotes can lack different data from your local repositories:
   secrets/env files, e.g., stashed or not staged files, local branches/commits.

   This script makes a backup of git repositories in a directory that must be included in an external backup tool with
   the proper strategy. It makes a backup only if the repository directory has been edited since the last one.
   It stores the backup in a tar.gz file that should be used later by some other guy like rsync.
   As simple as possible, but useful. It doesn't use any git command: there's no
   useful one to my knowledge that can help backuping the files described above
   while avoiding others that can be useless as `node_modules` or `build` files.

   Put it in your anacron/cron/systemd scripts or use it as a standalone

   #### Usage:

   ```bash
    git-backup.sh <git-repositories-containing-dir> <output-backup-dir>
    git-backup.sh <configfilename> # The name of .env file stored in $HOME/.git-backup
   ```


## Installing Git-Backup with systemd timers

    ```bash
        ln -s /path/to/repo/git-backup.sh /usr/local/bin/
        mkdir -p ~/.config/systemd/user ~/.git-backup
        cp dot.git-backup/example.env ~/.git-backup/myexample.env # Choose the name of your configuation (here "myexample")
        vim ~/.git-backup/myexample.env # Modify the env example file at your like
        ln -s /phat/to/repo/git-backup@.service ~/.config/systemd/user
        ln -s /phat/to/repo/git-backup@.timer ~/.config/systemd/user
        systemctl enable --user git-backup@myexample.timer # Enable timer for each of the configurations (here "myexample")
        systemctl start --user git-backup@myexample.timer # Start the timer to avoid reboot
    ```

