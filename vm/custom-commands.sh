#!/usr/bin/env bash

onos-run(){
  cd $ONOS_ROOT
  buck run onos-local -- clean debug
}

onos-lite-run(){
  cd $ONOS_ROOT
  ONOS_APPS=fwd,proxyarp,hostprovider,lldpprovider \
  onos-buck run onos-local -- clean debug
}

onos-cli(){
  cd $ONOS_ROOT
  onos localhost
}
