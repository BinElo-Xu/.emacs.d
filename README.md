# Emacs 配置

这份配置以 [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d)
1.5.2 为起点，并遵循它的设计：上游的 `early-init.el`、`init.el` 保持原样，
个人配置写在 `pre-init.el`、`post-init.el` 和 `var/init-lisp/` 中。

## 文档导航

- 基础：目录结构、环境要求、启动与安装、模块加载顺序、Desktop
- 编辑：补全、视觉换行、Minibuffer、多光标、Evil 集成
- 笔记：org-download、Org Agenda、Org-roam、LaTeX/Org/PDF
- 开发：project.el、Eglot、Python、C/C++、Tree-sitter
- 工具：VTerm、OpenCode、Magit
- 界面：窗口、字体、常用快捷键、版本控制

README 说明配置和行为；[SHORTCUTS.md](SHORTCUTS.md) 是按键速查表。

## 目录结构

```text
~/.emacs.d/
├── early-init.el           # minimal-emacs.d，上游文件，不修改
├── init.el                 # minimal-emacs.d，上游文件，不修改
├── pre-early-init.el       # 将 user-emacs-directory 重定向到 var/
├── post-early-init.el
├── pre-init.el             # 加载路径、行号、fill-column 指示线
├── post-init.el            # 按顺序加载 var/init-lisp/ 下的模块
├── custom.el               # Customize 写入的配置
├── var/
│   ├── init-lisp/
│   │   ├── init-theme.el
│   │   ├── init-font.el        # 中英文字体（霞鹜文楷等宽）
│   │   ├── init-sysEnv.el
│   │   ├── init-clipboard.el   # 剪贴板、org-download
│   │   ├── init-file.el
│   │   ├── init-completion.el
│   │   ├── init-evil.el
│   │   ├── init-multicursor.el  # evil-mc 多光标
│   │   ├── init-project.el      # project.el、项目列表与 Evil 项目键位
│   │   ├── init-minibuffer.el   # minibuffer 的 Evil 风格按键
│   │   ├── init-visual-line.el  # 视觉行换行
│   │   ├── init-org.el
│   │   ├── init-latex.el        # Org 公式预览、AUCTeX/RefTeX/CDLaTeX
│   │   ├── init-pdf.el          # PDF 阅读（pdf-tools）、主题与按键
│   │   ├── init-treesit.el      # Tree-sitter 自动安装与 mode remap
│   │   ├── init-eglot.el        # Eglot 通用配置与语言服务器注册辅助
│   │   ├── init-python.el       # Python、uv 与 Eglot 的 Python 集成
│   │   ├── init-c-c++.el        # C/C++、Makefile、CMake 与 clangd
│   │   ├── init-vterm.el        # VTerm 终端与 Evil 集成
│   │   ├── init-opencode.el     # OpenCode 与 agent-shell ACP 集成
│   │   ├── init-magit.el        # Magit、Git 与 Evil/项目集成
│   │   ├── init-ui.el           # which-key、窗口切换、像素滚动
│   │   └── init-desktop.el      # 恢复上次会话的缓冲区与窗口布局
│   ├── elpa/               # 安装的包（不纳入 Git）
│   ├── eln-cache/          # 原生编译缓存（不纳入 Git）
│   ├── tree-sitter/        # Tree-sitter 语法库（不纳入 Git）
│   ├── autosave/           # 自动保存文件（不纳入 Git）
│   ├── desktop/            # Desktop 会话文件（不纳入 Git）
│   ├── org-roam.db         # Org-roam 数据库（不纳入 Git）
│   └── ...                 # 历史、recentf、saveplace 等运行时数据
├── SHORTCUTS.md            # 快捷键速查表
└── README.md
```

`pre-early-init.el` 把 `user-emacs-directory` 设为 `~/.emacs.d/var/`，
因此包目录、历史记录、缓存和自动保存文件都集中在 `var/` 中，仓库根目录只保留
配置文件。

## 环境要求

- Emacs 31.1 或更新版本（推荐并验证于 31.1；29/30 仅部分兼容）
- Linux
- `uv`（用于创建 Python 虚拟环境，以及在未安装语言服务器时通过 `uvx` 启动 basedpyright）
- `clangd`（用于 C/C++ 的 Eglot 语言服务器；可通过发行版包管理器安装）
- `opencode` CLI（用于 agent-shell 的 ACP 集成；需要先执行 `opencode auth login`）
- `fd` 和 `ripgrep`（`consult-fd` 与 `consult-ripgrep` 使用）
- Git 和 C 编译器（首次自动编译 Tree-sitter 语法时需要）
- `cmake` 和 `libvterm`（VTerm 模块首次编译时需要；没有系统 libvterm 时还需要
  `libtool`）
- XeLaTeX（默认 LaTeX 引擎，通常由 `texlive-xetex` 提供）；如果改用
  pdfLaTeX/LuaLaTeX，需要对应的 TeX 引擎
- `dvipng`（Org 公式预览使用；也可以用 `dvisvgm`）
- Poppler 开发头文件、`gcc` 和 `make`（pdf-tools 的 `epdfinfo` 首次编译需要）
- 可选：`latexmk`、`biber`（使用自动构建或 biblatex 时需要）
- Wayland 下从剪贴板读取图片需要 `wl-clipboard`（提供 `wl-paste`）；
  X11 下需要 `xclip`
- 首次安装缺失包时需要访问 MELPA、GNU ELPA 或 NonGNU ELPA

## 启动与安装

直接运行 `emacs`。配置使用 `use-package` 的 `:ensure t`，缺失的包会在首次
启动时从已配置的软件源安装。需要手动刷新软件源时，执行：

```text
M-x package-refresh-contents
```

包安装在 `var/elpa/`，该目录由 `.gitignore` 排除。

## 模块加载顺序

`post-init.el` 按以下顺序加载各模块：

1. `init-theme`：加载内置 `tango-dark` 主题
2. `init-font`：默认字体与中文字体集（霞鹜文楷等宽）
3. `init-sysEnv`：`compile-angel` 与平台环境变量
4. `init-clipboard`：系统剪贴板与 `org-download`
5. `init-file`：`recentf`、`savehist`、`saveplace`、`auto-revert`
6. `init-completion`：Corfu、Cape、Vertico、Marginalia、Orderless、Embark
7. `init-evil`：Evil 及相关扩展
8. `init-multicursor`：`evil-mc` 多光标编辑
9. `init-project`：project.el、项目列表、项目切换与 Evil 项目键位
10. `init-minibuffer`：minibuffer 的 Evil 风格按键
11. `init-visual-line`：`visual-line-mode` 与 `visual-fill-column`
12. `init-org`：Org、Org-roam、Org-roam-ui、Consult 集成
13. `init-latex`：Org 公式预览、AUCTeX/RefTeX/CDLaTeX
14. `init-pdf`：PDF 阅读（`pdf-tools`）、主题跟随与 PDF 按键
15. `init-treesit`：Tree-sitter 自动安装与 major mode remap
16. `init-eglot`：Eglot 通用配置、快捷键和语言服务器注册辅助
17. `init-python`：Python 模式、uv 虚拟环境、basedpyright/pyright 语言服务器
18. `init-c-c++`：C/C++ Tree-sitter 模式、clangd、Makefile/CMake 编辑与 C/C++ 项目根目录
19. `init-vterm`：VTerm 终端、项目级会话与 Evil 集成
20. `init-opencode`：OpenCode、agent-shell、ACP 与 Evil 集成
21. `init-magit`：Magit、Git、Evil Magit 状态与项目入口
22. `init-ui`：`which-key`、`repeat-mode`、`winner-mode`、`ace-window` 与像素滚动
23. `init-desktop`：恢复上次退出时的缓冲区、光标位置和窗口布局

