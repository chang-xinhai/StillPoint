# StillPoint 产品规格

版本：2026-07-08
目标平台：macOS 菜单栏原型优先，Android 作为后续迁移目标
一句话：StillPoint 在用户被信息流带走之前，插入一次温和但有效的选择权。

## 1. 产品理念

StillPoint 不是严格意义上的 app blocker，也不是又一个待办、番茄钟或 dashboard。
它解决的问题更具体：

> 很多分心不是主动选择，而是等待、疲惫、无聊或卡住时的一次下意识打开。

用户打开抖音、B 站、小红书、YouTube Shorts 可能确实有正当目的：
查一个视频、找一条教程、回复一个链接、短暂休息一下。StillPoint 不应该在
入口处粗暴阻止。真正危险的时刻是：

- 用户原本只是查东西，但被首页信息流吸走；
- 用户在 VSCode / Cursor 等待 AI agent 反馈时顺手打开短视频；
- 用户以“休息一下”为名进入 feed，但没有一个结束点；
- 用户明知道不想刷，却因为路径太顺滑而继续。

所以 StillPoint 的产品原则是：

1. **先相信用户，再保护用户。** 不默认羞辱、不默认惩罚。
2. **只拦截漂移，不打断正常工作。** 默认只监控明确列入的高风险应用和站点。
3. **少打扰，但必须有效。** 不频繁弹提醒；一旦触发，必须能打断自动驾驶。
4. **把自控从意志力问题变成环境设计问题。** 用户不需要每次都靠硬扛。
5. **复盘按天发生，而不是每次退出都打扰。** Attention Receipt 是每日总结，不是每次弹出一张小票。

## 2. 产品定位

竞品给我们的启发：

- one sec：在打开分心应用前加入短暂停顿。
- ScreenZen：选择应用、设定限制、安排专注时段、追踪结果，且有 Lock Mode。
- Opal：高级的专注会话和更强的 blocking difficulty。
- ClearSpace：更温和的 mindful controls，而不是单纯惩罚。

StillPoint 的差异化：

- 不是“打开即拦”，而是识别从正当使用滑向无意识刷屏的过程。
- 不把注意力问题包装成羞耻感，而是把它设计成一次可恢复的选择。
- 每天给用户一张 Daily Attention Receipt，让用户看到被挽回的时间和触发场景。
- 强调“保护无聊”：不是把所有空白都填满，而是帮用户保留一点没有被 feed 占领的空间。

## 3. 核心场景：macOS 抖音

### 3.1 普通模式

1. 用户在 StillPoint 菜单栏面板或 Control Center 中把“抖音”加入 watched list。
2. StillPoint 后台监听当前前台应用。
3. 用户打开抖音。
4. StillPoint 开始一个 Grace Window，例如 90 秒。
5. 90 秒内不打扰，因为用户可能真的只是查一个东西。
6. 如果用户仍然停留在抖音，StillPoint 弹出全屏 intervention：

   > You have been in Douyin for 1m 30s.  
   > Are you still here for the reason you came?

7. 用户选择：

   - `Looking something up · 3 min`
   - `Intentional break · 5 min`
   - `I drifted · close it`
   - `Lock this until focus ends`

8. 如果选择继续，StillPoint 发放一个 Purpose Pass，到期后再次检查。
9. 如果再次超时，摩擦升级，例如要求输入目的或进入冷却。

### 3.2 Deep Work Lock

用于“我在写代码，但等 Codex / 构建 / 测试时会手滑打开短视频”的场景。

1. 用户点击 `Start Deep Work Lock`，选择 25 / 45 / 90 分钟。
2. 锁定期内，高风险应用进入强保护。
3. 打开 watched app 时，不再给长 Grace Window，而是快速触发 intervention。
4. 用户仍可 emergency unlock，但摩擦更高：

   - 等待一段时间；
   - 写出当前目的；
   - 或承认 drift 并返回工作。

MVP 中的 Deep Work Lock 不承诺系统级不可绕过。它的目标是 demo 出真实闭环：
检测前台应用、覆盖屏幕、要求用户做选择、记录结果。

## 4. 人性化规则

### 4.1 默认不监控工作工具

默认不监控：

- VSCode / Cursor / Xcode
- Terminal / iTerm
- Lark / 飞书
- Obsidian / Notion
- Chrome / Safari 整个浏览器

