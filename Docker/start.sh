#!/bin/bash

ls -alF .
ls -alF ./world

/usr/bin/java -Xms1024M -Xmx1536M -jar server.jar --nogui