## 会话恢复（Desktop）

`var/init-lisp/init-desktop.el` 使用 Emacs 内置的 `desktop` 包：

- 退出时自动保存打开的**文件缓冲区**、光标位置、窗口和 frame 布局；
- 下次启动时自动恢复，并重新打开上次的文件；
- 桌面文件保存到 `~/.emacs.d/var/desktop/emacs.desktop`，由 `.gitignore` 排除；
- 只保存访问文件的缓冲区；`*Messages*`、`*scratch*`、VTerm、agent-shell
  等临时或进程相关缓冲区不会恢复；
- 如果上次 Emacs 异常退出，`desktop-load-locked-desktop 'check-pid` 会检查
  锁文件对应的进程是否还在，避免无谓的锁提示；
- 在 daemon 模式下只恢复缓冲区，不尝试重建图形 frame。

如果不希望自动恢复，可以在 `init-desktop.el` 中把
`(desktop-save-mode 1)` 改为 `(desktop-save-mode -1)`，或在 `post-init.el`
中删除 `(require 'init-desktop)`。

## 代码补全（Corfu）

`var/init-lisp/init-completion.el` 中，Corfu 负责缓冲区内的补全弹窗，
`completion-at-point-functions`（CAPF）负责提供候选。Eglot、Python 模式和
Cape 都通过 CAPF 接入 Corfu。

### 自动补全

- 在 `prog-mode`、`conf-mode`、`comint-mode` 和 `eshell-mode` 中自动启用；
- `corfu-auto-prefix` 为 2，输入两个字符后自动弹出候选；
- `corfu-auto-trigger` 包含 `.`，输入 `obj.` 后会立即请求成员补全，适合
  Python、LSP 和 Elisp；
- `corfu-auto-delay` 为 0.15 秒，避免每次输入都立即查询后端；
- `corfu-cycle` 为 `t`，可以在候选之间循环；
- `corfu-popupinfo-mode` 显示当前候选的文档；
- `corfu-history-mode` 将最近选择过的候选排在前面，并通过已有的
  `savehist-mode` 跨会话保存；
- `TAB` 仍然保留为手动补全和缩进的后备方式；
- 文本和 Org 缓冲区不会自动弹出候选，仍然使用手动补全，避免写文章时被打断。

补全弹窗打开后：`TAB` 接受当前候选，`RET` 插入候选，`M-n` / `M-p` 或方向键
切换候选，`C-g` 关闭弹窗。

### 补全来源

优先级从高到低：

1. Eglot 的语言服务器补全；
2. 当前 major mode 自带的 CAPF，例如 `python-completion-at-point`；
3. Cape 提供的后备补全：
   - `cape-dabbrev`：当前缓冲区和其他缓冲区中的单词；
   - `cape-file`：文件名；
   - `cape-keyword`：当前语言的关键字；
   - `cape-elisp-block`：Org/Elisp 中的代码块。

`C-c p` 是 Cape 前缀键，例如：

| 快捷键 | 功能 |
| --- | --- |
| `C-c p d` | 手动触发 Dabbrev 补全 |
| `C-c p f` | 手动触发文件名补全 |
| `C-c p k` | 手动触发关键字补全 |
| `C-c p p` | 手动触发普通 `completion-at-point` |

如果不想在某个缓冲区自动补全，可以在该缓冲区执行
`(setq-local corfu-auto nil)`。

## 视觉换行

`var/init-lisp/init-visual-line.el` 使用 `visual-line-mode` 和
`visual-fill-column` 管理视觉行的换行：

- `pre-init.el` 启用 `global-display-fill-column-indicator-mode`；
- `init-visual-line.el` 将 `display-fill-column-indicator-column` 明确设为
  `t`，因此指示线始终使用当前缓冲区的 `fill-column`；
- `visual-fill-column-width` 保持为 `nil`，表示 visual-fill-column 也使用
  同一个缓冲区局部的 `fill-column`。这样换行位置和指示线始终一致；
- `visual-fill-column` 随 `visual-line-mode` 一起启用和关闭；
- 只在 `text-mode` 派生缓冲区（包括 Org 笔记）中启用 `visual-line-mode`。
  编程缓冲区仍保留 minimal-emacs.d 的 `truncate-lines t`，不会把代码行折行；
- 在 `init-evil.el` 中设置了 `evil-respect-visual-line-mode`。在启用
  `visual-line-mode` 的缓冲区中，`j`/`k` 按视觉行移动，`gj`/`gk` 按逻辑行
  移动，避免把一整段软换行文本当成一行而直接跳过；
- 当窗口宽度小于 `fill-column` 时，`fill-column` 会自动收缩到窗口可用宽度，
  使指示线和换行位置都保持在窗口内。窗口重新变宽后恢复原来的 `fill-column`
  （默认 80）。如果同一个缓冲区同时显示在多个窗口中，使用最窄窗口的宽度，
  以保证所有窗口都能显示指示线。

默认 `fill-column` 为 80，因此文本会在第 80 列处换行。各模式可以在启用
`visual-line-mode` 之前设置缓冲区局部的 `fill-column`，指示线和换行位置会使用
同一个值。

## Minibuffer

`var/init-lisp/init-minibuffer.el` 让 minibuffer 在保留 Evil 状态机的同时，拥有
适合命令行输入的按键。`init-evil.el` 中的 `evil-collection-setup-minibuffer`
会把每个新的 minibuffer 置于 Evil 的 insert state，因此 Evil 插入模式的绑定会
覆盖 Emacs 的编辑键（例如 `C-a`、`C-e`、`C-k`、`C-n`、`C-p`）。这些命令在普通
缓冲区中有用，但在单行 minibuffer 中会妨碍输入和候选切换。

配置使用 Evil 的 auxiliary keymap（辅助键位表），只在这些 minibuffer 键位表中
覆盖按键，不改变 Evil 在其它缓冲区中的行为：

| 按键 | 功能 |
| --- | --- |
| `C-j` / `C-n` / `↓` | 选择下一个候选或历史项 |
| `C-k` / `C-p` / `↑` | 选择上一个候选或历史项 |
| `C-h` / `C-l` | 向左 / 向右移动一个字符 |
| `C-a` / `C-e` | 移动到输入开头 / 末尾 |
| `C-u` | `universal-argument` |
| `C-w` | `kill-region` |
| `C-r` | `isearch-backward` |
| `C-y` | `yank` |
| `C-d` | `delete-char` |
| `C-t` | `transpose-chars` |
| `TAB` / `C-i` | 补全；Vertico 中插入当前候选；普通 read-string 中插入 tab |
| `RET` | 接受当前候选并退出 minibuffer |

`C-h` 在 minibuffer 中被改成了向左移动，不再删除字符；删除请继续使用
Backspace（`DEL`）。Evil insert state 原本会把 `C-u`、`C-w`、`C-r`、`C-y`、
`C-d`、`C-t` 替换成适合普通缓冲区的 Vim 命令，这里统一恢复为编辑 minibuffer
时应有的行为。

在 `M-x`、`C-x C-f` 等使用 Vertico 的补全中，`C-j` / `C-k` 直接调用
`vertico-next` / `vertico-previous`，可以用它们在命令或文件列表中上下切换；
没有候选时（例如普通的 `read-string` 提示）则退化为在历史记录中前后移动。
`↓` / `↑` 仍然由 Vertico 处理。

按下 `ESC` 后 minibuffer 进入 Evil 的 normal state，此时 `j` / `k` 同样用于
切换候选，`h` / `l` 左右移动，`0` / `$` 跳到开头 / 末尾，`TAB` 补全或插入
当前候选；按 `i` 返回 insert state，再按一次 `ESC` 取消输入。`C-j` 不再像
Emacs 默认那样直接退出 minibuffer，请使用 `RET` 确认。

