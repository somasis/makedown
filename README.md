# makedown

makedown is a build system for generating static websites.

## Requirements

### Building

- [GNU `make`](https://www.gnu.org/software/make/)
- [discount `markdown`](http://www.pell.portland.or.us/~orc/Code/discount/)

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

1. Clone this repository to a directory named "makedown" in the root of your site

```text
$ cd www.makedown.gov
$ ls -CFl
total 16K
-rw-r--r-- 1 somasis somasis  71 Nov 11 05:44 index.md
-rw-r--r-- 1 somasis somasis 421 Nov 11 05:51 page.template
$ git clone https://github.com/somasis/makedown
Cloning into 'makedown'...
remote: Counting objects: 11, done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 11 (delta 0), reused 11 (delta 0), pack-reused 0
Unpacking objects: 100% (11/11), done.
```

2. Symbolically link the Makefile from the "makedown" directory to your root.

```text
$ ln -s ./makedown/Makefile Makefile
```

3. Make a `makedown.conf` file, and a `page.template`. There's example files in this repository.

```
$ ls -CFl
total 16K
-rw-r--r-- 1 somasis somasis  71 Nov 11 05:44 index.md
drwxr-xr-x 1 somasis somasis 220 Nov 11 05:55 makedown/
-rw-r--r-- 1 somasis somasis  18 Nov 11 05:51 makedown.conf
lrwxrwxrwx 1 somasis somasis  17 Nov 11 05:44 Makefile -> makedown/Makefile
-rw-r--r-- 1 somasis somasis 421 Nov 11 05:51 page.template
```

4. `make`, `make check`, `make deploy`.

## License

All files in this repository are licensed under the [0BSD license](http://landley.net/toybox/license.html).
