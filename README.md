# php-ioncube-loader

Debian source package and helper script for building ionCube Loader
as a packaged PHP extension on [Launchpad.net](https://launchpad.net).

Builds **64 bit** only (but not too hard to modify if needed).

# Build instructions

Builds should be run on a Debian/Ubuntu box, and in the root of this repo.

Install build dependencies:

```
apt-get update && apt-get install -y devscripts build-essential
```

To download the latest binaries:

```
./build.sh download
```

Then run `./build.sh` (without arguments).

You'll be prompted for the ionCube Loader version, target series,
and maybe some other stuff.

This will update or write out configuration as appropriate.

To build and sign:

```
debuild -S -sa -k{YOUR KEY ID}
```

This builds the source package in the parent directory.

Push to Launchpad (and assuming you've no other builds in the parent dir):

```
cd ..
dput ppa:{YOUR PPA} *.changes
```

If you want to build the package locally first for testing, you can drop the
`-S` flag from `debuild`:

```
debuild -sa -k{YOUR KEY ID}
```