Ex 命令行（`:`）和搜索提示（`/`、`?`）使用独立的键位表，配置同样为它们设置
了 `C-j` / `C-k` 的历史导航，以及 `C-h` / `C-e` 的编辑行为。

## 多光标（evil-mc）

`var/init-lisp/init-multicursor.el` 使用 `evil-mc` 提供 Evil 风格的多光标。
它在编程、配置、文本（包括 Org）和 Dired 缓冲区中自动启用，终端、REPL 和其他
特殊缓冲区不会启用。

按键由 `evil-collection` 的 evil-mc 集成提供，使用 `g.` 前缀。该集成会清除
evil-mc 默认的直接按键（`C-n`、`C-p`、`C-t`、`M-n`、`M-p`），从而避免覆盖
Evil 的粘贴历史、`pop-tag-mark` 以及 Eglot 的 `gr` 前缀。

| 快捷键 | 功能 |
| --- | --- |
| `g. n` / `g. N` | 在下一个 / 上一个匹配处添加光标 |
| `g. a` | 在所有匹配处添加光标 |
| `g. C-m` | 在当前位置添加一个光标 |
| `g. o` / `g. O` | 在下一行 / 上一行添加光标 |
| `g. I` / `g. A` | 在可视选区开头 / 结尾添加光标 |
| `g. C-n` / `g. C-S-n` | 跳到下一个 / 上一个匹配，但不添加光标 |
| `g. M-n` / `g. M-N` | 跳到下一个 / 上一个已有光标 |
| `g. C-u` / `g. C-S-u` | 在已有光标之间前后跳过 |
| `g. u` / `g. q` | 撤销最近添加 / 全部光标 |
| `g. C-p` / `g. C-r` | 暂停 / 恢复多光标 |
| `g. 0` / `g. $` | 跳到第一个 / 最后一个光标 |

典型流程：把光标放在一个单词上，按 `g. n` 逐个添加下一个匹配，或按
`g. a` 选中全部匹配；编辑完成后按 `g. q` 清除所有光标。

Dired 中也会启用多光标；Dired 本身是只读缓冲区，如果需要修改多个文件名，
先按 `C-x C-q` 进入 `wdired-mode`，编辑完成后再用 `C-c C-c` 提交。

`g. n` / `g. N` 支持数字前缀。例如：

- `3 g. n`：在当前匹配处开始，连续添加 3 个匹配（当前 + 后两个）；
- `5 g. N`：向反方向连续添加 5 个匹配；
- `3 g. o` / `3 g. O`：在下面 / 上面连续 3 行添加光标。

如果只想标记**当前匹配之后**的若干项，先用 `g. C-n` 跳到下一个匹配，再按
`3 g. n` 即可。

`g. n` / `g. N` 之后还会进入一个临时的重复状态：

| 按键 | 功能 |
| --- | --- |
| `;` | 继续在下一个匹配处添加光标 |
| `,` | 向相反方向添加光标 |

例如按一次 `g. n`，再连续按 `;`，就会逐个标记后续匹配；按任意其他键即可退出
这个重复状态，`;` 恢复为 Evil 默认的重复 `f`/`F`/`t`/`T` 行为。`;` 也支持数字
前缀，例如 `3 ;` 会一次再标记 3 个匹配。

## Evil 集成

配置以 Evil 为主要编辑方式：`evil-mode` 全局启用，`evil-collection-init`
加载各包的 Evil 绑定，`evil-collection-setup-minibuffer` 让 minibuffer 使用
Evil insert state。特殊缓冲区的初始 state 如下：

| 模式 | 初始 state | 说明 |
| --- | --- | --- |
| `pdf-view-mode` | `normal` | PDF 阅读、目录、`pdf-occur` |
| `org-mode` / `org-agenda-mode` / `org-roam` | `normal` | `TAB` / `S-TAB` 由 evil-collection 绑定为 Org 的 cycle |
| `org-capture-mode` | `normal` | evil-collection 的设计；按 `i` 输入，`ZZ`/`ZQ` 完成/取消 |
| `dired-mode` / `wdired-mode` | `normal` | Dired 中启用 `evil-mc`；`wdired` 按 `i` 编辑文件名 |
| `vterm-mode` | `insert` | `ESC` 回 normal，`C-c C-z` 切换 ESC 归属 |
| `agent-shell-mode` | `insert` | `agent-shell-diff-mode` 使用 `emacs` state |
| `magit-mode` 系列 | `normal` | commit message 使用 `insert` |
| `shell-mode` / `eshell-mode` / `comint-mode` | `insert` | 可直接输入命令 |
| `help-mode` / `occur-mode` / `compilation-mode` | `normal` | 只读或导航缓冲区 |

键位约定：

- `C-c` 在 Evil normal/insert state 下都没有被占用，所以 `C-c e`（Eglot）、
  `C-c v`（Python/uv）、`C-c o`（OpenCode）、`C-c p`（Cape）、`C-c P`
  （project.el）等前缀在所有 state 下都可用；
- `C-x p` 是标准 project.el 前缀；`gp` 是 Evil normal state 的别名（Evil 默认
  没有绑定 `gp`，不会冲突）；`C-c P` 可跨 state 使用；
- `gr` 只在 Eglot 管理的缓冲区中是 LSP 前缀；`gd` / `K` / `C-t` 在 Eglot
  缓冲区中分别改为跳转定义 / Eldoc 文档 / 跳回，其他缓冲区保持 Evil 默认；
- `g.` 是 `evil-mc` 多光标前缀，`gc` 是注释操作符，`g;` / `g,` 跳到最近修改处；
- `C-w` 在 normal state 仍是 Evil 的窗口前缀；minibuffer 中已恢复为
  `kill-region`。`C-u` / `C-h` 在普通 insert state 中按 `evil-want-C-u-delete`
  和 `evil-want-C-h-delete` 启用删除行为，minibuffer 中则恢复标准含义；
- `M-o` 是 `ace-window`，会覆盖 Emacs 默认的 `facemenu-keymap`；如果不使用面部
  菜单可以忽略。

OpenCode 缓冲区中 `gp` 被有意改回 project 前缀；粘贴命令使用 `C-c o y`
（`agent-shell-yank-dwim`），因为 Evil 在 insert/normal state 中分别占用了
`C-y`。

## org-download

`org-download` 用于把图片下载或粘贴到 Org 笔记中。配置位于
`var/init-lisp/init-clipboard.el`。

### 图片存放规则

全局变量 `org-download-image-dir` 被有意保持为 `nil`，不在配置中写死图片目录。
图片目录由笔记各子目录下的 `.dir-locals.el` 提供：

```elisp
((org-mode . ((eval . (setq-local org-download-image-dir
                                  (concat "./" (file-name-nondirectory
                                                (directory-file-name default-directory))
                                          "-img"))))))
```

当前笔记根目录是 `~/Notes/`，对应关系为：

| 笔记目录 | 图片目录 |
| --- | --- |
| `~/Notes/notes/permanent/` | `./permanent-img/` |
| `~/Notes/notes/projects/` | `./projects-img/` |
| `~/Notes/notes/reference/` | `./reference-img/` |

由于 `org-download-image-dir` 只在这些目录中作为缓冲区局部变量设置，
Org 文件无论从哪里打开，图片都会留在对应笔记目录旁边，插入的链接也是相对路径，
例如 `[[file:permanent-img/20261026-153000_screenshot.png]]`。

新图片沿用笔记中已有的命名和排版习惯：

