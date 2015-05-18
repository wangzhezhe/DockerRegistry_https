#!/bin/bash
input=$1
output=`expect <<EXP
log_user 0
puts $input
EXP
`
echo $output
