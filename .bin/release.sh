#! /bin/bash
# A modification of Dean Clatworthy's deploy script as found here: https://github.com/deanc/wordpress-plugin-git-svn via
# Brent Shepherd's deploy script at https://github.com/thenbrent/multisite-user-management/blob/master/deploy.sh .
# The difference is that this script lives in the plugin's git repo & doesn't require an existing SVN repo.

# main config
PLUGINSLUG="insert-headers-and-footers"
CURRENTDIR=`pwd`
MAINFILE="ihaf.php" # this should be the name of your main php file in the wordpress plugin
SKIP_NPM=false
SKIP_COMPOSER=true

# git config
GITPATH="$CURRENTDIR/" # this file should be in the base of your git repository

# svn config
TMPPATH="$GITPATH/.tmp-svn" # path to a temp SVN repo. No trailing slash required and don't add trunk.
SVNURL="http://plugins.svn.wordpress.org/$PLUGINSLUG/" # Remote SVN repo on wordpress.org, with trailing slash
SVNUSER="peterwilsoncc" # your svn username

# Let's begin...
echo ".........................................."
echo
echo "Preparing to deploy wordpress plugin"
echo
echo ".........................................."
echo

# Check if subversion is installed before getting all worked up
if ! which svn >/dev/null; then
	echo "You'll need to install subversion before proceeding. Exiting....";
	exit 1;
fi

if [ ! -z "$(git status --porcelain)" ]; then
	echo "Git is dirty."
	# exit
fi

# Check version in readme.txt is the same as plugin file after translating both to unix line breaks to work around grep's failure to identify mac line breaks
NEWVERSION1=`grep "^Stable tag:" $GITPATH/readme.txt | awk -F' ' '{print $NF}'`
echo "readme.txt version: $NEWVERSION1"
NEWVERSION2=`grep "^[ \t\*]*Version[ \t]*:[ \t]*" $MAINFILE | awk -F' ' '{print $NF}'`
echo "$MAINFILE version: $NEWVERSION2"

if [ "$NEWVERSION1" != "$NEWVERSION2" ]; then echo "Version in readme.txt & $MAINFILE don't match. Exiting...."; exit 1; fi

mkdir -p "$TMPPATH/svn-checkout";

echo
echo "Creating local copy of SVN repo ..."
svn co $SVNURL "$TMPPATH/svn-checkout"

echo
echo "Exporting archive of HEAD ..."
git archive --format zip -o "$TMPPATH/archive.zip" HEAD

echo
echo "Replacing SVN trunk with archive ..."
rm -rf "$TMPPATH/svn-checkout/trunk"
unzip "$TMPPATH/archive.zip" -d "$TMPPATH/svn-checkout/trunk"

cd "$TMPPATH/svn-checkout/trunk"

if [[ -f composer.json ]]; then
	if [[ false = $SKIP_COMPOSER ]]; then
		if ! which composer >/dev/null; then
			echo "You'll need to install composer before proceeding. Exiting....";
			exit 1;
		fi

		echo "Installing composer dependencies..."
		composer install --no-dev -a
	fi
	rm composer.{json,lock}
fi

if [[ -f package.json ]]; then
	if [[ false = $SKIP_NPM ]]; then
		if ! which npm >/dev/null; then
			echo "You'll need to install NPM before proceeding. Exiting....";
			exit 1;
		fi

		echo "Installing node dependencies..."
		npm install --production
	fi
	rm package{.json,-lock.json}
fi

echo
echo "Removing dot files from root directory."
rm .*

echo "Removing xml files from root directory."
rm *.xml
rm *.xml.dist

echo "Removing webpack and remaining config files from root directory."
rm webpack.config.js postcss.config.js


echo
echo "CURRENT SVN STATUS"
svn status
