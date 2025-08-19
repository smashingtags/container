#!/bin/bash
####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
#####################################
# THIS DOCKER IS UNDER LICENSE      #
# NO CUSTOMIZING IS ALLOWED         #
# NO REBRANDING IS ALLOWED          #
# NO CODE MIRRORING IS ALLOWED      #
#####################################
# shellcheck disable=SC2086
# shellcheck disable=SC2046

export username=${username}
export token=${token}

folder=$(ls -1p ./ | grep '/$' | sed 's/\/$//' | sed '/docs/d' |sed '/images/d' | sed '/dead/d' )

for i in ${folder[@]}; do
   find ./$i -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | while read app; do
      if test -f "./.templates/$i/${app}.sh"; then
         echo "$i" "${app}" && sleep 1
         bash "./.templates/$i/${app}.sh" "$i" "${app}" "$username" "$token"
      fi
   done
done

folder=$(ls -1p ./ | grep '/$' | sed 's/\/$//' | sed '/docs/d' | sed '/dead/d' | sed '/images/d' )
for i in ${folder[@]}; do
   find ./$i -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | while read app; do
     ## hardcoded files inside
     if [ -d "./$i/${app}/root/" ] && [ ! -f "./$i/${app}/root/dockserver.txt" ]; then
        cp -r "./.templates/ci/dockserver.txt" "./$i/${app}/root/donate.txt"
     fi
     unset app
   done
done

unset token username

## add container.json
rm -f ./container.json ./wiki/docs/install/container.json
folder=$(ls -1p ./ | grep '/$' | sed 's/\/$//' | sed '/docs/d' | sed '/dead/d' | sed '/images/d' )
for i in ${folder[@]}; do
   find ./$i -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | while read app; do
      if test -f "./$i/${app}/release.json"; then
         ## FOR METRCIS
         echo "$i" "${app}" >> container.json && \
         cat "./$i/${app}/release.json" >> container.json && \
         echo "" >> container.json
         ## FOR DOCKERSERVER
         cat "./$i/${app}/release.json" >> ./wiki/docs/install/container.json
      fi
   done
done

#### END FILE ####

sleep 5
if [[ -n $(git status --porcelain) ]]; then
   git config --global user.name 'dockserver-bot[bot]'
   git config --global user.email '145536302+dockserver-bot[bot]@users.noreply.github.com'
   git add -A
   LOG=$(git status --porcelain | sed s/^...//)
   git commit -sam "[Auto Generation] Changes : $LOG" || exit 0
   git push --force
fi

exit 0
