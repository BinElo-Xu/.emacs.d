# Emacs 配置

这份配置以 [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d)
1.5.2 为起点，并遵循它的设计：上游的 `early-init.el`、`init.el` 保持原样，
个人配置写在 `pre-init.el`、`post-init.el` 和 `var/init-lisp/` 中。

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
│   │   ├── init-sysEnv.el
│   │   ├── init-clipboard.el   # 剪贴板、org-download
│   │   ├── init-file.el
│   │   ├── init-completion.el
│   │   ├── init-evil.el
│   │   ├── init-project.el      # project.el、项目列表与 Evil 项目键位
│   │   ├── init-minibuffer.el   # minibuffer 的 Evil 风格按键
│   │   ├── init-visual-line.el  # 视觉行换行
│   │   ├── init-org.el
│   │   ├── init-treesit.el      # Tree-sitter 自动安装与 mode remap
│   │   ├── init-eglot.el        # Eglot 通用配置与语言服务器注册辅助
│   │   └── init-python.el       # Python、uv 与 Eglot 的 Python 集成
│   ├── elpa/               # 安装的包（不纳入 Git）
│   ├── eln-cache/          # 原生编译缓存（不纳入 Git）
│   ├── tree-sitter/        # Tree-sitter 语法库（不纳入 Git）
│   ├── autosave/           # 自动保存文件（不纳入 Git）
│   ├── org-roam.db         # Org-roam 数据库（不纳入 Git）
│   └── ...                 # 历史、recentf、saveplace 等运行时数据
├── SHORTCUTS.md            # 快捷键速查表
└── README.md
```

`pre-early-init.el` 把 `user-emacs-directory` 设为 `~/.emacs.d/var/`，
因此包目录、历史记录、缓存和自动保存文件都集中在 `var/` 中，仓库根目录只保留
配置文件。

## 环境要求

- Emacs 29.1 或更新版本（当前验证版本：31.1）
- Linux
- `uv`（用于创建 Python 虚拟环境，以及在未安装语言服务器时通过 `uvx` 启动 basedpyright）
- Git 和 C 编译器（首次自动编译 Tree-sitter 语法时需要）
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
2. `init-sysEnv`：`compile-angel` 与平台环境变量
3. `init-clipboard`：系统剪贴板与 `org-download`
4. `init-file`：`recentf`、`savehist`、`saveplace`、`auto-revert`
5. `init-completion`：Corfu、Cape、Vertico、Marginalia、Orderless、Embark
6. `init-evil`：Evil 及相关扩展
7. `init-project`：project.el、项目列表、项目切换与 Evil 项目键位
8. `init-minibuffer`：minibuffer 的 Evil 风格按键
9. `init-visual-line`：`visual-line-mode` 与 `visual-fill-column`
10. `init-org`：Org、Org-roam、Org-roam-ui、Consult 集成
11. `init-treesit`：Tree-sitter 自动安装与 major mode remap
12. `init-eglot`：Eglot 通用配置、快捷键和语言服务器注册辅助
13. `init-python`：Python 模式、uv 虚拟环境、basedpyright/pyright 语言服务器

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
| `RET` | 接受当前候选并退出 minibuffer |

`C-h` 在 minibuffer 中被改成了向左移动，不再删除字符；删除请继续使用
Backspace（`DEL`）。

在 `M-x`、`C-x C-f` 等使用 Vertico 的补全中，`C-j` / `C-k` 直接调用
`vertico-next` / `vertico-previous`，可以用它们在命令或文件列表中上下切换；
没有候选时（例如普通的 `read-string` 提示）则退化为在历史记录中前后移动。
`↓` / `↑` 仍然由 Vertico 处理。

按下 `ESC` 后 minibuffer 进入 Evil 的 normal state，此时 `j` / `k` 同样用于
切换候选，`h` / `l` 左右移动，`0` / `$` 跳到开头 / 末尾；按 `i` 返回 insert
state，再按一次 `ESC` 取消输入。`C-j` 不再像 Emacs 默认那样直接退出
minibuffer，请使用 `RET` 确认。

Ex 命令行（`:`）和搜索提示（`/`、`?`）使用独立的键位表，配置同样为它们设置
了 `C-j` / `C-k` 的历史导航，以及 `C-h` / `C-e` 的编辑行为。

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
| `C-x p c` | 编译项目 |
| `C-x p k` | 删除项目相关的缓冲区 |
| `C-x p C-b` | 列出项目缓冲区 |
| `C-x p C-s` | 保存项目中的缓冲区 |
| `C-x p R` | 记住某个目录下的项目（前缀参数递归查找） |
| `C-x p X` | 遗忘某个项目 |
| `C-x p Z` | 清理已失效的项目 |
| `gp` | Evil normal state 的项目前缀，例如 `gp f`、`gp p` |
| `C-c P` | 任意 state 下可用的项目前缀 |

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
| `gp` / `C-c P` | Evil normal state / 任意 state 的项目前缀 |
| `gr` | Eglot 管理缓冲区中 Evil normal state 的 LSP 前缀 |
| `C-c e` | Eglot 全局前缀键（代码操作、重命名、格式化、跳转等） |
| `C-c v` | uv / Python 前缀键（sync、lock、add、run、Python shell） |

## 版本控制

仓库只跟踪配置文件。以下内容由 `.gitignore` 排除：

- `var/elpa/`：安装的包
- `var/eln-cache/`、`eln-cache/`、`*.elc`、`*.eln`：编译产物
- `var/tree-sitter/`：自动编译的 Tree-sitter 语法库
- `var/autosave/`、`var/history`、`var/recentf.eld`、`var/saveplace`
- `var/projects.eld`：project.el 记住的项目列表
- `var/org-roam.db`：从笔记自动生成的数据库
- 顶层遗留的 `elpa/` 目录