- 不再插入 `#+DOWNLOADED` 注释行；
- 文件名使用 `%Y%m%d-%H%M%S_` 时间戳前缀；
- 图片不放在标题名子目录中，直接放在 `<子目录>-img/` 下；
- 链接前插入 `#+ATTR_ORG: :width 400` 和
  `#+ATTR_HTML: :width 80% :align center`，与已有笔记一致。

### 使用 `C-c g` 粘贴剪贴板图片

在 `org-mode` 缓冲区中按 `C-c g`（`org-download-clipboard`）：

1. 从浏览器、截图工具等复制一张图片到系统剪贴板；
2. 在 Org 文件中按 `C-c g`；
3. 图片会保存到当前笔记子目录对应的 `*-img/` 目录，并在光标处插入链接。

Wayland 下该命令通过 `wl-paste -t image/png` 读取图片，所以需要安装
`wl-clipboard`。`org-download` 会延迟到打开 Org 文件时加载，并注册拖放处理。

### 关于 `.dir-locals.el` 中的 `eval`

minimal-emacs.d 在 `init.el` 中设置 `enable-local-eval nil`，默认禁止执行
目录局部变量中的 `eval` 形式，以避免打开不可信文件时执行任意代码。笔记中的
`.dir-locals.el` 需要 `eval` 才能根据当前子目录名计算 `*-img` 目录，
因此 `init-clipboard.el` 添加了一段作用域受限的 advice：

- 仅当目录局部变量来自 `my/notes-directory`（默认 `~/Notes/`）时才临时启用
  `eval`；
- 其它目录仍保持 minimal-emacs.d 的 `enable-local-eval nil`，`eval` 不会执行。

如果笔记根目录发生变化，修改 `init-clipboard.el` 中的 `my/notes-directory`，
或通过 Customize 设置该变量。

## Org Agenda

`C-c a` 打开 Org Agenda，`C-c a g` 进入配置好的 GTD 视图。

- `org-agenda-files` 直接指向 `~/Notes/agenda/` 目录，因此该目录下新增的
  `.org` 文件会自动纳入 Agenda；
- `org-agenda-sticky` 已关闭，再次执行 `C-c a` 会重新生成 Agenda，而不是
  显示第一次生成的旧缓冲区；
- 在 Agenda 中用 `C-c C-t` 切换 TODO 状态后，会自动执行 `org-agenda-redo`，
  让当前视图立即按新状态重新过滤；
- 仍然可以用 `g` 手动刷新当前 Agenda；
- `C-c C-w` 的 refile 目标覆盖 `~/Notes/agenda/` 下的全部 Agenda 文件，
  因此可以在 `inbox.org`、`projects.org`、`habbits.org`、`archive.org` 之间
  相互 refile；
- refile 候选项包含文件路径，便于区分不同文件中的同名标题；
- 状态变化日志写入任务自己的 `:LOGBOOK:` drawer，不会散落在任务标题下方；
- `C-c c t` 创建新的 TODO，写入 `~/Notes/agenda/inbox.org`；该文件通过
  `#+FILETAGS: INBOX` 给新条目继承 `INBOX` 标签；
- `C-c c n` 创建带 `:NOTE:` 标签的笔记。

Agenda 中继承的文件标签会显示为类似 `:INBOX::` 的形式，末尾的双冒号是
Org 用来标记“继承标签”的显示方式，不是重复标签或文件损坏。

## Org-roam capture 模板

`M-x org-roam-capture` 提供以下三个模板：

| 键 | 模板 | 保存位置 |
| --- | --- | --- |
| `p` | project | `~/Notes/notes/projects/` |
| `l` | literature | `~/Notes/notes/reference/` |
| `z` | zettel(permanent) | `~/Notes/notes/permanent/` |

模板使用 `:target` 和 `file+head`，文件名格式为 `%Y%m%d%H%M%S.org`。文件统一
放在现有的 `notes/` 分类子目录中，不会在 `~/Notes/` 顶层创建 `projects/`、
`reference/` 或 `permanent/` 目录。

## LaTeX、Org 公式与 PDF

配置分别位于 `var/init-lisp/init-latex.el`（Org 公式与 LaTeX 编辑）和
`var/init-lisp/init-pdf.el`（PDF 阅读）。

### PDF 阅读

使用 `pdf-tools`，第一次打开 PDF 时才加载。结合 evil-collection 的
`pdf-view` 集成，normal state 下常用键为：

- `j` / `k`：向下 / 向上滚动一行，到页边时继续翻到下一页 / 上一页；
- `C-j` / `C-k`：直接跳到下一页 / 上一页；
- `SPC` / `S-SPC`（或 `C-f` / `C-b`）：向下 / 向上滚动，并可在页边翻页；
- `gg` / `G` 或 `M-<` / `M->`：第一页 / 最后一页；
- `/`：搜索 PDF 文本；`n` / `N`：下一个 / 上一个搜索结果；
- `M-s o`：打开 `pdf-occur` 搜索结果列表；
- `o`：打开目录（outline）；
- `f` / `F`：跟随 PDF 链接 / 执行链接动作；
- `Q`：关闭当前 PDF 缓冲区；
- `z0` / `C-0`：恢复按页面宽度显示；
- `C-=` / `C-+` / `C--`：放大 / 缩小 PDF 页面（不是文本缩放）；
- `P`：适合整页。

PDF 默认按 **页面宽度**（`fit-width`）排版，因此纵向分屏不会因为窗口变矮而把整页
缩小到看不清。`W` / `H` 的 PDF 专用绑定已解除，现在分别是 Evil 的
`evil-forward-WORD-begin` 和 `evil-window-top`；需要整页显示时按 `P`。

PDF 页面颜色会跟随当前 Emacs 主题（`pdf-view-themed-minor-mode`）；切换主题时
已经打开的 PDF 也会刷新。`pdf-tools` 和 Emacs 自带 PDF 阅读器一样，本质上是按页
渲染图像，每个 buffer 同时显示一页；`pdf-view-continuous` 已开启，滚动到页边会
继续翻到下一页，通常不需要为同一份 PDF 打开多个 buffer。如果需要真正的连续多页
并排显示，建议使用外部 PDF 阅读器（如 Zathura/Okular）。

### Org 公式预览图片缓存

`org-latex-preview` 仍然需要在磁盘上生成预览图片。配置把预览图片集中到：

```text
~/.emacs.d/var/ltximg/<emacs-pid>/
```

不会在 `~/Notes/` 下创建 `ltximg/` 目录。每个 Emacs 会话使用独立的 PID
子目录；启动时清理 PID 已经退出的会话留下的缓存，退出时删除当前会话的缓存。
多个 Emacs 同时运行时不会互相删除正在使用的预览图。HTML/LaTeX 导出的图片不受
这个预览缓存影响。

### Org 公式

- `org-fragtog-mode`：光标离开公式时自动渲染，进入公式时显示源码；
- `C-c C-x C-l`：手动切换当前公式 / 当前节的预览；
- `org-cdlatex-mode` 与 `cdlatex`：在 Org 公式中快速输入数学符号、上下标、
  分式和环境。`org-cdlatex-mode` 会把 `'`、`^`、`_`、`` ` `` 等键接管为
  数学输入辅助，离开公式后恢复普通编辑。
- 如果系统的 TeX Live 缺少 `ulem.sty`，配置会自动从
  `org-latex-default-packages-alist` 中移除 `ulem`，避免公式预览报
  “File ...dvi wasn't produced”。

### LaTeX 文件

- 使用 AUCTeX 编辑 `.tex` 文件；
- 默认引擎为 XeLaTeX（`TeX-engine 'xetex`），适合中文文档；
- `C-c C-c`：编译；
- `C-c C-v`：在 pdf-tools 中查看 PDF；
- `C-c C-e` / `C-c C-s` / `C-c C-m`：插入环境 / 章节 / 宏；
- `reftex-mode` 提供引用、交叉引用和标签补全；
- `cdlatex-mode` 提供数学输入辅助；
- `TeX-source-correlate-mode` 与 SyncTeX 已启用，可在源码和 PDF 之间跳转。

