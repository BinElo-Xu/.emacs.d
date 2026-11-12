# Emacs 配置快捷键速查表

本文档整理 `~/.emacs.d` 配置中显式绑定、或通过自定义前缀开放出来的快捷键。

## 约定

- `C-x p f` 表示依次按下 `C-x`、`p`、`f`。
- `RET`、`TAB`、`SPC` 分别表示回车、Tab、空格。
- `Evil normal` 表示 Evil 的 normal state；`Evil insert` 表示 insert state。
- “全局”表示不限于某个 major mode，但具体命令仍可能要求当前缓冲区属于某个项目、已启动 Eglot 等。
- Project 前缀有多个等价入口：
  - `C-x p ...`：标准 project.el 前缀；
  - `C-c P ...`：任意 state 都可用的别名；
  - `gp ...`：Evil normal state 下的别名。
- Ibuffer 未启用，`C-x p B` 当前未绑定；`C-x p C-b` 使用默认 Buffer Menu。
- 本表不逐一列出 major mode 自带的大量按键；只列配置相关按键和常用 Evil 默认键。
- 部分组合键（如 `C-.`、`C-;`）在终端中可能受终端限制，GUI 下正常。

## Evil 初始 state

| 模式 | state | 备注 |
| --- | --- | --- |
| `pdf-view-mode` | `normal` | PDF 目录、`pdf-occur` 也是 normal |
| `org-mode` / `org-agenda-mode` / `org-roam` | `normal` | `TAB` / `S-TAB` 为 Org cycle |
| `org-capture-mode` | `normal` | 按 `i` 输入；`ZZ` / `ZQ` 完成 / 取消 |
| `dired-mode` / `wdired-mode` | `normal` | `wdired` 按 `i` 编辑文件名 |
| `vterm-mode` | `insert` | `ESC` 回 normal |
| `agent-shell-mode` | `insert` | diff buffer 为 `emacs` state |
| `magit-mode` 系列 | `normal` | commit message 为 `insert` |
| `shell-mode` / `eshell-mode` / `comint-mode` | `insert` | 可直接输入命令 |
| `help-mode` / `occur-mode` / `compilation-mode` | `normal` | 只读或导航 |

## 高频入口

| 快捷键 | 功能 |
| --- | --- |
| `C-x p p` / `C-c P p` / `gp p` | 切换项目 |
| `C-x p f` / `C-c P f` / `gp f` | 在项目中查找文件 |
| `C-x p b` / `C-c P b` / `gp b` | 用 Consult 切换项目缓冲区 |
| `M-s r` | 项目/目录内 `consult-ripgrep` 搜索 |
| `C-x b` | `consult-buffer` |
| `C-c e` | Eglot 全局前缀 |
| `gr` | Eglot 缓冲区中 Evil normal state 的 LSP 前缀 |
| `C-c v` | Python / uv 前缀 |
| `C-c t` | 打开 VTerm 终端 |
| `C-c o o` | 启动或复用 OpenCode |
| `C-x g` | 打开 Magit status |
| `C-c n f` | 查找 Org-roam 节点 |
| `C-c a` | Org Agenda |
| `C-c g` | 在 Org 文件中插入剪贴板图片 |

## 通用前缀

| 前缀 | 生效范围 | 说明 |
| --- | --- | --- |
| `C-c e` | 全局 | Eglot / LSP 命令 |
| `C-c v` | 全局 | Python / uv 命令 |
| `C-c o` | 全局 | OpenCode / agent-shell 命令 |
| `C-c p` | 全局 | Cape 补全命令 |
| `C-c P` | 全局 | project.el 前缀别名 |
| `C-x p` | 全局；Evil 中也可用 | project.el 标准前缀 |
| `gp` | Evil normal（含 OpenCode/agent-shell 缓冲区） | project.el 前缀别名 |
| `gr` | Evil normal；仅 Eglot 管理的缓冲区 | Eglot 前缀 |
| `g.` | Evil normal/visual；编程、配置、文本和 Dired | evil-mc 多光标命令 |

## 补全与搜索

### Corfu 补全弹窗

