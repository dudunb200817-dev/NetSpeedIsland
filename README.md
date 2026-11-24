# 灵动网速（NetSpeedIsland）安装与使用指南

这是一个专为 iPhone 灵动岛设计的轻量级实时网速监控 App（SwiftUI + ActivityKit），支持免费 Apple ID 通过**开发者模式**自装到自己的 iPhone 上，无需越狱，也无需购买 688 元/年的苹果开发者账号。

## 功能特点
- **灵动岛实时显示**：左侧实时下载速度（绿色 `↓`），右侧实时上传速度（蓝色 `↑`），长按展开可查看当前网络类型（Wi-Fi / 蜂窝网络）与本次累计流量。
- **锁屏实时活动卡片**：锁屏界面同步展示实时上下行网速与累计流量。
- **实时波形图**：主界面内置最近 30 次采样的下载速度曲线与峰值统计。
- **后台持续刷新**：可选开启静默音频保活（`.mixWithOthers` 模式，不打断听歌和看视频），防止 iOS 切后台后挂起导致灵动岛停止刷新。

---

## 路线 A：直接在你的 2019 Intel Mac 上用 Xcode 安装（推荐）

适用条件：你的 Mac 系统为 macOS Sequoia 15.6+ 或 macOS Tahoe 26，且已安装对应版本的 [Xcode](https://developer.apple.com/xcode/system-requirements/)（与你的 iPhone 系统版本匹配）。

### 第 1 步：生成 Xcode 工程
在 Mac 上打开“终端（Terminal）”，进入解压后的 `NetSpeedIsland` 文件夹，运行：

```bash
brew install xcodegen
xcodegen generate
open NetSpeedIsland.xcodeproj
```

> 如果你的 Mac 还没装 Homebrew，也可以直接在 Xcode 里新建一个 iOS App 工程 + Widget Extension（勾选 Include Live Activity），然后把 `Shared/`、`NetSpeedIsland/` 和 `NetSpeedWidgetExtension/` 里的 Swift 文件拖进去。

### 第 2 步：登录免费 Apple ID 并修改 Bundle ID
1. 在 Xcode 顶部菜单打开 **Xcode → Settings → Accounts**，点左下角 `+` 登录你的普通 Apple ID。
2. 点击左侧工程名 `NetSpeedIsland`，依次选中两个 Target（`NetSpeedIsland` 和 `NetSpeedWidgetExtension`）：
   - 切到 **Signing & Capabilities** 标签页。
   - 勾选 **Automatically manage signing**，**Team** 选择你的个人 Apple ID（Personal Team）。
   - 把 **Bundle Identifier** 改成独一无二的名字（例如把 `com.personal.netspeedisland` 改成 `com.你的名字.netspeedisland`，Widget 的则改成 `com.你的名字.netspeedisland.widget`）。

### 第 3 步：打开 iPhone 开发者模式并安装
1. 用数据线将 iPhone 连上 Mac，解锁手机并点“信任此电脑”。
2. 在 Xcode 顶部设备栏选中你的 iPhone，按 `Cmd + R` 运行。
3. 此时去 iPhone 的 **设置 → 隐私与安全性 → 开发者模式**，打开开关并按提示重启手机（参考 [Apple 官方启用开发者模式文档](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)）。
4. 首次打开 App 若提示“未受信任的开发者”，前往 **设置 → 通用 → VPN 与设备管理**，点击你的 Apple ID 并选择**信任**即可。

---

## 路线 B：如果 2019 Mac 的 Xcode 版本太旧（GitHub 云端免费打包 `.ipa`）

如果你的 iPhone 已经升级到最新 iOS（如 iOS 27），而 2019 款 Intel Mac 装不了对应版本的 Xcode，可以用本工程自带的 GitHub Actions 脚本免费云端编译：

1. 在 GitHub 上新建一个免费仓库，把本文件夹内的所有文件（包含隐藏目录 `.github/workflows/build-ipa.yml`）上传上去。
2. 打开仓库顶部的 **Actions** 页面，等待 **Build Unsigned IPA** 绿勾完成（约 2～3 分钟），在页面底部下载 `NetSpeedIsland-IPA` 压缩包，解压得到 `NetSpeedIsland.ipa`。
3. 在你的 2019 Mac 上使用 [SideStore](https://docs.sidestore.io/docs/faq) 或 [AltStore](https://faq.altstore.io/altstore-classic/your-altstore) 把 `NetSpeedIsland.ipa` 免费自签装进 iPhone（同样需要开启上面的“开发者模式”）。

---

## 使用注意事项
- **7 天续签**：免费 Apple ID 自签安装的 App 有效期为 7 天，到期前连一下 Mac 重新点 `Cmd + R`（或用 [SideStore](https://docs.sidestore.io/docs/faq) 直接在手机上点刷新）即可无缝续签，不会丢数据。
- **8 小时上限**：苹果规定单次灵动岛 [Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities) 最长持续 8 小时，到期后打开 App 重新点一下“开启灵动岛实时网速”即可。
