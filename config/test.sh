#!//bin/bash

cd /tmp
cat test.txt | msmtp --debug --read-recipients --host 127.0.0.1 --port 25 --from "noreply@${DOMAIN}" --user "noreply@${DOMAIN}"