以下按键只在 Corfu 弹窗打开时生效：

| 快捷键 | 功能 |
| --- | --- |
| `TAB` | 接受/完成当前候选 |
| `RET` | 插入当前候选 |
| `M-n` / `M-p` | 下一个 / 上一个候选 |
| `↓` / `↑` | 下一个 / 上一个候选 |
| `M-TAB` | 展开候选 |
| `M-g` | 查看候选位置 |
| `M-h` | 查看候选文档 |
| `M-SPC` | 插入分隔符，用于多段匹配 |
| `C-g` | 关闭补全弹窗 |

自动补全在 `prog-mode`、`conf-mode`、`comint-mode`、`eshell-mode` 中启用；输入两个字符或输入 `.` 后自动弹出。`TAB` 仍是手动补全和缩进的后备方式。

### Cape

`C-c p` 是 Cape 前缀键：

| 快捷键 | 功能 |
| --- | --- |
| `C-c p p` / `C-c p TAB` / `C-c p M-TAB` | 普通 `completion-at-point` |
| `C-c p d` | Dabbrev 补全 |
| `C-c p f` | 文件名补全 |
| `C-c p k` | 当前语言关键字补全 |
| `C-c p t` | Tags 补全 |
| `C-c p h` | 补全历史 |
| `C-c p s` | Elisp 符号 |
| `C-c p e` | Elisp 代码块 |
| `C-c p a` | Abbrev 补全 |
| `C-c p l` | 当前行内容补全 |
| `C-c p w` | 字典补全 |
| `C-c p :` | Emoji 补全 |
| `C-c p` 后接反斜杠、`_` 或 `^` | TeX 补全 |
| `C-c p &` | SGML 补全 |
| `C-c p r` | RFC1345 补全 |

### Embark 与 Marginalia

| 快捷键 | 作用范围 | 功能 |
| --- | --- | --- |
| `C-.` | 全局 | `embark-act`，对当前目标执行上下文操作 |
| `C-;` | 全局 | `embark-dwim` |
| `C-h B` | 全局 | `embark-bindings`，替代默认的 `describe-bindings` |
| `M-A` | minibuffer | `marginalia-cycle`，循环切换候选注释 |

### Consult

| 快捷键 | 功能 |
| --- | --- |
| `C-c M-x` | `consult-mode-command` |
| `C-c h` | `consult-history` |
| `C-c k` | `consult-kmacro` |
| `C-c m` | `consult-man` |
| `C-c i` | `consult-info` |
| `C-x M-:` | `consult-complex-command` |
| `C-x b` | `consult-buffer` |
| `C-x 4 b` | `consult-buffer-other-window` |
| `C-x 5 b` | `consult-buffer-other-frame` |
| `C-x t b` | `consult-buffer-other-tab` |
| `C-x r b` | `consult-bookmark` |
| `C-x p b` | `consult-project-buffer` |
| `M-#` | `consult-register-load` |
| `M-'` | `consult-register-store` |
| `C-M-#` | `consult-register` |
| `M-y` | `consult-yank-pop` |
| `M-g e` | `consult-compile-error` |
| `M-g r` | `consult-grep-match` |
| `M-g f` | `consult-flymake` |
| `M-g g` / `M-g M-g` | `consult-goto-line` |
| `M-g o` | `consult-outline` |
| `M-g m` | `consult-mark` |
| `M-g k` | `consult-global-mark` |
| `M-g i` | `consult-imenu` |
| `M-g I` | `consult-imenu-multi` |
| `M-s d` | `consult-fd` |
| `M-s c` | `consult-locate` |
| `M-s g` | `consult-grep` |
| `M-s G` | `consult-git-grep` |
| `M-s r` | `consult-ripgrep` |
| `M-s l` | `consult-line` |
| `M-s L` | `consult-line-multi` |
| `M-s k` | `consult-keep-lines` |
| `M-s u` | `consult-focus-lines` |
| `M-s e` | `consult-isearch-history` |

`Info-search` 被 remap 到 `consult-info`，因此在 Info 中搜索会使用 Consult。

