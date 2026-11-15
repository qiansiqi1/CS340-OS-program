#!/bin/bash
set -e

# part2 性能测试脚本
SRC=perf_bench/perf_micro.c
BIN_NATIVE=./perf_native
BIN_ASAN=./perf_asan
OUT_DIR=results/perf
RUN_TIMES=5   # 重复运行次数，至少3次

mkdir -p ${OUT_DIR}
rm -f ${BIN_NATIVE} ${BIN_ASAN}

echo "[Compile] native -O2"
clang -O2 -o ${BIN_NATIVE} ${SRC}

echo "[Compile] asan -O2"
clang -O2 -fsanitize=address -o ${BIN_ASAN} ${SRC}

echo "run_times: ${RUN_TIMES}" > ${OUT_DIR}/meta.txt
echo "native_bin: ${BIN_NATIVE}" >> ${OUT_DIR}/meta.txt
echo "asan_bin: ${BIN_ASAN}" >> ${OUT_DIR}/meta.txt

# 输出表头 tsv
echo "run_id,real_native,user_native,sys_native,real_asan,user_asan,sys_asan" > ${OUT_DIR}/raw.tsv

for (( idx=1; idx<=${RUN_TIMES}; idx++ ))
do
    echo "==== trial ${idx} ===="

    # native
    TIME_NATIVE=$( { time ${BIN_NATIVE} ; } 2>&1 )
    REAL_N=$(echo "${TIME_NATIVE}"|grep real|awk '{print $2}')
    USER_N=$(echo "${TIME_NATIVE}"|grep user|awk '{print $2}')
    SYS_N=$(echo "${TIME_NATIVE}"|grep sys|awk '{print $2}')

    # asan
    TIME_ASAN=$( { time ${BIN_ASAN} ; } 2>&1 )
    REAL_A=$(echo "${TIME_ASAN}"|grep real|awk '{print $2}')
    USER_A=$(echo "${TIME_ASAN}"|grep user|awk '{print $2}')
    SYS_A=$(echo "${TIME_ASAN}"|grep sys|awk '{print $2}')

    echo "${idx},${REAL_N},${USER_N},${SYS_N},${REAL_A},${USER_A},${SYS_A}" >> ${OUT_DIR}/raw.tsv

    echo "native real=${REAL_N} user=${USER_N} sys=${SYS_N}"
    echo "asan   real=${REAL_A} user=${USER_A} sys=${SYS_A}"
done

# 保存原始文本日志
cp ${OUT_DIR}/raw.tsv ${OUT_DIR}/raw.log

rm -f ${BIN_NATIVE} ${BIN_ASAN}
echo "done, raw data saved to ${OUT_DIR}/raw.tsv"
