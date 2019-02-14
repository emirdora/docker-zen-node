#!/bin/bash

set -xe

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback
USER_ID=${LOCAL_USER_ID:-9001}
GRP_ID=${LOCAL_GRP_ID:-9001}

groupadd -f -g $GRP_ID node
id -u node > /dev/null 2>&1 || useradd --shell /bin/bash -u $USER_ID -g $GRP_ID -o -c "" -m node

LOCAL_UID=$(id -u node)
LOCAL_GID=$(getent group node | cut -d ":" -f 3)

if [ ! "$USER_ID" == "$LOCAL_UID" ] || [ ! "$GRP_ID" == "$LOCAL_GID" ]; then
    echo "Warning: User with differing UID "$LOCAL_UID"/GID "$LOCAL_GID" already exists, most likely this container was started before with a different UID/GID. Re-create it to change UID/GID."
fi

echo "Starting with UID/GID : $LOCAL_UID/$LOCAL_GID"

# link the secure node tracker config, bail if not present
if [ -f "/mnt/zen/secnode/config.json" ]; then
  echo "Secure node config found OK - linking..."
  ln -s /mnt/zen/secnode /home/node/secnodetracker/config > /dev/null 2>&1 || true
else
  echo "No secure node config found. exiting"
  exit 1
fi

# Copy the zencash params
ln -s /mnt/zen/zcash-params /mnt/zcash-params
# cp -r /mnt/zen/zcash-params /mnt/zcash-params

# Fix the permissons
chown -R node:node /mnt/zen/secnode /mnt/zcash-params /home/node/secnodetracker
chmod g+rw /mnt/zen/secnode /home/node/secnodetracker
chmod -R 777 /home/node/secnodetracker/config

cd /home/node/secnodetracker
gosu node node app.js