### Isearch 与 minibuffer 中的 Consult

| 快捷键 | 作用范围 | 功能 |
| --- | --- | --- |
| `M-e` | Isearch | `consult-isearch-history` |
| `M-s e` | Isearch | `consult-isearch-history` |
| `M-s l` | Isearch | `consult-line` |
| `M-s L` | Isearch | `consult-line-multi` |
| `M-s` | minibuffer | `consult-history` |
| `M-r` | minibuffer | `consult-history` |

### Vertico 扩展

| 快捷键 | 功能 |
| --- | --- |
| `M-R` | 恢复上一次 Vertico 补全会话（`vertico-repeat`） |
| `RET` | 在文件补全中进入选中的目录；否则接受当前候选 |
| `DEL` | 在文件路径中删除前一个路径组件 |
| `M-DEL` | 在文件路径中删除前一个单词 |

`RET` / `DEL` / `M-DEL` 只在 Vertico 文件补全中改变目录导航行为，普通补全
仍然接受或编辑输入。

## 项目（project.el）

项目前缀为 `C-x p`、`C-c P` 或 Evil normal 下的 `gp`。下表只写 `C-x p`，把前缀替换成 `C-c P` 或 `gp` 后同样可用。

| 快捷键 | 功能 |
| --- | --- |
| `C-x p p` | `project-switch-project`，切换项目 |
| `C-x p f` | 在当前项目中查找文件 |
| `C-x p F` | 在项目或外部根目录中查找文件 |
| `C-x p b` | `consult-project-buffer`，用 Consult 切换项目缓冲区 |
| `C-x p g` | 在当前项目中搜索正则表达式 |
| `C-x p G` | 在项目或外部根目录中搜索正则表达式 |
| `C-x p r` | 在项目中执行 `query-replace-regexp` |
| `C-x p d` | 查找并打开项目中的目录 |
| `C-x p D` | 用 Dired 打开项目根目录 |
| `C-x p v` | 打开项目的 `vc-dir` |
| `C-x p m` | 打开当前项目的 Magit status |
| `C-x p s` | 在项目根目录启动 shell |
| `C-x p e` | 在项目根目录启动 Eshell |
| `C-x p c` | 编译项目 |
| `C-x p k` | 删除项目相关缓冲区 |
| `C-x p C-b` | 列出项目缓冲区（Buffer Menu） |
| `C-x p C-s` | 保存项目中的缓冲区 |
| `C-x p o` | 在项目根目录执行任意命令 |
| `C-x p x` | 在项目根目录执行 `M-x` |
| `C-x p !` | 在项目根目录执行 shell command |
| `C-x p &` | 在项目根目录执行异步 shell command |
| `C-x p R` | 记住某个目录下的项目；前缀参数递归查找 |
| `C-x p X` | 遗忘某个项目 |
| `C-x p Z` | 清理已失效的项目 |

说明：

- `C-x p B` 未绑定；Ibuffer 没有启用。
- `C-x p C-b` 使用 Emacs 默认 Buffer Menu。
- `C-x p p` 的 dispatch 菜单中按 `b` 也使用 `consult-project-buffer`。
- `C-x p p` 的 dispatch 菜单中按 `m` 打开 Magit status。

## Eglot 与 LSP

### 全局 `C-c e` 前缀

这些命令在任意 Evil state 下都可以使用；没有活动 Eglot 服务器时相关命令会报错。

| 快捷键 | 功能 |
| --- | --- |
| `C-c e a` | 代码操作（code actions） |
| `C-c e .` | 快速修复 |
| `C-c e o` | 整理导入 |
| `C-c e r` | 重命名符号 |
| `C-c e f` | 格式化（区域/当前范围） |
| `C-c e F` | 格式化整个缓冲区 |
| `C-c e d` | 跳转到定义 |
| `C-c e D` | 查找引用 |
| `C-c e s` | `xref-find-apropos`，工作区符号搜索 |
| `C-c e b` | 跳转后退 |
| `C-c e B` | 跳转前进 |
| `C-c e h` | 在 Eldoc 缓冲区查看文档 |
| `C-c e c` | 调用层级 |
| `C-c e y` | 类型层级 |
| `C-c e i` | 切换 inlay hints |
| `C-c e t` | 切换 semantic tokens |
| `C-c e e` | 打开 Eglot 事件日志 |
| `C-c e l` | 列出 Eglot 连接 |
| `C-c e R` | 重新连接服务器 |
| `C-c e q` | 关闭当前服务器 |
| `C-c e Q` | 关闭全部服务器 |

