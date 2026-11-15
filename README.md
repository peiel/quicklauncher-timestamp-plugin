# QuickLauncher 时间戳转换

在 QuickLauncher 中转换 Unix 时间戳。结果按 macOS 当前本地时区显示并复制，显示的 UTC 偏移取决于该时间点的时区规则。

## 安装

使用支持 `input: "arguments"` 和 `copyAndShow` 的 QuickLauncher 版本，并确保 Ruby 运行环境可用。在“设置 → 插件 → 发现插件”中输入 `peiel/quicklauncher-timestamp-plugin`，审查并确认安装，再在“已安装”中启用。安装后可修改触发词。

也可以从[插件展示站](https://plugin.quicklauncher.flyee.tech)选择插件并在 QuickLauncher 中打开，然后审查安装。

## 使用

- `ts now`：显示并复制当前 Unix 时间戳（整数秒）。
- `ts 1700000000`：按秒转换，例如 UTC 下为 `2023-11-14 22:13:20 +00:00`。
- `ts 1700000000123`：按毫秒转换，例如 UTC 下为 `2023-11-14 22:13:20.123 +00:00`。
- `ts s -1` 或 `ts ms 1000`：显式指定秒或毫秒，支持负时间戳。

不指定单位时，1–10 位数字按秒处理，13 位数字按毫秒处理；11–12 位需要显式指定 `ms`。秒最多 10 位、毫秒最多 13 位（不含正负号）；小数、日期字符串和其他格式不支持。插件不联网、不读取剪贴板或其他应用的选区；返回结果由 QuickLauncher 负责显示与复制。

## 测试和协议

运行 `ruby tests/timestamp_test.rb`。脚本读取单个 JSON 请求，例如 `{"version":1,"arguments":"1700000000"}`；成功输出 `copyAndShow`，无效输入输出 `error`。脚本仅使用 Ruby 标准库。

本项目使用 [MIT 协议](LICENSE)。
