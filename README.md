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
├── pre-init.el             # 加载路径、行号、基础剪贴板设置
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
│   │   └── init-org.el
│   ├── elpa/               # 安装的包（不纳入 Git）
│   ├── eln-cache/          # 原生编译缓存（不纳入 Git）
│   ├── autosave/           # 自动保存文件（不纳入 Git）
│   ├── org-roam.db         # Org-roam 数据库（不纳入 Git）
│   └── ...                 # 历史、recentf、saveplace 等运行时数据
└── README.md
```

`pre-early-init.el` 把 `user-emacs-directory` 设为 `~/.emacs.d/var/`，
因此包目录、历史记录、缓存和自动保存文件都集中在 `var/` 中，仓库根目录只保留
配置文件。

## 环境要求

- Emacs 29.1 或更新版本（当前验证版本：31.1）
- Linux
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
7. `init-org`：Org、Org-roam、Org-roam-ui、Consult 集成

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

## 常用快捷键

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

## 版本控制

仓库只跟踪配置文件。以下内容由 `.gitignore` 排除：

- `var/elpa/`：安装的包
- `var/eln-cache/`、`eln-cache/`、`*.elc`、`*.eln`：编译产物
- `var/autosave/`、`var/history`、`var/recentf.eld`、`var/saveplace`
- `var/org-roam.db`：从笔记自动生成的数据库
- 顶层遗留的 `elpa/` 目录