如果项目需要 pdfLaTeX 或 LuaLaTeX，只需把 `init-latex.el` 中的
`TeX-engine` 改为 `'default` 或 `'luatex`。

## 项目（project.el）

`var/init-lisp/init-project.el` 配置 project.el，并让项目命令、Consult 和
Eglot 使用一致的项目根目录。

### 项目设置

- 项目列表保存在 `~/.emacs.d/var/projects.eld`；打开本地项目文件时会自动把
  项目加入列表，远程文件会跳过；
- `C-x p` 使用标准的 project 前缀；Evil normal state 没有占用 `C-x`，所以
  原生绑定可以直接使用；
- Evil normal state 额外绑定 `gp` 到同一个项目前缀，`C-c P` 是跨 state 的
  别名；
- `C-x p p` 切换项目后，dispatch 菜单中的 `b` 使用 `consult-project-buffer`，
  与 `init-completion.el` 中的 `C-x p b` 保持一致；
- `project-switch-use-entire-map` 为 `t`，`project-prefix-map` 中的全部按键
  在 dispatch 菜单中都可用；
- 每个项目使用独立的编译缓冲区，mode line 显示本地项目名；
- `project-kill-buffers-display-buffer-list` 为 `t`，删除项目缓冲区前会先
  显示将要删除的缓冲区。

Python 的 `pyproject.toml` / `uv.lock` 会在 `init-python.el` 中加入
`project-vc-extra-root-markers`，因此项目命令和 Eglot 都能在 monorepo 子项目
中找到正确的根目录；`.venv/`、`__pycache__/` 等目录也被排除在项目文件搜索
之外。

C/C++ 的 `.clangd`、`CMakeLists.txt`、`Makefile` 等标记由
`init-c-c++.el` 加入同一个列表；`build/`、`out/`、`cmake-build-*/`、
`CMakeFiles/` 等构建目录会从项目搜索中排除。

### 项目快捷键

| 快捷键 | 功能 |
| --- | --- |
| `C-x p p` | 切换项目（`project-switch-project`） |
| `C-x p f` | 在当前项目中查找文件 |
| `C-x p b` | 使用 Consult 切换当前项目的缓冲区 |
| `C-x p g` | 在当前项目中搜索正则表达式 |
| `C-x p d` | 查找目录 |
| `C-x p s` | 在当前项目中启动 shell |
| `C-x p e` | 在当前项目中启动 Eshell |
| `C-x p m` | 打开当前项目的 Magit status |
| `C-x p c` | 编译项目 |
| `C-x p k` | 删除项目相关的缓冲区 |
| `C-x p C-b` | 列出项目缓冲区 |
| `C-x p C-s` | 保存项目中的缓冲区 |
| `C-x p R` | 记住某个目录下的项目（前缀参数递归查找） |
| `C-x p X` | 遗忘某个项目 |
| `C-x p Z` | 清理已失效的项目 |
| `gp` | Evil normal state 的项目前缀，例如 `gp f`、`gp p` |
| `C-c P` | 任意 state 下可用的项目前缀 |

在 `C-x p p` 的 dispatch 菜单中按 `t` 可以直接打开当前项目的 VTerm，
按 `m` 打开 Magit status。

## Eglot 与语言服务器

Eglot 的通用配置在 `var/init-lisp/init-eglot.el` 中，具体语言只在自己的
`init-<language>.el` 中注册服务器。这样添加新语言时不需要修改 Eglot 的通用
逻辑。

### 注册一个新语言

以 Rust 为例，新建 `var/init-rust.el`：

```elisp
(require 'init-eglot)

(my/eglot-register '(rust-mode rust-ts-mode)
  :server '("rust-analyzer"))
```

然后在 `post-init.el` 中加上 `(require 'init-rust)` 即可。`my/eglot-register`
默认会把 `eglot-ensure` 加到这些模式的 hook 中，打开对应文件时自动启动
Eglot；传入 `:auto-start nil` 则改为手动执行 `M-x eglot`。

`:server` 的取值与 `eglot-server-programs` 的 CDR 相同：可以是程序名、程序与
参数组成的列表，或一个返回启动命令的函数。`my/eglot-contact-fallback` 提供
了“优先使用本机程序，找不到时用 `uvx` 运行”的选择方式：

```elisp
(my/eglot-register '(python-mode python-ts-mode)
  :server (my/eglot-contact-fallback
           '(("basedpyright-langserver" "--stdio")
             (:uvx "basedpyright" "basedpyright-langserver" "--stdio"))))
```

### 通用设置

- `eglot-autoshutdown`：最后一个由该服务器管理的缓冲区关闭后自动关闭服务器；
- `eglot-sync-connect` 为 `nil`：打开文件时不等服务器启动完成，首次通过
  `uvx` 下载服务器时不会卡住界面；
- `eglot-extend-to-xref`：允许 Eglot 管理通过 xref 跳转到项目外的文件；
- `eglot-send-changes-idle-time` 为 0.4 秒，减少输入时发送给服务器的变更通知。

Eglot 管理缓冲区时会自动启用 Flymake、Eldoc 和补全，并与已配置的 Corfu、
Consult（`consult-xref`、`consult-flymake`）协同工作。

### Evil 集成

`C-c e` 是全局前缀，在 Evil 的任何 state 下都可以使用。除此之外，
`init-eglot.el` 只在 Eglot 管理的缓冲区中为 Evil normal state 补充了
Vim/LSP 风格的绑定，不会影响其他模式的按键：

| 快捷键 | 功能 |
| --- | --- |
| `gd` | 跳转到定义 |
| `gD` | 在另一个窗口跳转到定义 |
| `g5` | 在另一个 frame 跳转到定义 |
| `K` | 在 Eldoc 缓冲区查看文档 |
| `C-t` | 跳回跳转前的位置 |
| `gr` | Eglot/LSP 前缀键 |

`gr` 前缀：

| 快捷键 | 功能 |
| --- | --- |
| `grn` | 重命名符号 |
| `gra` | 代码操作 |
| `gr.` | 快速修复 |
| `grc` | 整理导入 |
| `grf` / `grF` | 格式化区域 / 缓冲区 |
| `grd` / `grD` | 跳转到定义 / 在另一个窗口跳转 |
| `grr` | 查找引用 |
| `gri` / `grt` | 跳转到实现 / 类型定义 |
| `grh` | 查看文档 |

### `C-c e` 快捷键

| 快捷键 | 功能 |
| --- | --- |
| `C-c e a` | 代码操作（code actions） |
| `C-c e .` | 快速修复 |
| `C-c e o` | 整理导入 |
| `C-c e r` | 重命名符号 |
| `C-c e f` / `C-c e F` | 格式化区域 / 缓冲区（需要服务器支持） |
| `C-c e d` / `C-c e D` | 跳转到定义 / 查找引用 |
| `C-c e s` | 在工作区中搜索符号 |
| `C-c e b` / `C-c e B` | 跳转后退 / 前进 |
| `C-c e h` | 在 Eldoc 缓冲区查看文档 |
| `C-c e c` / `C-c e y` | 调用层级 / 类型层级 |
| `C-c e i` / `C-c e t` | 切换 inlay hints / semantic tokens |
| `C-c e e` | 打开 Eglot 事件日志 |
| `C-c e l` | 列出当前 Eglot 连接 |
| `C-c e R` | 重新连接服务器 |
| `C-c e q` / `C-c e Q` | 关闭当前 / 全部服务器 |

