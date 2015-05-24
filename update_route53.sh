# ----------------------------------------------------------- #
# - This little script is meant to be run at start up and
# - is designed to push an update to our Route 53 zone to
# - update the CNAME for our the server hostname to the
# - amazon public ec2 hostname
# - This script relies on cli53, so make sure it is installed
# - Author: dplessas, 08052013
# ----------------------------------------------------------- #

. /etc/profile

if [[ $(which python-pip) != 0 ]]; then
    echo python-pip package does not exist, install it now.
    sudo yum install python-pip -y
fi

# - check for cli53 - #
if [[ $(which cli53 > /dev/null) != 0 ]]; then
    echo 'cli53 does not exist! Installing it now!'
    sudo python-pip install cli53
fi

# - vars - #
AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2
ZONE=$3
TTL=60
USR_DATA=/tmp/userdata.out

META_URL=http://169.254.169.254/latest
# - check for root privs - #
if [ "`id -u`" -ne 0 ]; then
    echo "Back off! You are dealing with things man was never meant to know!"
    exit 1
fi

# - poll user data - #
HOST_ID=$(curl -f -s http://169.254.169.254/latest/user-data 2>&1 | perl -nle 'print $1 if /HOSTNAME=(\S+)/')
echo HOST ID is $HOST_ID

# - If we got nothing from the user data, set the dns cname to this hostname on the instance and hope it is correct - #
if [ -z ${HOST_ID} ]; then
    HOST_ID="$(hostname -s)"
fi

# - export our non prived IAM user keys - #
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# - Get the ec2 public-dns name to CNAME to - #
PUBLIC_HOSTNAME=$(curl -f -s $META_URL/meta-data/public-hostname)
echo public hostname is $PUBLIC_HOSTNAME

# - Now Create a new CNAME record on Route 53, replacing the old entry if nessesary - #
# echo cli53 rrcreate $ZONE $HOST_ID CNAME $PUBLIC_HOSTNAME --replace --ttl $TTL

cli53 rrcreate "${ZONE}" "${HOST_ID}" CNAME "${PUBLIC_HOSTNAME}" --replace --ttl "${TTL}"
exit 0
