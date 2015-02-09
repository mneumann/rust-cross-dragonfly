DIR=`echo $1 | rev | cut -f 2- -d / | rev`
REV=`echo $1 | rev | cut -f 1 -d / | rev`

echo dir: $DIR
echo rev: $REV

if [ ! -d ${DIR} ]; then
  echo "*** git clone $2 -> ${DIR}"
  git clone --recursive $2 ${DIR}
fi
echo "*** git pull"
(cd ${DIR} && git pull)
echo "*** git checkout ${DIR} ${REV}"
(cd ${DIR} && git checkout -q ${REV})
touch ${DIR}/${REV}