## Python 与 uv

`var/init-lisp/init-python.el` 负责 Python 模式、uv 虚拟环境和语言服务器。
它通过 `my/treesit-enable` 把 `.py` 文件映射到 `python-ts-mode`，并由
`init-treesit.el` 在 Emacs 31 上自动安装缺少的语法。

### Tree-sitter 语法自动安装

`var/init-lisp/init-treesit.el` 将 `treesit-auto-install-grammar` 设为
`always`。第一次打开 `.py` 文件时，Emacs 会自动从 tree-sitter-python 仓库
下载并编译语法，安装到 `~/.emacs.d/var/tree-sitter/`；之后直接加载，不会重复
安装。安装过程需要 `git`、C 编译器以及网络连接；因为安装是同步的，第一次打开
Python 文件可能会有短暂停顿。

如果不想自动下载，可以把 `my/treesit-auto-install` 设为 `nil`，然后手动执行
`M-x treesit-install-language-grammar RET python`。Emacs 31 之前的版本没有
`treesit-auto-install-grammar`，配置只会在语法已经安装后启用
`python-ts-mode`，因此仍需要手动安装语法。

添加其他语言时，在对应的 `init-<language>.el` 中调用：

```elisp
(my/treesit-enable 'rust-mode 'rust-ts-mode 'rust)
```

### 语言服务器

Python 默认使用 basedpyright，找不到时使用 pyright。查找顺序为：

1. 项目虚拟环境中的 `basedpyright-langserver` / `pyright-langserver`
   （`.venv/bin`）；
2. `exec-path` 中的同名程序；
3. 通过 `uvx` 临时运行（`uvx --from basedpyright basedpyright-langserver --stdio`）。

因此不安装任何 Python 包也可以直接打开 `.py` 文件：第一次启动 Eglot 时
`uvx` 会下载 basedpyright，之后使用 uv 的缓存。需要固定版本或在 CI/离线环境
中使用时，把服务器装进项目即可：

```text
uv add --dev basedpyright
```

下一次启动 Eglot 时会优先使用 `.venv/bin/basedpyright-langserver`。修改依赖后
如果服务器已经在运行，用 `C-c e R` 重启连接。

basedpyright 负责补全、跳转、类型检查、诊断、重命名和代码操作，但它不提供
格式化。`C-c e f` / `C-c e F` 只有在语言服务器声明支持格式化时才有效；
需要 Ruff 格式化时可以在项目中添加 Ruff，并用 `apheleia` 或 `ruff format`
单独处理。

### 虚拟环境与项目根目录

Python 项目根目录由最近的 `pyproject.toml` 或 `uv.lock` 决定。这两个文件名会被
加入 `project-vc-extra-root-markers`，因此 Eglot、`consult-ripgrep` 等基于
project.el 的命令在 monorepo 的子项目中也会使用正确的根目录。

打开 Python 文件时，`my/python-setup` 会查找虚拟环境：

1. 如果设置了 `UV_PROJECT_ENVIRONMENT`，优先使用它（相对路径按项目根目录解析）；
2. 否则使用项目根目录下的 `.venv`。

找到后，当前缓冲区会设置：

- `python-shell-virtualenv-root`：Python shell 使用该虚拟环境；
- `python-shell-interpreter`：指向 `.venv/bin/python`（Windows 为
  `Scripts/python.exe`）；
- `python-shell-dedicated` 为 `project`：每个项目使用独立的 Python shell，
  不会把不同项目的依赖混在一起。

如果项目使用非标准的虚拟环境路径，basedpyright 不会读取
`UV_PROJECT_ENVIRONMENT`。这种情况下可以在项目的 `pyproject.toml` 中配置
`[tool.basedpyright]`，或者在该项目的 `.dir-locals.el` 中设置
`eglot-workspace-configuration` 的 `:python (:pythonPath ".../bin/python")`。

### `C-c v` 快捷键

| 快捷键 | 功能 |
| --- | --- |
| `C-c v s` | `uv sync`：创建/更新 `.venv` 并安装依赖 |
| `C-c v l` | `uv lock`：更新锁文件 |
| `C-c v v` | `uv venv`：创建虚拟环境 |
| `C-c v a` | `uv add`：添加依赖 |
| `C-c v r` | `uv run`：在项目环境中执行命令（如 `pytest -q`） |
| `C-c v p` | 启动 Python shell（`run-python`） |

这些 uv 命令在项目根目录下异步执行，输出显示在 `*uv*` 缓冲区。刚执行
`uv sync` 创建 `.venv` 时，Eglot 可能已经用系统 Python 启动了服务器；执行完
后用 `C-c e R` 重启连接，让 basedpyright 重新发现虚拟环境。

## C/C++ 与构建文件

`var/init-lisp/init-c-c++.el` 负责 C/C++ 的 Tree-sitter 模式、clangd 语言服务器，
以及 Makefile、CMake 和 clang 配置文件的基础编辑支持。调试没有集成到 Emacs 中，
可以直接使用 gdb。

### 编辑模式

- `.c` 使用 `c-ts-mode`；
- `.h` 使用 `c-or-c++-ts-mode`，根据文件内容判断是 C 还是 C++；
- `.cpp`、`.cc`、`.cxx`、`.hpp`、`.hh`、`.hxx` 使用 `c++-ts-mode`；
- 额外的 C++ 扩展名 `.C`、`.H`、`.ipp`、`.tpp`、`.inl`、`.ixx`、`.cppm`、
  `.ccm`、`.cxxm` 也映射到 `c++-ts-mode`；
- `Makefile`、`makefile`、`GNUmakefile`、`*.mk`、`*.make`、`*.mak`、`Kbuild`
  使用 `makefile-gmake-mode`；
- `Makefile.am` 使用 `makefile-automake-mode`，`Makefile.in` 使用
  `makefile-mode`；
- `CMakeLists.txt` 和 `*.cmake` 使用 `cmake-ts-mode`；
- `meson.build` 和 `meson_options.txt` 使用 `meson-mode`；
- `compile_commands.json`、`CMakePresets.json` 和 `CMakeUserPresets.json` 使用
  `json-ts-mode`；
- `.clangd`、`.clang-format`、`.clang-tidy` 使用 `yaml-ts-mode`。

这些模式大多属于 `prog-mode` 或从它派生，因此会自动启用 Corfu 补全；YAML
使用 `text-mode`，保持手动补全。Cape 的 `C-c p` 前缀在这些缓冲区中都可以使用。
Evil 的 `gc` 注释操作、`C-c e` Eglot 前缀和 Eglot 缓冲区中的 `gr` 前缀都同样
适用于 C/C++。

Makefile 中继续使用真正的 TAB 作为 recipe 缩进；CMake、YAML 和 JSON 文件则
使用空格缩进。C/C++ 使用 Linux 缩进风格，缩进宽度为 4 个空格，并关闭 TAB
缩进。

### clangd

打开 C/C++ 文件时，Eglot 会自动启动 clangd：

```text
clangd --background-index --clang-tidy
```

可以用 `my/c-c++-clangd-args` 自定义参数，例如关闭 clang-tidy：

```elisp
(setq my/c-c++-clangd-args '("--background-index"))
```

clangd 会从项目根目录向上查找 `compile_commands.json`、`compile_flags.txt` 和
`.clangd`。为了让 clangd 获得准确的 include 路径和编译宏，建议为项目生成
`compile_commands.json`：