### Evil normal state 中的 Eglot 键

仅在 Eglot 管理的缓冲区中生效：

| 快捷键 | 功能 |
| --- | --- |
| `gd` | 跳转到定义 |
| `gD` | 在另一个窗口跳转到定义 |
| `g5` | 在另一个 frame 跳转到定义 |
| `K` | 在 Eldoc 缓冲区查看文档 |
| `C-t` | 跳回跳转前的位置 |
| `gr` | Eglot / LSP 前缀 |

`gr` 子键：

| 快捷键 | 功能 |
| --- | --- |
| `grn` | 重命名符号 |
| `gra` | 代码操作 |
| `gr.` | 快速修复 |
| `grc` | 整理导入 |
| `grf` | 格式化 |
| `grF` | 格式化整个缓冲区 |
| `grd` | 跳转到定义 |
| `grD` | 在另一个窗口跳转到定义 |
| `grr` | 查找引用 |
| `gri` | 跳转到实现 |
| `grt` | 跳转到类型定义 |
| `grh` | 查看文档 |

## Python 与 uv

`C-c v` 是 Python / uv 前缀，在任意 Evil state 下可用。

| 快捷键 | 功能 |
| --- | --- |
| `C-c v s` | `uv sync`，创建/更新 `.venv` 并安装依赖 |
| `C-c v l` | `uv lock` |
| `C-c v v` | `uv venv` |
| `C-c v a` | `uv add`，添加依赖 |
| `C-c v r` | `uv run`，在项目环境中执行命令 |
| `C-c v p` | `run-python`，启动 Python shell |

## C/C++ 与构建文件

C/C++ 使用 clangd，并复用 Eglot 的按键：

| 快捷键 | 功能 |
| --- | --- |
| `C-c e` | Eglot 全局前缀 |
| `gr` | Eglot 缓冲区中 Evil normal state 的 LSP 前缀 |
| `gd` / `K` / `C-t` | 定义 / 文档 / 跳回 |
| `C-c p` | Cape 补全前缀 |
| `C-x p` / `gp` / `C-c P` | project.el 项目前缀 |

Makefile 模式还提供一些内置按键（不是本配置新增）：

| 快捷键 | 功能 |
| --- | --- |
| `C-c TAB` | 插入 GNU make 函数 |
| `C-c C-f` | 把当前文件名插入为 target |
| `C-c C-c` | 注释/取消注释当前区域 |

C/C++ 没有单独的调试快捷键；调试在 Emacs 外部使用 gdb。

## 界面与窗口

| 快捷键 | 功能 |
| --- | --- |
| `M-o` | 按标签切换窗口（`ace-window`）；两个窗口时直接切换 |
| `C-c <left>` / `C-c <right>` | 撤销 / 重做窗口布局变化（`winner-mode`） |
| `C-=` / `C-+` / `C--` | 放大 / 缩小当前缓冲区的文字 |
| `C-0` | 重置当前缓冲区的文字大小 |

`C-=` / `C--` 在 PDF buffer 中改为缩放 PDF 页面；`C-0` 恢复 100%。
`M-o` 在窗口多于两个时显示 `a`、`s`、`d`、`f` 等标签，按对应字母跳转；标签也会
显示在各窗口的 mode line 上。`which-key` 会在前缀键停顿后自动显示后续按键；
`repeat-mode` 用于重复执行支持重复的 Emacs 命令。

## VTerm 终端

| 快捷键 | 功能 |
| --- | --- |
| `C-c t` | 在当前项目根目录打开 VTerm |
| `C-c T` | 在另一个窗口打开 VTerm |
| `C-u 2 C-c t` | 切换或创建编号为 2 的 VTerm 会话 |
| `C-x p p` 然后 `t` | 在项目 dispatch 菜单中打开 VTerm |

