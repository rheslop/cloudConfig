
# AWK split
# split(a,b,c);
#   where:
#      a = field
#      b = user-defined variable
#      c = delimeter

DOMAIN=vmnet.local
nova list | awk '/ACTIVE/ {split($12,x,"="); print x[2], $4.".'$DOMAIN'", $4}'
