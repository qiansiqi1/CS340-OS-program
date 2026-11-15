# Claim2：ASan内存分配性能开销复现
## 实验目标
复现论文 AddressSanitizer: A Fast Address Sanity Checker 中关于内存分配释放的性能开销；对比原生程序与开启ASan程序的运行时间。

### 论文参照
填写：论文对应章节/图号，例如：Section 6 Performance Evaluation，分配释放微基准测试。

## 实验设置
- 编译器：clang‑18
- 编译优化级别：**‑O2**
- 测试程序：`perf_bench/perf_micro.c`
- 测试逻辑：循环进行 1 000 000 次小块malloc/free，少量内存写入避免编译器优化消除测试逻辑。
- 重复次数：5次
- 运行环境：GitHub Actions Ubuntu‑24.04 共享虚拟机

## 编译命令
native版本：
```bash
clang -O2 -o perf_native perf_bench/perf_micro.c