VTerm 内部：

| 快捷键 | 功能 |
| --- | --- |
| `ESC` | 默认回到 Evil normal state |
| `C-c C-z` | 切换 ESC 是交给 Evil 还是发送给终端 |
| `C-c C-t` | 进入/退出 `vterm-copy-mode` |
| `C-c C-l` | 清除滚动历史 |
| `C-c C-n` / `C-c C-p` | 下一个 / 上一个 shell prompt |
| `C-c C-r` | 重置终端光标位置 |
| `i` / `a` / `I` / `A` | normal state 下进入输入状态 |
| `p` / `P` | 粘贴到终端 |
| `d` / `D` / `x` / `X` | 删除终端命令行内容 |
| `c` / `C` / `s` / `S` | 修改终端命令行内容 |
| `u` | 撤销终端输入 |
| `j` / `k` | 在终端历史中移动 |
| `G` | 跳到终端光标位置 |
| `[[` / `]]` | 上一个 / 下一个 shell prompt |

VTerm 由 `evil-collection` 提供 normal state 集成；新建终端默认进入 insert
state。要在终端里运行 Vim、SSH 或另一个 Emacs 时，先用 `C-c C-z` 把 ESC
交给终端。

## 多光标（evil-mc）

`g.` 是 `evil-mc` 多光标前缀，在 Evil normal/visual state 下使用。
它在编程、配置、文本（含 Org）和 Dired 缓冲区中自动启用。按键由
`evil-collection` 的 evil-mc 集成提供，默认的直接按键已被清除。

Dired 是只读缓冲区；要批量修改文件名，先用 `C-x C-q` 进入
`wdired-mode`，改完后按 `C-c C-c` 提交。

| 快捷键 | 功能 |
| --- | --- |
| `g. n` / `g. N` | 在下一个 / 上一个匹配处添加光标 |
| `g. a` | 在所有匹配处添加光标 |
| `g. C-m` | 在当前位置添加光标 |
| `g. o` / `g. O` | 在下一行 / 上一行添加光标 |
| `g. I` / `g. A` | 在可视选区开头 / 结尾添加光标 |
| `g. C-n` / `g. C-S-n` | 跳到下一个 / 上一个匹配，但不添加光标 |
| `g. M-n` / `g. M-N` | 跳到下一个 / 上一个已有光标 |
| `g. C-u` / `g. C-S-u` | 在已有光标之间前后跳过 |
| `g. u` / `g. q` | 撤销最近添加 / 全部光标 |
| `g. C-p` / `g. C-r` | 暂停 / 恢复光标 |
| `g. 0` / `g. $` | 跳到第一个 / 最后一个光标 |

`g. n` / `g. N` 支持数字前缀：

| 快捷键 | 功能 |
| --- | --- |
| `3 g. n` | 在当前匹配及后续匹配处连续添加 3 个光标 |
| `5 g. N` | 向反方向连续添加 5 个光标 |
| `3 g. o` / `3 g. O` | 在下面 / 上面连续 3 行添加光标 |

只想标记当前匹配之后的项时，先用 `g. C-n` 跳到下一个匹配，再按 `3 g. n`。

`g. n` / `g. N` 之后会进入临时重复状态：

| 按键 | 功能 |
| --- | --- |
| `;` | 继续在下一个匹配处添加光标 |
| `,` | 向相反方向添加光标 |

按任意其他键退出重复状态，`;` 恢复为 Evil 默认的重复查找行为。`3 ;` 可以
一次再标记 3 个匹配。

## OpenCode

`C-c o` 是 OpenCode 前缀：

| 快捷键 | 功能 |
| --- | --- |
| `C-c o o` | 在当前项目启动或复用 OpenCode |
| `C-c o n` | 强制启动新的 OpenCode 会话；默认会列出已有 session 供选择 |
| `C-c o s` | 发送当前选区 |
| `C-c o d` | 发送当前区域或错误（DWIM） |
| `C-c o t` | 显示/隐藏 OpenCode 缓冲区 |

