#!/bin/bash

DOX_PATH=$1
REPO_PATH=$2
REPO=$3

if [ -d $REPO_PATH ]; then
  rm -rf $REPO_PATH
fi

git clone $REPO $REPO_PATH
pushd $REPO_PATH
  git checkout gh-pages
popd

# Run doxygen
echo "Running doxygen."
doxygen ${DOX_PATH}

# Copy files.
mv ${REPO_PATH}/html/* ${REPO_PATH}
rm -rf ${REPO_PATH}/html

git config --global user.name $GIT_NAME
git config --global user.email $GIT_EMAIL
git config --global credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > ".git/credentials"

# Use Travis CI environment variables to upload result to our github account.
pushd $REPO_PATH
git add .
git commit -m "Travis auto publish site"
git push origin gh-pages

rm .git/credentials

