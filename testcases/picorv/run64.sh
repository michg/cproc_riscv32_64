CC=../../cproc/cproc
AS=../../elftools/minias/minias
LD=../../elftools//neatld/nld
AR=../../elftools/ar/ar
CFLAGS="-S -I."  
SRCDIR=./src/$1
RESDIR=./result/$1

rm -f -r result
mkdir result 
mkdir ${RESDIR}
copts=$(<${SRCDIR}/copts.txt)
libs=$(<${SRCDIR}/libs.txt)
ldopt=""
for lib in ${libs}; do
	ldopt+="${lib}64.a "
done
${CC} -emit-qbe ${copts} ${SRCDIR}/$1.c  -o ${RESDIR}/$1.qbe
${CC} ${CFLAGS} ${copts} ${SRCDIR}/$1.c  -o ${RESDIR}/$1_pre.s
cpp -include ../../defs.inc ${RESDIR}/$1_pre.s -o ${RESDIR}/$1.s
${AS} -o ${RESDIR}/$1.o -m64 ${RESDIR}/$1.s
${AS} -o ${RESDIR}/start.o -m64 start.s
${CC} ${CFLAGS} io.c -o ${RESDIR}/io_pre.s
cpp -include ../../defs.inc ${RESDIR}/io_pre.s -o ${RESDIR}/io.s
${AS} -o ${RESDIR}/io.o -m64 ${RESDIR}/io.s
${LD} -mc=0 -t ${RESDIR}/map.txt -ns -ne -o ${RESDIR}/$1.bin ${RESDIR}/start.o ${RESDIR}/io.o ${RESDIR}/$1.o ${ldopt}
${LD} -mc=0 -o ${RESDIR}/$1.elf ${RESDIR}/start.o ${RESDIR}/io.o ${RESDIR}/$1.o ${ldopt}
python3 mkhex.py ${RESDIR}/$1
cp ${RESDIR}/$1.hex firmware.mem
./simv | head -n -1 >> ${RESDIR}/$1.log
if cmp -s "${SRCDIR}/$1.ref" "${RESDIR}/$1.log"
   then
      echo "Testcase $1 ok."
   else
      echo "Testcase $1 fail."
   fi 