```text
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

Makefile 项目可以使用 `bear -- make` 或 `compiledb make` 生成。更新编译数据库后，
用 `C-c e R` 重启当前 Eglot 连接。

C/C++ 项目根目录由最近的 `.clangd`、`CMakeLists.txt`、`meson.build`、
`configure.ac`、`configure.in` 或 `Makefile.am` 决定；这些标记会加入
`project-vc-extra-root-markers`。只有 `Makefile` / `GNUmakefile` 的项目使用
`my/c-c++-project-find`：在没有 VC 根目录时，它会选择最上层的 Makefile 所在
目录，避免子目录 Makefile 把项目切碎。`build/`、`out/`、`cmake-build-*/`、
`CMakeFiles/` 和 `.cache/` 会从项目文件搜索中排除。`compile_commands.json`
经常位于 `build/` 中，因此它不是项目根目录标记；clangd 会自行查找它。

### 快捷键

没有新增 C/C++ 专用前缀；沿用已有的通用按键：

| 快捷键 | 功能 |
| --- | --- |
| `C-c e` | Eglot 全局前缀（代码操作、重命名、定义、引用等） |
| `gr` | Eglot 缓冲区中 Evil normal state 的 LSP 前缀 |
| `gd` / `K` / `C-t` | 定义 / 文档 / 跳回 |
| `C-c p` | Cape 补全前缀 |
| `C-x p` / `gp` / `C-c P` | project.el 项目前缀 |

`clangd` 不提供调试功能；调试请在 Emacs 外部使用 gdb。

## VTerm 终端

`var/init-lisp/init-vterm.el` 配置 VTerm 终端。VTerm 使用 libvterm 的动态模块，
适合运行 `htop`、`ncurses`、SSH 等需要完整终端能力的程序。

### 打开终端

| 快捷键 | 功能 |
| --- | --- |
| `C-c t` | 在当前项目根目录打开 VTerm；没有项目时使用当前目录 |
| `C-c T` | 在另一个窗口打开 VTerm |

在 `C-x p p` 的项目 dispatch 菜单中按 `t` 也可以打开当前项目的 VTerm。

每个项目使用独立的 VTerm 缓冲区，例如 `*vterm:my-project*`；没有项目时使用
`*vterm*`。默认会复用当前项目的终端。带数字前缀参数可以切换或创建编号会话：

```text
C-u 2 C-c t
```

### 终端设置

- shell 使用环境变量 `SHELL`，当前环境为 `/usr/bin/bash`；
- 滚动历史上限为 100000 行；
- shell 退出后自动关闭对应缓冲区；
- 启用 `vterm-copy-mode-remove-fake-newlines`，方便在复制模式中搜索和复制；
- 首次运行时会自动编译 `vterm-module`。编译需要 `cmake` 和 `libvterm`；Arch
  Linux 上可以执行：

```text
sudo pacman -S cmake libvterm
```

或者只安装用户级 CMake：

```text
uv tool install cmake
```

### Evil 集成

VTerm 的 Evil 绑定来自 `evil-collection`：

- 新建终端默认进入 Evil insert state，可以直接输入命令；
- 按 `ESC` 回到 Evil normal state，可使用 `h`/`j`/`k`/`l` 浏览终端历史，
  以及 `i`/`a`/`I`/`A` 回到输入状态；
- normal state 下的 `p`、`P`、`d`、`D`、`x`、`X`、`c`、`C`、`s`、`S`、`u`
  等操作会尽量限制在终端当前命令行内；
- `C-c C-z` 切换 ESC 的归属：
  - 默认由 Evil 处理，用于回到 normal state；
  - 切换后 ESC 会直接发送给终端，适合在 VTerm 中运行 Vim、SSH 或另一个
    Emacs；
- `C-c C-t` 进入/退出 `vterm-copy-mode`，用于搜索和复制终端输出；
- `C-c C-l` 清除滚动历史；
- `C-c C-n` / `C-c C-p` 跳到下一个 / 上一个 shell prompt；
- `C-c C-r` 重置终端光标位置。

VTerm 的复制模式、提示符跳转和目录跟踪可以通过 shell 侧配置增强；不配置时
仍可正常作为交互式终端使用。

## OpenCode 与 agent-shell

`var/init-lisp/init-opencode.el` 通过 `agent-shell` 的 ACP 后端集成 OpenCode：

```text
opencode acp
```

它不是把 OpenCode TUI 放进 VTerm，而是使用原生 Emacs 缓冲区，因此可以和
Evil、Corfu、Vertico、Consult、project.el、diff-mode 等现有配置一起工作。

### 前置条件

先安装并登录 OpenCode：

```text
opencode auth login
```

`agent-shell` 来自 MELPA，配置会自动安装。OpenCode 需要位于 `PATH` 中；
`init-sysEnv.el` 的 Linux GUI PATH 同步会处理桌面启动的情况。

### 快捷键

| 快捷键 | 功能 |
| --- | --- |
| `C-c o o` | 在当前项目启动或复用 OpenCode |
| `C-c o n` | 强制启动新的 OpenCode 会话 |
| `C-c o s` | 把当前选区发送到 OpenCode |
| `C-c o d` | 发送当前区域或光标处的错误（DWIM） |
| `C-c o t` | 显示/隐藏 OpenCode 缓冲区 |

在 OpenCode shell 内部：

| 快捷键 | 功能 |
| --- | --- |
| `RET` | 提交 prompt |
| `M-J` | 插入换行，不提交 |
| `TAB` | 在三角形/标题上展开或折叠该段；普通位置跳到下一项 |
| `C-c C-c` | 中断当前请求 |
| `C-c C-r` | 发送当前选区 |
| `C-c C-v` | 选择模型 |
| `C-c C-m` | 选择 session mode |
| `C-c C-t` | 选择 thought level |
| `C-c C-o` | 切换到其他 agent-shell 缓冲区（`agent-shell-other-buffer`） |
| `C-c o y` | 粘贴；剪贴板是图片时改为插入图片文件上下文 |
| `gp ...` | Evil normal state 下的 project.el 前缀，如 `gp f`、`gp p` |

OpenCode 缓冲区默认进入 Evil insert state；normal state 下也可以直接按 `RET`
提交。Agent 修改文件时产生的 diff 缓冲区默认进入 Evil Emacs state，方便直接
使用 `y`、`n`、`p`、`q` 等按键。

`evil-collection` 默认把 agent-shell 缓冲区的 `gp` 绑定为
`agent-shell-yank-dwim`，会遮住全局的 `gp` → `project-prefix-map`；在 kill
ring 为空时还会报 `Kill ring is empty`。本配置在 `init-opencode.el` 中把
normal state 的 `gp` 改回 project 前缀，因此 OpenCode 缓冲区里的 `gp f`、
`gp p`、`gp b` 等与普通缓冲区一致。由于 Evil 在 insert/normal state 中分别
占用了 `C-y`（复制上一行 / 向上滚动），粘贴命令统一放在 `C-c o y`
（`agent-shell-yank-dwim`）。

### 斜杠命令

这里的 OpenCode 是 `agent-shell` 通过 `opencode acp` 连接的 ACP 客户端，而不是
OpenCode 的 TUI，因此 `/` 补全只包含：

- 当前目录 `.opencode/commands/` 下的自定义命令（以及全局
  `~/.config/opencode/commands/`）；
- ACP 下发的内置命令 `compact`。

TUI 自己的 `/new`、`/sessions`、`/models`、`/undo` 等命令不会出现在这里；需要
它们时请直接运行 `opencode`。`/continue` 也不是 OpenCode 内置命令，可以自己
定义：

```md
<!-- .opencode/commands/continue.md -->
---
description: Continue the current task
---

Continue from where you left off. Do not repeat completed work.
```

保存后重新开始会话，ACP 会通过 `available_commands_update` 下发该命令，
agent-shell 的 `/` 补全即可使用 `/continue`。

### 恢复会话与历史

`agent-shell` 默认只恢复 session 标题，不显示历史对话。本配置把
`agent-shell-session-restore-verbosity` 设为 `'last`：恢复 session 时会回放
最后一个 prompt turn（用户问题 + agent 回复）；更早的内容会显示为 truncated
history。需要完整对话时把它改为 `'full`，只显示标题则用 `'minimal`。

