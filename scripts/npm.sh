#!/usr/bin/env bash

echo "We're about to ask you to login to npm. Before you do this,"
echo "make sure you add yourself to the nodejitsu npm registry."
echo "(Ask another engineer if you need help with this.)"
npm login
npm cache clean