浏览器只在后续支持域名匹配后，监控明确的 social feed 域名，例如：

- `douyin.com`
- `tiktok.com`
- `youtube.com/shorts`
- `bilibili.com`
- `xiaohongshu.com`

这样避免用户查文档、看课程、处理工作网页时被误伤。

### 4.2 Grace Window

StillPoint 不在用户刚打开应用时立刻阻止。默认策略：

- 普通模式：60-120 秒宽限。
- Demo 模式：8-15 秒宽限，便于现场展示。
- Deep Work Lock：0-15 秒宽限。

### 4.3 Purpose Pass

Purpose Pass 是一次有边界的继续使用授权。

示例：

- 查东西：3 分钟。
- 有意识休息：5 分钟。
- 特殊情况：用户可以自定义。

Purpose Pass 到期后，不直接惩罚，而是再次询问用户是否仍然有目的。

### 4.4 Friction Ladder

同一天同一应用反复触发时，摩擦逐级升级：

1. 第一次：轻提示。
2. 第二次：必须选择目的和时长。
3. 第三次：必须输入一句具体目的。
4. 第四次：建议进入 cooldown 或 Deep Work Lock。

MVP 先实现前两级和 Deep Work Lock。

## 5. Daily Attention Receipt

Attention Receipt 不在每次退出应用时弹出，避免制造新的打扰。
它只作为每日总结存在。

每天结束时，或者用户打开 StillPoint 菜单栏面板 / Control Center 时，可以看到：

- 今天被检测到的 drift 次数；
- 发放了多少次 Purpose Pass；
- 用户主动关闭了几次分心应用；
- Deep Work Lock 持续了多久；
- 估算挽回了多少分钟；
- 最容易漂移的时间段；
- 最容易漂移的应用。

示例文案：

> Today, StillPoint caught 4 possible drifts.  
> You closed Douyin twice, used 2 purpose passes, and protected about 23 minutes of deep work.

这个总结应该是低压的，不做羞辱排行榜，不做失败惩罚。

## 6. MVP 功能范围

必须完成：

- macOS 菜单栏常驻入口。
- 玻璃质感 Control Center 窗口，用于 demo、配置和查看实时前台应用。
- 前台应用监听。
- watched app 列表。
- Demo Mode 短阈值。
- Deep Work Lock。
- 全屏 intervention overlay。
- 用户选择后的放行 / 关闭 / 锁定逻辑。
- 今日 Attention Receipt 聚合面板。

可以后续做：

- 浏览器当前 URL / title 识别。
- 输入具体目的。
- 更强 lock 防绕过。
- Android 版本。
- 数据持久化和历史趋势。

明确不做：

- 不监控用户所有行为。
- 不读取聊天内容。
- 不上传个人使用数据。
- 不把工作浏览器整体加入默认拦截。
- 不把每次退出都变成一次复盘打扰。

## 7. 技术原理

macOS 原型：

- 使用 `NSWorkspace.shared.frontmostApplication` 监听当前前台应用。
- 使用定时器计算 watched app 的连续停留时间。
- 命中阈值后创建屏幕级 overlay window。
- 用户选择后更新本地状态和当日聚合记录。
- Deep Work Lock 通过更短阈值和更高摩擦实现。

后续 Android 迁移：

- 使用 `UsageStatsManager` 判断应用使用状态。
- 使用 `AccessibilityService` 获取前台上下文。
- 使用系统 overlay 呈现 intervention。
- 小米 / HyperOS 需要额外处理悬浮窗、无障碍、后台、自启动和电池策略。

## 8. 预期效果

短期 demo 效果：

- 评委能看到一个真实运行的 macOS 原型，而不是静态网页。
- 从打开抖音类应用到触发 StillPoint 的流程完整可演示。
- Deep Work Lock 能对应“写代码等 AI agent 时分心”的真实场景。
- Daily Attention Receipt 展示产品闭环，而不会打扰每次正常退出。

长期产品效果：

- 用户少依赖意志力，多依赖环境设计。
- 用户仍保留正当使用分心应用的自由。
- 用户能逐渐意识到自己最容易被 feed 带走的场景。
- 产品帮助用户保护无聊、专注和主动选择权。
