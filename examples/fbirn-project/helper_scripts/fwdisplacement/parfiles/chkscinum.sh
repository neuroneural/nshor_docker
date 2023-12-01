#!/bin/bash

VAR=$1
echo $VAR

if [[ $VAR =~ ^[0-9]+$ ]];then
      echo "Input contains number"
   else
	echo "Input contains non numerical value"
	if [[ "$VAR" == *"e"* ]]; then
		echo "lower case scinum"
	elif [[ "$VAR" == *"E"* ]]; then
		echo "upper case scinum"
	fi
fi
