#!/bin/bash
filepath=$1

if [[ $filepath == *"ses"* ]]; then
    echo "The filepath contains the word 'ses'"
else
    echo "The filepath does not contain the word 'ses'"
fi
