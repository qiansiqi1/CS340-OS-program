# CS340 项目说明（中文版）

## 这个项目是做什么的

我们要尝试复现论文 [AddressSanitizer: A Fast Address Sanity Checker](https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf) 中的一部分实验。AddressSanitizer，简称 ASan，是一个帮助 C/C++ 程序发现内存越界等错误的工具。仓库提供用于验证 ASan 报告的基础测试和堆红区实验。

## 第一次运行：Windows 用户也能直接操作

**电脑没有 Linux 也能运行。推荐使用下面的 GitHub 网页方法，不需要先下载代码、安装编译器或在自己电脑上输入命令。** 程序实际运行在 GitHub 提供的 Ubuntu 电脑上，你的电脑负责打开网页、启动任务和下载结果。

### 第 1 步：登录 GitHub，选择要运行的实验

打开[项目首页](https://github.com/qiansiqi1/CS340-OS-program)，登录拥有本仓库写入权限的账号。只读访问者可以查看公开运行记录，但不能直接在这个仓库启动任务；需要先获得权限，或 Fork 到自己的账号后在自己的仓库启用 Actions。

本项目有两个工作流（可以理解成两套“自动运行步骤”）：

| 你想做什么 | 在 Actions 左侧选择 | 结束后下载什么 |
| --- | --- | --- |
| 检查 ASan 能否发现越界错误 | **ASan smoke test** | `asan-smoke-…` 和 `asan-redzone-…` 两个包 |
| 测量开启 ASan 后程序慢了多少 | **ASan performance benchmark** | `asan-perf-…` 一个包 |

两个实验分别启动。检测实验成功，不代表性能实验也运行过。第一次完整复查项目时，两套都运行一次即可；性能工作流一次就会完成每种配置的九次正式测量，不必手动点击九次。

### 第 2 步：进入 Actions 页面，找到运行按钮

1. 在仓库顶部点击 **Actions**，再点击左侧需要的工作流名称。也可以直接打开[检测工作流](https://github.com/qiansiqi1/CS340-OS-program/actions/workflows/asan-smoke.yml)或[性能工作流](https://github.com/qiansiqi1/CS340-OS-program/actions/workflows/asan-performance.yml)。
2. 确认现在看到的是“运行记录列表”。**如果屏幕中间是带行号的 `.yml` 代码，你还在 Code 文件页面。** 点击该页面右上角的 **View runs**，或返回顶部 **Actions** 后选择工作流。
3. 在运行列表上方右侧找到 **Run workflow ▾**，点开它。
4. 菜单里的 **Branch** 选择 `main`，再点击菜单里面绿色的 **Run workflow**。这一步才真正启动任务。
5. 稍等并刷新页面，列表中会出现一条新的运行记录。点开这条记录，进入详情页。

### 第 3 步：等待任务完成，查看是否成功

依赖安装和排队可能需要几分钟，不用一直重复点击启动。

- 黄色圆点或旋转图标：正在排队或运行，继续等待。
- 绿色勾：这次工作流成功完成。
- 红色叉：运行失败，点击左侧任务，再展开标红的步骤查看错误信息。

检测工作流中应看到 `smoke` 和 `redzone` 两个任务均成功；性能工作流中应看到 `performance` 任务成功。性能结果汇总表在运行的 **Summary**（概览）页面；原始数据在下面介绍的附件里。

检测程序故意制造了越界，所以原始日志里出现 `heap-buffer-overflow`、`ABORTING` 或某个越界用例退出码为 1，是预期现象。**整体是否成功，看任务状态和 `summary.txt`，不要只凭日志里出现 ERROR 判断失败。** 安全用例应退出 0，越界用例应被 ASan 检出。

### 第 4 步：下载结果到自己的电脑

1. 保持在这一次运行的详情页，点击左侧 **Summary**（如果已经在概览页就不用再点）。
2. 向页面下方滚动，找到 **Artifacts**。它的意思是本次运行生成的可下载文件。
3. 点击对应附件名称，浏览器会下载一个 ZIP 压缩包。检测实验下载两个包；性能实验下载一个包。
4. 在 Windows 下载文件夹中右键 ZIP，选择 **全部提取**，然后打开解压后的文件夹。

附件名称包含本次代码版本号（SHA）；性能包还包含运行编号和第几次尝试，用来区分不同运行。例如你这次下载的 `asan-perf-fb54e2b…-46114837908-1.zip`，对应[这条运行记录](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46114837908)。不必自己修改附件名字来启动程序。

附件只保留 **30 天**，请及时下载。下载后的文件不会自动出现在仓库代码里；需要归档时，再按照[证据说明](evidence/README.md)保存到新的证据目录并记录运行链接。

### 第 5 步：打开哪些文件、怎么看数据

**检测结果：** 解压 `asan-smoke-…` 和 `asan-redzone-…` 后，分别先看 `summary.txt`。

| 文件 | 用途 |
| --- | --- |
| 基础测试包中的 `summary.txt` | 检查安全用例、越界用例的退出状态和最终 PASS/FAIL |
| `safe.log` / `overflow.log` | 安全访问输出、实际 ASan 越界报告 |
| 红区测试包中的 `summary.txt` | 查看通过数和失败数；全部符合协议时应为 84/84，失败 0 |
| 红区测试包中的 `trials.tsv` | 每次试验的分配大小、模式、退出状态、判定和对应日志路径 |
| 红区测试包中的 `logs/` | 每次试验的完整原始输出 |
| 两个包各自的 `environment.txt` | 本次代码版本、工具版本和运行环境 |

84 次红区试验包含 42 次安全对照和 42 次故意越界，不能把 84 次都写成“检出了越界”。

**性能结果：** 你上传的性能 ZIP 中有下面七个文件，可以按这个顺序看：

| 文件 | 用途与打开方法 |
| --- | --- |
| `benchmark/summary.csv` | 先用 Excel 打开，看每种配置的平均耗时、标准差和倍数 |
| `benchmark/raw.csv` | 查看每次正式测量，共 27 条：三种配置各九条 |
| `benchmark/execution.log` | 查看运行顺序、退出状态和原始输出；包含预热，共 30 次执行 |
| `benchmark/environment.txt` | 查看代码版本、CPU、编译器、运行库、编译参数和文件哈希 |
| `workflow-environment.txt` | 查看这次 Actions 的网址、运行次数、系统镜像和安装的软件版本 |
| `runner.log` | 查看性能脚本在终端打印的内容 |
| `setup.log` | 查看安装依赖的记录，安装失败时用它排查 |

`summary.csv` 中的列含义如下：

| 列名 | 通俗解释 |
| --- | --- |
| `variant` | `native` 是未开启 ASan；`asan_q0` / `asan_q64` 是开启 ASan、隔离区分别设为 0 / 64 MiB |
| `n` | 正式测量次数，本协议每种配置为 9 |
| `mean_seconds` | 平均运行时间，单位秒，越小表示耗时越少 |
| `sample_sd_seconds` | 多次耗时的波动大小，数值越大说明越不稳定 |
| `ratio_to_native` | 相对原生程序的耗时倍数；例如 2.2 表示用了约 2.2 倍时间 |
| `slowdown_pct` | 比原生程序增加的耗时百分比；2.2 倍耗时对应约 120% 增加，不是 220% 增加 |

CSV 可以用 Excel 打开；`.log`、`.txt` 可以用记事本打开；TSV 可用 Excel 导入并选择“制表符”分隔。保留一份原始文件，分析时用副本，避免 Excel 保存时改变原始数据格式。

GitHub 的电脑可能每次不同，性能数据会波动。优先比较同一批次中的三种配置；不要把不同环境的数据混成一批，也不要把微基准结果当作论文 SPEC CPU2006 的精确复现。当前工作流测量时间，**没有测峰值内存**。

### 常见问题

- **找不到 Run workflow：** 先确认不在 `.yml` 代码页面；点击 **View runs** 或顶部 **Actions**，在左侧选中具体工作流。再确认已登录有写入权限的账号，并且 `main` 中有该工作流。浏览器窗口较窄时可适当缩小网页。
- **看不到 Artifacts：** 先确认在单次运行的 Summary，而不是所有运行的列表；等待运行完成，再向下滚动。下载通常需要登录。超过 30 天的旧附件可能已过期，需要重跑。
- **失败也有 ZIP：** 工作流会尽可能保存失败时的日志，因此“下载到了附件”不等于实验成功。检查失败步骤和 `setup.log`、`runner.log`，不要把不完整结果填入报告。
- **只改 README 后性能没有自动运行：** 这是正常的。性能工作流只在相关代码/工作流改变时自动运行；需要新一批数据时用 **Run workflow** 手动启动。
- **Windows 提示没有 gcc 或 clang：** 网页方法不需要本机编译器。下面的命令只给已经有 Ubuntu 环境的同学使用，不能直接复制到普通 Windows PowerShell 中运行。

## 可选：已经有 Ubuntu 时，在本机运行

如果采用前面的网页方法，这一节可以跳过。以下命令适用于 Ubuntu 24.04 终端（包括装有 Ubuntu 的 WSL2），在项目目录中执行。Git Bash 本身不提供所需 Linux 环境。

第一次使用先安装依赖、下载代码：

```bash
sudo apt-get update
sudo apt-get install --yes git clang-18 libclang-rt-18-dev llvm-18 gcc-13 libasan8 python3
git clone https://github.com/qiansiqi1/CS340-OS-program.git
cd CS340-OS-program
```

已经下载过仓库就不要重复 clone；先进入原有目录，确认自己的修改已保存，再切换/更新到需要测试的版本。以下命令均应在能看到 `scripts/`、`examples/`、`perf_bench/` 的项目根目录运行。

分别运行检测和性能实验：

```bash
# 基础检测；结果在 results/latest/
bash scripts/run_smoke.sh

# 84 次红区试验；结果在 results/redzone/
bash scripts/run_redzone.sh

# 三种配置的性能测量；终端会显示本次结果目录
CC=gcc-13 python3 scripts/run_week3_perf.py
```

性能结果默认保存在新的 `results/week3-<时间>-<随机标识>/` 目录。也可以指定一个尚不存在的目录：

```bash
CC=gcc-13 python3 scripts/run_week3_perf.py --output-dir results/my-performance-01
```

再次运行时换一个新的目录名，避免覆盖已有证据。`results/` 中的数据不会自动上传 GitHub；本地运行也不会生成 Actions 附件。这里的 GCC 13 与网页工作流一致，历史 Week 3 的 GCC 14.2 批次仍是不同环境。

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

- `main` 已在 `40e5f0f` 合并实验分支。[Actions #26](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46110961155) 成功；本次两份 artifact 已逐条核对并原样归档。42/42 次紧邻堆边界的单字节越界写入被检出，42/42 次安全对照正常完成。详见 [Claim 1](docs/claim1.md)、[基础证据](evidence/week1/)和[红区原始日志](evidence/claim1/)。结论限于所测子集。
- 第二部分的性能基准和运行脚本见 [`1240011613CHENYANTONG` 分支](https://github.com/qiansiqi1/CS340-OS-program/tree/1240011613CHENYANTONG)。第三周性能结果见[独立提交](https://github.com/qiansiqi1/CS340-OS-program/commit/8b9dbd3c183ce8e4711e6391aab97cefb78b9dd1)。该提交的 [Actions 运行](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/44249774534) 执行的是 `smoke` 和 `redzone`。这些代码和历史数据现已合并到 main；引用时仍须区分历史性能批次与合并后的新运行。

## 性能实验：合并后的运行入口

第二周提供 `perf_bench/perf_micro.c` 分配微基准。第三周在相同负载上保存了两批真实性能记录、统计结果和 quarantine 补充实验，详见 [Claim 2](docs/claim2.md) 与[第三周分析](docs/week3-performance.md)。

- 正式入口：Linux 下运行 `python3 scripts/run_week3_perf.py`，需要 GCC/libasan、Python 3.9+、Git 和 ldd。
- 已保存实验使用 GCC 14.2、Linux 容器，每条件预热一次、测量九次。它与 Clang 18 的检测实验是不同环境。
- `scripts/run_perf.sh` 仅作为旧命令的兼容入口，转交到上述 Python 脚本；不再生成旧的五次测量 `raw.tsv`。
- 新增独立工作流 **ASan performance benchmark**：在 Actions 中选择它，点击 **Run workflow → main** 即可用 GitHub Ubuntu 运行性能实验。完成后下载 `asan-perf-<SHA>-<运行ID>-<尝试次数>`，详见[运行和数据下载说明](docs/performance-actions.md)。检测工作流的绿色状态仍不能证明性能已执行。
- 新测量默认写入唯一的 `results/week3-<UTC时间>-<随机标识>/`，也可以用 `--output-dir` 指定一个尚不存在的目录。不要覆盖已保存证据。

```bash
sudo apt-get install --yes gcc python3
python3 scripts/run_week3_perf.py
```

现有数据支持本分配负载中 ASan 约 2.3 倍运行时间，不代表精确复现论文的 SPEC CPU2006 汇总结果。本次检测计数已核验归档；新性能工作流[首次运行](https://github.com/qiansiqi1/CS340-OS-program/actions/runs/46113854580)已成功，具体统计仍须检查新 artifact 后更新。详见[复现状态及补充建议](docs/replication-status.md)。

## 进一步核验与交接

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
