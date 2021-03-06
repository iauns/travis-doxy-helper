#!/bin/bash

DOX_PATH=$1
REPO_PATH=$2
REPO=$3

# Only run doxygen if we are using gcc.
if [[ "$CXX" == "g++"* ]]; then
  echo "GCC detected. Running doxygen. CXX: $CXX"
else
  echo "Clang detected. Not running doxygen."
  echo "CXX: $CXX"
  exit 0
fi

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

# Use Travis CI environment variables to upload result to our github account.
pushd $REPO_PATH
  git config user.name $GIT_NAME
  git config user.email $GIT_EMAIL
  git config credential.helper "store --file=.git/credentials"
  echo "https://iauns:${GH_TOKEN}@github.com" > ".git/credentials"

  # Ensure we touch .nojekyll. Otherwise files that begin with '_' will be
  # ignored by github's gh-pages.
  touch .nojekyll

  git add .
  git commit -m "Travis auto publish site"
  git push origin gh-pages

  rm .git/credentials
popd