OpenCode shell 内部：

| 快捷键 | 功能 |
| --- | --- |
| `RET` | 提交 prompt |
| `M-J` | 插入换行 |
| `TAB` | 在三角形/标题上折叠/展开；普通位置跳到下一项 |
| `C-c C-c` | 中断当前请求 |
| `C-c C-r` | 发送当前选区 |
| `C-c C-v` | 选择模型 |
| `C-c C-m` | 选择 session mode |
| `C-c C-t` | 选择 thought level |
| `C-c C-o` | 切换到其他 agent-shell 缓冲区 |
| `C-c o y` | 粘贴；剪贴板是图片时插入图片文件上下文 |
| `gp ...` | Evil normal state 下的 project.el 前缀，如 `gp f`、`gp p` |

OpenCode 缓冲区默认进入 Evil insert state；normal state 下也可以按 `RET` 提交。
Agent 修改文件时产生的 diff 缓冲区默认进入 Evil Emacs state，可直接使用
`y` / `n` / `p` / `q` 等按键。

`evil-collection` 原本把 agent-shell normal state 的 `gp` 绑成
`agent-shell-yank-dwim`，会遮住项目前缀并在 kill ring 为空时报
`Kill ring is empty`。本配置已把 `gp` 恢复为 `project-prefix-map`，与普通
缓冲区一致；粘贴命令统一使用 `C-c o y`，因为 Evil 在 insert/normal state 中
分别占用了 `C-y`。

OpenCode 缓冲区通过 ACP 连接，`/` 只补全 `.opencode/commands/` 下的自定义
命令和内置的 `/compact`；TUI 的 `/new`、`/sessions`、`/undo` 等命令不可用。

`C-c o n` 会列出当前项目的已有 session；选择后会恢复该 session 的最后一个
prompt turn（`agent-shell-session-restore-verbosity` 为 `'last`）。需要完整
历史时把它设为 `'full`。如果希望自动恢复最近一次会话，可设置：

```elisp
(setq agent-shell-session-strategy 'latest)
```

## Git 与 Magit

