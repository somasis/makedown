# makedown

makedown is a build system for generating static websites.

## Requirements

### Building

- [GNU `make`](https://www.gnu.org/software/make/)
- [discount `markdown`](http://www.pell.portland.or.us/~orc/Code/discount/) (at least version 2.2.2)

### Checking

- [markdownlint](https://github.com/markdownlint/markdownlint)
- [devd](https://github.com/cortesi/devd)
- [linkchecker](https://wummel.github.io/linkchecker)

### Deploying

- [rsync](https://rsync.samba.org/)

### Live rebuilding

- [devd](https://github.com/cortesi/devd)
- [entr](http://entrproject.org/)

## Usage

1. Clone this repository to a directory named "makedown" in the root of your site.

        $ cd www.makedown.gov
        $ ls -CFl
        total 16K
        -rw-r--r-- 1 somasis somasis  71 Nov 11 05:44 index.md
        -rw-r--r-- 1 somasis somasis 421 Nov 11 05:51 page.template
        $ git clone https://gitlab.com/somasis/makedown
        Cloning into 'makedown'...
        remote: Counting objects: 11, done.
        remote: Compressing objects: 100% (11/11), done.
        remote: Total 11 (delta 0), reused 11 (delta 0), pack-reused 0
        Unpacking objects: 100% (11/11), done.

    If you are cloning it into an existing git repository, you'll want to have it be a submodule.

        $ git submodule add https://gitlab.com/somasis/makedown makedown
        Cloning into '/home/somasis/git/somasis.com/makedown'...
        remote: Counting objects: 60, done.
        remote: Compressing objects: 100% (40/40), done.
        remote: Total 60 (delta 31), reused 48 (delta 19), pack-reused 0
        Unpacking objects: 100% (60/60), done
        $ git status
        On branch master
        Changes to be committed:
          (use "git reset HEAD <file>..." to unstage)

                new file:   .gitmodules
                new file:   makedown

2.  Symbolically link the Makefile from the "makedown" directory to your root.

        $ ln -s ./makedown/Makefile Makefile

3.  Make a `makedown.conf` file, and a `page.template`. There's example files in this repository.

        $ ls -CFl
        total 16K
        -rw-r--r-- 1 somasis somasis  71 Nov 11 05:44 index.md
        drwxr-xr-x 1 somasis somasis 220 Nov 11 05:55 makedown/
        -rw-r--r-- 1 somasis somasis  18 Nov 11 05:51 makedown.conf
        lrwxrwxrwx 1 somasis somasis  17 Nov 11 05:44 Makefile -> makedown/Makefile
        -rw-r--r-- 1 somasis somasis 421 Nov 11 05:51 page.template

4. `make`, `make check`, `make deploy`.

5.  When `makedown` gets some new commits, you want to update.

    If you're using it as part of a git repository, you want to update the submodule.

        $ git submodule update --checkout --remote makedown
        Submodule path 'makedown': checked out '4a2078479578c51f031fcd2ea341ca05ecea6005'
        $ git add -v makedown
        add 'makedown'
        $ git commit -v
        [master f57c37e] Update makedown
         1 file changed, 1 insertion(+), 1 deletion(-)
        $ git push -v
        Pushing to git@gitlab.com:somasis/www.makedown.gov.git
        Counting objects: 2, done.
        Delta compression using up to 4 threads.
        Compressing objects: 100% (2/2), done.
        Writing objects: 100% (2/2), 254 bytes | 254.00 KiB/s, done.
        Total 2 (delta 1), reused 0 (delta 0)
        remote: Resolving deltas: 100% (1/1), completed with 1 local object.
        To gitlab.com:somasis/www.makedown.gov.git
           3839b44..f57c37e  master -> master
        updating local tracking ref 'refs/remotes/origin/master'

    (you can also just run `update-submodule.sh` from within the root repository to do this)

    If you're not, just pull the changes like any other git repository, with `git pull`.

## License

All files in this repository are licensed under the [0BSD license](http://landley.net/toybox/license.html).
