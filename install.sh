#!/bin/sh

curl -sLo $HOME/.dcm.sh https://github.com/honsiorovskyi/dcm/raw/master/dcm.sh

if ! grep 'source $HOME/.dcm.sh' $HOME/.bashrc > /dev/null ; then
   echo 'source $HOME/.dcm.sh' >> $HOME/.bashrc
fi
