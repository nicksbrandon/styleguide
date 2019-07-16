## Lint for BASH

It is important to ensure that BASH scripts abide by appropriate standards.

This can be managed by installing two packages:

 - ShellCheck:  The tool will check syntax of script and report any cases where good coding practice is not met.
    - Note:  It does *not* modify the script and does not check line lengths, line endings or code indentation
 - Shfmt:  This tool will ensure indentation, line endings are correctly set and multiple multiple consecutive blank lines are removed.
 
Neither of these packages enforce max line lengths.  This is managed by a shell script that will report, but not correct, line lengths that exceed 100 characters.

It is important to note that although ShellCheck is an extremely powerful and useful tool, it will occasionally make suggestions that will not run correctly and thus need to be ignored.
When this happens a short note in the script to explain why the recommendation was not followed is extremely useful.

To wrap up these checks there is a script called `format_bash.sh`.  It takes one parameter which is the script name.  It will run the three sets of tests as described.


## Install ShellCheck

```
sudo apt install shellcheck
``` 

 Useful link:
 
 https://www.cyberciti.biz/programming/improve-your-bashsh-shell-script-with-shellcheck-lint-script-analysis-tool/
 
 


## Install shfmt

Some instructions can be found here :

https://github.com/mvdan/sh

To install shfmt you first need to install Go.

You will need at least version 1.11 of GO.

I found if you have a lower version it is better to uninstall then reinstall rather than doing the upgrade. 

To uninstall:

```
sudo apt-get remove golang-go
sudo apt-get remove --auto-remove golang-go
```

Now download the installation from :

https://golang.org/dl/

I use the Linux x86-64 version.  `go1.12.7.linux-amd64.tar.gz`.

Now unpack it.

```
tar -C /usr/local -xzf go1.12.7.linux-amd64.tar.gz
```

Now add to the PATH

to check all has install as you expect run the following command:

```
go version
```

Now install shfmt.

```
cd $(mktemp -d); go mod init tmp; go get mvdan.cc/sh/cmd/shfmt
```

## Install format_bash.sh

The script is ran with a single parameter: the script to check.

```
sh format_bash.sh my_script_to_check.sh
```










