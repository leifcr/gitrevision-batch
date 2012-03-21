# Git version script for Windows

You need to have 'sed' and 'git' installed in order for this script to work.

Your git tags must be in format v1.0.123
1 is major version
0 is minor version
123 is revision number

## Usage 
<pre>
  gitversion.bat git_repo_folder input_file output_file
</pre>
## Usage example:

<pre>
  gitversion.bat c:\path\to\my\git\repository file_with_version_codes.h version.h
</pre>

Parameters changed in input file:
* $MAJOR_VERSION$ - the major version number
* $MINOR_VERSION$ - the minor version number
* $REVISION$ - the revision number
* $COMMITS_SINCE_TAG$ - number of commits since last tag
* $GIT_TAG_HASH$ - git hash for the tag
* $GIT_HASH$ - the current git hash  will be same as GIT_HASH if the current tag is checked out)

Copyright (c) 2012 Leif Ringstad, released under the MIT license
