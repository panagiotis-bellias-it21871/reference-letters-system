#/bin/bash
echo "USAGE: ./git.sh <commit-message>"
echo $1

cd ansible-reference-letter-code
git add .
git commit -m "$1"
git push

cd ../reference-letters-fastapi-server
git add .
git commit -m "$1"
git push

cd ../reference-letters-vuejs-client
git add .
git commit -m "$1"
git push

cd ..
git add .
git commit -m "$1"
git push