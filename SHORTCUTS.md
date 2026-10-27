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
| `C-c n f` | 查找 Org-roam 节点 |
| `C-c a` | Org Agenda |
| `C-c g` | 在 Org 文件中插入剪贴板图片 |

## 通用前缀

| 前缀 | 生效范围 | 说明 |
| --- | --- | --- |
| `C-c e` | 全局 | Eglot / LSP 命令 |
| `C-c v` | 全局 | Python / uv 命令 |
| `C-c p` | 全局 | Cape 补全命令 |
| `C-c P` | 全局 | project.el 前缀别名 |
| `C-x p` | 全局；Evil 中也可用 | project.el 标准前缀 |
| `gp` | Evil normal | project.el 前缀别名 |
| `gr` | Evil normal；仅 Eglot 管理的缓冲区 | Eglot 前缀 |

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
| `M-s d` | `consult-find` |
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

## Org、Org-roam 与 org-download

| 快捷键 | 作用范围 | 功能 |
| --- | --- | --- |
| `C-c a` | 全局 | `org-agenda` |
| `C-c c` | 全局 | `org-capture` |
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
| `RET` | 接受当前候选并退出 |

在 minibuffer 中按 `ESC` 进入 Evil normal state 后，`j` / `k` 也用于下一个 / 上一个候选。

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