- `C-c o n`：创建新的 agent shell，并列出当前项目的已有 session 供选择；
- 选择已有 session 后，会恢复完整对话历史；
- `C-c o o`：如果当前项目已经有 OpenCode buffer，通常只是切换显示；
- `M-x agent-shell-resume-session`：已知 session ID 时直接恢复；
- `M-x agent-shell-copy-session-id`：复制当前 session ID。

如果希望自动恢复最近一次会话，可以额外设置：

```elisp
(setq agent-shell-session-strategy 'latest)
```

这样 `C-c o n` 会直接恢复最近 session，不再列出选择。

### 项目、上下文与存储

- OpenCode 从当前项目根目录启动；
- `agent-shell` 会自动带上当前文件、行号、选区和错误上下文；
- 会话记录和截图保存在 `~/.emacs.d/var/agent-shell/`，全局历史保存在
  `~/.emacs.d/var/agent/`，不会在项目里创建 `.agent-shell/`；
- `agent-shell` 的补全使用 comint，因此 Corfu 自动补全会在 OpenCode shell 中
  生效；模型和模式选择使用 `completing-read`，因此复用 Vertico/Consult。
- VTerm 配置与 OpenCode 配置相互独立，可以同时使用。

如需固定默认模型，可以在启动前设置：

```elisp
(setq agent-shell-opencode-default-model-id "deepseek/deepseek-flash")
```

## Git 与 Magit

`var/init-lisp/init-magit.el` 配置 Magit，并把它接入现有的 Evil、project.el、
diff-mode 和 OpenCode 工作流。

| 快捷键 | 功能 |
| --- | --- |
| `C-x g` | 打开 Magit status |
| `C-x p m` | 打开当前项目的 Magit status |
| `C-t` / `\` | 在 Magit 缓冲区中切换 Evil text mode，方便自由移动和复制 |

在 Magit 缓冲区中，Evil 绑定由 `evil-collection` 提供：

- status / log / diff / process 等缓冲区默认进入 Evil normal state；
- `s` / `u` 暂存 / 取消暂存，`c` 提交，`P` 推送，`f` 拉取，`l` 查看日志，
  `d` 查看 diff，`q` 退出；
- commit message 缓冲区默认进入 Evil insert state；
- `C-t` 或 `\` 可以临时切换到 text mode，使用完整的 Evil 移动和复制操作。

Magit 与项目集成：

- `C-x p m` 是 project.el 中的 Magit 入口；
- `C-x p v` 仍然保留为 `vc-dir`；
- Magit status 使用当前窗口，diff 和 process 缓冲区使用其他窗口；
- `magit-auto-revert-mode` 已启用，Git 操作后文件缓冲区会自动刷新。

和 OpenCode 的配合：

- 在 Magit status/diff 中选择区域后，可以用 `C-c o s` 把区域发送给 OpenCode；
- 也可以用 `C-c o d` 发送当前区域或光标处的上下文（DWIM）。

## 界面与窗口

`var/init-lisp/init-ui.el` 启用以下界面功能：

- `which-key`：显示 `C-c`、`C-x`、`gp`、`gr` 等前缀的后续按键；
- `repeat-mode`：重复执行 `next-error`、`other-window` 等命令；
- `winner-mode`：撤销/重做窗口布局变化，可用 `C-c <left>` / `C-c <right>`；
- `ace-window`：按 `M-o` 给窗口加字母标签，按标签即可跳转；只有两个窗口时
  直接切到另一个；标签字母同时显示在各自窗口的 mode line 上；
- `pixel-scroll-precision-mode`：在图形界面中启用平滑像素滚动；
- `C-=` / `C--` / `C-0`：全局放大 / 缩小 / 重置缓冲区文字大小
  （`text-scale-increase` / `text-scale-decrease` / `text-scale-set 0`）。

### 字体

`var/init-lisp/init-font.el` 把默认字体和中文字体统一为
**LXGW WenKai Mono GB Screen**（霞鹜文楷等宽 GB 屏幕阅读版）：

- 英文和中文字符使用同一个字体家族，不会出现中英文风格割裂；
- 该字体是等宽的，并且宽度比为 1:2：一个英文占 0.5em，一个汉字占 1em，
  所以两个英文字符正好等于一个汉字的宽度，表格、注释和对齐都不会错位；
- 默认字号为 13pt（`my/font-height` 可调）；LXGW 在相同字号下的
  x-height 比 JetBrains Maple Mono 小，所以略微放大可以保持可读性；
- `han` 和 `cjk-misc` 字体集也显式指向该字体，避免中文回退到其他字体；
- 修改 `my/font-family` 或 `my/font-height` 即可换字体或调整字号。

## 常用快捷键

完整的快捷键速查表见 [SHORTCUTS.md](SHORTCUTS.md)。

| 快捷键 | 功能 |
| --- | --- |
| `C-c a` | Org Agenda |
| `C-c c` | Org Capture |
| `C-c l` | 保存 Org 链接 |
| `C-c g` | 将剪贴板图片插入当前 Org 文件（`org-download-clipboard`） |
| `C-c n f` | 查找 Org-roam 节点 |
| `C-c n i` | 插入 Org-roam 节点链接 |
| `C-c n l` | 打开/关闭 Org-roam 侧边缓冲区 |
| `C-c n d` | Org-roam dailies 前缀键 |
| `C-c n u` | 打开 Org-roam-ui |
| `C-c n b` | 查看当前节点的反向链接 |
| `C-c n s` | 搜索 Org-roam 笔记 |
| `C-x p` | project.el 前缀键（项目切换、查找文件、搜索等） |
| `C-x g` | 打开 Magit status |
| `C-x p m` | 打开当前项目的 Magit status |
| `gp` / `C-c P` | Evil normal state / 任意 state 的项目前缀（OpenCode 缓冲区同样可用） |
| `gr` | Eglot 管理缓冲区中 Evil normal state 的 LSP 前缀 |
| `C-c e` | Eglot 全局前缀键（代码操作、重命名、格式化、跳转等） |
| `C-c v` | uv / Python 前缀键（sync、lock、add、run、Python shell） |
| `C-c t` / `C-c T` | 在当前项目 / 另一个窗口打开 VTerm 终端 |
| `C-c o` | OpenCode 前缀（`C-c o o` 启动/复用，`C-c o n` 新会话） |

## 版本控制

仓库只跟踪配置文件。以下内容由 `.gitignore` 排除：

- `var/elpa/`：安装的包
- `var/eln-cache/`、`eln-cache/`、`*.elc`、`*.eln`：编译产物
- `var/tree-sitter/`：自动编译的 Tree-sitter 语法库
- `var/autosave/`、`var/backup/`、`var/history`、`var/recentf.eld`、
  `var/saveplace`、`var/bookmarks`、`var/abbrev_defs`
- `var/projects.eld` 及 `var/*.eld`：project.el 等保存的运行时数据
- `var/.org-id-locations`、`var/tramp`、`var/tramp-autosave/`：Org ID 与 Tramp 数据
- `var/agent-shell/`、`var/agent/`：OpenCode/agent-shell 的会话记录、截图和全局历史
- `var/desktop/`：Desktop 会话文件（缓冲区列表和窗口布局）
- `var/org-roam.db`：从笔记自动生成的数据库
- `var/ltximg/`：Org 公式预览缓存
- `var/eshell/`、`var/transient/`、`var/url/`、`var/cache/`：其他运行时数据
- 顶层遗留的 `elpa/` 目录
