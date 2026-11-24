# CS340 项目说明（中文版）

## 这个项目是做什么的

我们要尝试复现论文 [AddressSanitizer: A Fast Address Sanity Checker](https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf) 中的一部分实验。AddressSanitizer，简称 ASan，是一个帮助 C/C++ 程序发现内存越界等错误的工具。仓库提供用于验证 ASan 报告的基础测试和堆红区实验。

## 最后要交付什么

1. **可复查的代码和步骤。** 记录环境、运行命令和输出位置。
2. **真实的运行记录。** 保留原始输出、错误报告、源提交和每次测试的结果。
3. **与论文对照。** 指明原文图表、实验设置差异和可比指标。对报告中的性能数值至少测量三次，给出平均值和标准差。
4. **最终报告。** 写清目标、方法、结果、差异原因、局限性和一次只改变一个因素的补充实验。

## 四份任务怎么分

### 第一部分：把错误检测实验跑通

对照正常访问和 ASan 报告，测试不同分配大小的左右边界，保存每次运行的原始日志。

### 第二部分：复现论文中的一项性能结果

选择论文图表，在同一环境下多次测量原生版本与 ASan 版本。保存原始数据并说明统计方法和与论文的差异。

### 第三部分：分析结果并做补充实验

对比前两部分与论文结论，分析差异。补充实验每次改变一个因素，报告中的结论应能追溯到日志或数据。

### 第四部分：交付前整理

核对报告数字与原始日志，统一用词和图表，修正链接、错字和排版，让新同学能按说明复查结果。

## 分支和证据状态

- 默认分支 `main` 的工作流运行 `smoke` 和 `redzone`。[Actions 运行 #10](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/43695706254) 对应源提交 `e8aed04`，两项任务均通过，并上传了两份日志。报告中的实测值仍需逐项核对原始日志。
- 第二部分的性能基准和运行脚本见 [`1240011613CHENYANTONG` 分支](https://github.com/qiansiqi1/CS340-OS-program/tree/1240011613CHENYANTONG)。第三周性能结果见[独立提交](https://github.com/qiansiqi1/CS340-OS-program/commit/8b9dbd3c183ce8e4711e6391aab97cefb78b9dd1)。该提交的 [Actions 运行](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/44249774534) 执行的是 `smoke` 和 `redzone`。引用性能数据时，从对应实验分支确认实际运行环境、原始数据和统计口径。

## 新同学怎么上手

先阅读[英文 README](README.md)、[环境说明](docs/environment.md)和[堆红区实验记录](docs/claim1.md)。

### GitHub Actions

在 [ASan smoke test 工作流](https://github.com/qiansiqi1/CS340-OS-program/actions/workflows/asan-smoke.yml)查看已有运行。有运行权限时，可以选择 **Run workflow**，然后选择 `main`。运行结束后检查两个任务的状态，并在 **Artifacts** 下载 `asan-smoke-<源提交 SHA>` 和 `asan-redzone-<源提交 SHA>`。两份 artifact 的保留期限为 30 天。

### 本地 Ubuntu

使用 Ubuntu 24.04 x86-64，实体机、虚拟机或 WSL2 中的 Ubuntu 均可。在仓库根目录运行两个脚本。已有工作副本时，先确认所在分支和源提交。

```bash
sudo apt-get update
sudo apt-get install --yes git clang-18 libclang-rt-18-dev llvm-18
git clone https://github.com/qiansiqi1/CS340-OS-program.git
cd CS340-OS-program
bash scripts/run_smoke.sh
bash scripts/run_redzone.sh
```

### 从原始日志复查报告数字

| 核对项 | 文件 | 核对方法 |
| --- | --- | --- |
| 源提交和环境 | 两份 artifact 中的 `environment.txt` | 将 `Source` 下的完整 SHA 与 Actions 运行和 artifact 名称中的 SHA 核对 |
| 基础测试（`smoke`） | `results/latest/summary.txt`、`safe.log`、`overflow.log` | 正常访问应退出 0，越界访问应退出 1。检查 ASan 错误类型、写入大小和源位置 |
| 堆红区实验（`redzone`） | `results/redzone/summary.txt`、`trials.tsv`、`logs/` | 核对每行的模式、退出状态和判定，按最后一列打开原始日志，再将通过数与摘要核对 |

表中的 `results/` 路径适用于本地运行。下载的 artifact 解压后可直接查看同名文件。故意越界的单个程序退出 1 是预期行为，整个脚本的通过状态由摘要给出。

在 `results/redzone/` 或对应 artifact 的解压目录中运行下面的命令，按模式复核通过数和试验总数。协议规定每种模式各有 21 次试验，合计 84 次。其中 `left` 和 `right` 共 42 次正常访问，`underflow` 和 `overflow` 共 42 次越界访问。

```bash
awk -F '\t' '
    NR > 1 {
        total[$3]++
        if ($5 == "PASS") passed[$3]++
    }
    END {
        split("left right underflow overflow", modes, " ")
        for (i = 1; i <= 4; i++) {
            mode = modes[i]
            printf "%s: %d/%d\n", mode, passed[mode], total[mode]
        }
    }
' trials.tsv
```

### 保存和交接证据

按照[证据保存说明](evidence/README.md)保存原始文本日志，记录运行链接和源提交，再把核对后的结果填入[堆红区实验记录](docs/claim1.md)。

用自己的 GitHub 账号提交。提交消息应包含本人真实学号、全名和改动说明。仓库只保存项目需要的代码、文档和选定的文本日志。