| 快捷键 | 功能 |
| --- | --- |
| `C-x g` | 打开 Magit status |
| `C-x p m` | 打开当前项目的 Magit status |
| `C-t` / `\` | 切换 Magit text mode，便于自由移动和复制 |

Magit 缓冲区中的常用 Evil 键（由 `evil-collection` 提供）：

| 快捷键 | 功能 |
| --- | --- |
| `s` / `u` | 暂存 / 取消暂存 |
| `c` | 提交 |
| `P` | 推送 |
| `f` / `F` | 获取 / 拉取 |
| `l` | 查看日志 |
| `d` | 查看 diff |
| `TAB` | 展开/折叠当前 section |
| `q` | 关闭当前 Magit 缓冲区 |
| `C-t` / `\` | 切换 text mode |

commit message 缓冲区默认进入 Evil insert state：

| 快捷键 | 功能 |
| --- | --- |
| `C-c C-c` | 完成提交 |
| `C-c C-k` | 取消提交 |

在 Magit status/diff 中选择区域后，可以用 `C-c o s` 发送给 OpenCode，或用
`C-c o d` 发送当前区域/上下文。

## Org、Org-roam 与 org-download

| 快捷键 | 作用范围 | 功能 |
| --- | --- | --- |
| `C-c a` | 全局 | `org-agenda` |
| `C-c c` | 全局 | `org-capture` |
| `C-c c t` | Capture | 新建 TODO 到 `inbox.org` |
| `C-c c n` | Capture | 新建带 `:NOTE:` 标签的笔记 |
| `C-c l` | 全局 | `org-store-link` |
| `C-c g` | Org mode | 插入剪贴板图片（`org-download-clipboard`） |
| `C-M-i` | Org mode | `completion-at-point` |
| `C-c n f` | 全局 | 查找 Org-roam 节点 |
| `C-c n i` | 全局 | 插入 Org-roam 节点链接 |
| `C-c n l` | 全局 | 打开/关闭 Org-roam 侧边缓冲区 |
| `C-c n u` | 全局 | 打开/关闭 Org-roam-ui |
| `C-c n b` | 全局 | `consult-org-roam-backlinks` |
| `C-c n s` | 全局 | `consult-org-roam-search` |
| `C-c n d` | 全局 | Org-roam dailies 前缀 |

Agenda 中：

| 快捷键 | 功能 |
| --- | --- |
| `g` | 手动刷新当前 Agenda |
| `C-c C-t` | 切换 TODO 状态并自动刷新 Agenda |
| `C-c C-w` | refile 到任意 agenda 文件中的标题 |

`C-c a` 会重新生成 Agenda，不会复用第一次进入时的旧内容。状态变化日志会写入
任务的 `:LOGBOOK:` drawer。

### `C-c n d` 的 dailies 子键

| 快捷键 | 功能 |
| --- | --- |
| `C-c n d d` | 打开今天的日记 |
| `C-c n d y` | 打开昨天的日记 |
| `C-c n d t` | 打开明天的日记 |
| `C-c n d n` | capture 今天的日记 |
| `C-c n d f` | 下一天 |
| `C-c n d b` | 上一天 |
| `C-c n d c` | 跳转到指定日期 |
| `C-c n d v` | capture 指定日期 |
| `C-c n d .` | 打开日记目录 |
| `C-c n d Y` | capture 昨天的日记（自定义） |
| `C-c n d T` | capture 明天的日记（自定义） |

### Org-roam capture 模板

`M-x org-roam-capture` 选择模板：

| 键 | 模板 | 保存位置 |
| --- | --- | --- |
| `p` | project | `~/Notes/notes/projects/` |
| `l` | literature | `~/Notes/notes/reference/` |
| `z` | zettel(permanent) | `~/Notes/notes/permanent/` |

文件名为 `%Y%m%d%H%M%S.org`，不会在 `~/Notes/` 顶层新建额外目录。

## LaTeX、PDF 与 Org 公式

### PDF（pdf-tools）

PDF 使用 `pdf-tools` 打开，配置位于 `var/init-lisp/init-pdf.el`。normal state
下常用按键：

| 快捷键 | 功能 |
| --- | --- |
| `j` / `k` | 向下 / 向上滚动一行，到页边继续翻页 |
| `C-j` / `C-k` | 直接跳到下一页 / 上一页 |
| `SPC` / `S-SPC`（或 `C-f` / `C-b`） | 向下 / 向上滚动，可在页边翻页 |
| `gg` / `G` 或 `M-<` / `M->` | 第一页 / 最后一页 |
| `P` | 适合整页 |
| `/` | 搜索文本 |
| `n` / `N` | 下一个 / 上一个搜索结果 |
| `M-s o` | `pdf-occur` 搜索结果列表 |
| `o` | 目录（outline） |
| `f` / `F` | 跟随链接 / 执行链接动作 |
| `Q` | 关闭 PDF 缓冲区 |
| `z0` / `C-0` | 恢复按页面宽度显示 |
| `C-=` / `C-+` / `C--` | 放大 / 缩小 PDF 页面 |

PDF 默认按**页面宽度**（`fit-width`）排版，纵向分屏不会把整页缩小。`W` / `H` 的
PDF 专用绑定已解除，现在分别是 Evil 的 `evil-forward-WORD-begin` 和
`evil-window-top`；需要整页显示时按 `P`。

PDF 页面颜色跟随 Emacs 主题；切换主题时已打开的 PDF 会自动刷新。
`pdf-tools` 和其它 Emacs PDF 阅读器一样是按页显示的；`pdf-view-continuous` 已
开启，滚动到页边会继续翻页，通常用一个 buffer 即可。需要连续多页并排显示时建议
使用外部 PDF 阅读器。

### Org 公式

| 快捷键 | 功能 |
| --- | --- |
| `C-c C-x C-l` | 手动切换公式预览 |
| `org-fragtog-mode` | 光标离开公式时自动渲染，进入时显示源码 |
| `org-cdlatex-mode` | Org 公式中的 CDLaTeX 数学输入辅助 |

在公式中，`'`、`^`、`_`、`` ` `` 等键会用于输入 LaTeX 数学结构；离开公式后
恢复普通编辑。

