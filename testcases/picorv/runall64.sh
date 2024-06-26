CC=../../cproc/cproc
AS=../../elftools/minias/minias
LD=../../elftools//neatld/nld
AR=../../elftools/ar/ar
CFLAGS="-S -I."

rm -f -r result
mkdir result
for name in src/*/; do
	name=${name%/}
	name=${name#src/}
	SRCDIR=src/${name}
	RESDIR=result/${name}
	mkdir ${RESDIR}
        copts=$(<${SRCDIR}/copts.txt)
	libs=$(<${SRCDIR}/libs.txt)
	 ldopt=""
	for lib in ${libs}; do
		ldopt+="${lib}64.a "
	done 
	${CC} ${CFLAGS} ${copts} ${SRCDIR}/${name}.c -o ${RESDIR}/${name}_pre.s
	cpp -include ../../defs.inc ${RESDIR}/${name}_pre.s -o ${RESDIR}/${name}.s
	${CC} ${CFLAGS} io.c -o ${RESDIR}/io_pre.s
	cpp -include ../../defs.inc ${RESDIR}/io_pre.s -o ${RESDIR}/io.s
	${AS} -o ${RESDIR}/start.o -m64 start.s
	${AS} -o ${RESDIR}/io.o -m64 ${RESDIR}/io.s
	${AS} -o ${RESDIR}/${name}.o -m64 ${RESDIR}/${name}.s
	${LD} -ns -ne -o ${RESDIR}/${name}.bin ${RESDIR}/start.o ${RESDIR}/io.o ${RESDIR}/${name}.o ${ldopt}
	python3 mkhex.py ${RESDIR}/${name}
        cp ${RESDIR}/${name}.hex firmware.mem
	./simv | head -n -1 >> ${RESDIR}/${name}.log
	if cmp -s "${SRCDIR}/${name}.ref" "${RESDIR}/${name}.log"
	then
		echo "Testcase ${name} ok." >>result/results.log
	else
		echo "Testcase ${name} fail." >>result/results.log
	fi 
done