### LaTeX（AUCTeX）

| 快捷键 | 功能 |
| --- | --- |
| `C-c C-c` | 编译当前文档 |
| `C-c C-v` | 在 pdf-tools 中查看 PDF |
| `C-c C-e` | 插入 LaTeX 环境 |
| `C-c C-s` | 插入章节 |
| `C-c C-m` | 插入宏 |
| `C-c [` | RefTeX 引用 |
| `C-c )` | RefTeX 交叉引用 |
| `C-c (` | RefTeX 标签 |

默认使用 XeLaTeX；`C-c C-v` 通过 SyncTeX 跳到 PDF 对应位置。

## Minibuffer、Ex 与 Search

### 普通 minibuffer / Vertico

| 快捷键 | 功能 |
| --- | --- |
| `C-j` / `C-n` / `↓` | 下一个候选或历史项 |
| `C-k` / `C-p` / `↑` | 上一个候选或历史项 |
| `C-h` | 向左移动一个字符 |
| `C-l` | 向右移动一个字符 |
| `C-a` | 移动到输入开头 |
| `C-e` | 移动到输入末尾 |
| `C-u` | `universal-argument` |
| `C-w` | `kill-region` |
| `C-r` | `isearch-backward` |
| `C-y` | `yank` |
| `C-d` | `delete-char` |
| `C-t` | `transpose-chars` |
| `TAB` / `C-i` | 补全；Vertico 中插入当前候选；普通 read-string 中插入 tab |
| `RET` | 接受当前候选并退出 |

在 minibuffer 中按 `ESC` 进入 Evil normal state 后，`j` / `k` 也用于下一个 /
上一个候选，`TAB` 完成补全或插入当前候选。

### Ex 命令行和搜索提示

适用于 `:`、`/`、`?` 等提示：

| 快捷键 | 功能 |
| --- | --- |
| `C-h` | 向左移动 |
| `C-e` | 移动到末尾 |
| `C-a` / `C-d` | Ex 补全 |
| `C-u` | 删除整行 |
| `C-j` | 下一个历史项 |
| `C-k` | 上一个历史项 |
| `j` / `k` | Evil normal state 下浏览历史 |

注意：`C-j` 在 minibuffer 中不再直接退出，确认请使用 `RET`。

## Evil 常用键（参考）

以下是 Evil / evil-collection / 已加载扩展包提供的基础按键，不属于本配置新增绑定，列在此处便于查阅：

| 快捷键 | 功能 |
| --- | --- |
| `i` / `a` / `o` / `O` | 进入 insert state |
| `ESC` | 回到 normal state |
| `v` / `V` / `C-v` | 字符 / 行 / 块可视模式 |
| `h` / `j` / `k` / `l` | 左 / 下 / 上 / 右移动 |
| `w` / `b` / `e` | 下一个词 / 上一个词 / 词尾 |
| `0` / `$` | 行首 / 行尾 |
| `gg` / `G` | 文件开头 / 文件末尾 |
| `C-d` / `C-u` | 向下 / 向上翻半页 |
| `d` / `c` / `y` | 删除 / 修改 / 复制 |
| `p` / `P` | 粘贴 |
| `u` / `C-r` | 撤销 / 重做 |
| `/` / `?` / `n` / `N` | 搜索及下一个 / 上一个匹配 |
| `*` / `#` | 搜索光标下单词 |
| `gc` | 注释/取消注释（normal 用 `gc{motion}`，当前行可用 `gcc`；visual 直接 `gc`） |
| `g;` / `g,` | 跳转到最近修改处 / 反向跳转 |
| `ys{motion}{char}` | 为文本对象添加包围符号 |
| `cs{old}{new}` | 修改包围符号 |
| `ds{char}` | 删除包围符号 |
| `S{char}` / `gS{char}` | visual state 下包围选区 |
| `gd` / `K` / `C-t` | Eglot 缓冲区中的定义 / 文档 / 跳回 |
