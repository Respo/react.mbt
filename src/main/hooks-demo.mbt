///|
using @react {obscure, li}

///|
/// Hooks Demo Component - 展示新增的 React Hooks API 功能
///
struct HooksDemoProps {} derive(Default)

///|
/// 主要的 Hooks 演示组件
fn comp_hooks_demo(_props : HooksDemoProps) -> VirtualNode {
  // 基础状态管理
  let (count, set_count) = @react.use_state(0)
  let (message, set_message) = @react.use_state("初始消息")
  let (timer_count, set_timer_count) = @react.use_state(0)
  let (action_status, dispatch_action, is_action_pending) = @react.use_action_state(
    "未执行",
    fn(_previous : String, action : String) { action },
  )

  // 演示 use_effect_once - 仅在组件挂载时执行一次
  @react.use_effect_once(fn() {
    println("🎯 Hooks Demo 组件已挂载！")
    set_message("组件已成功挂载")
  })

  // 演示 use_effect_event：读取最新状态但不使 effect 因回调身份变化重订阅
  let update_count_message = @react.use_effect_event(fn() {
    if count > 0 {
      set_message("计数器已更新到: \{count}")
    }
  })

  // 演示 use_effect_deps - 依赖于 count 变化
  @react.use_effect_deps(
    fn() {
      println("📊 计数器变化: \{count}")
      update_count_message()
    },
    [count |> obscure],
  )

  // 演示 use_ref - 创建一个可变引用
  let timer_ref = @react.use_ref(0)

  // 演示 use_memo_deps - 计算昂贵的值
  let expensive_value = @react.use_memo_deps(
    fn() {
      println("🧮 重新计算昂贵的值...")
      count * count + count * 10
    },
    [count |> obscure],
  )

  // 演示 use_callback_deps - 缓存回调函数
  let increment_callback = @react.use_callback_deps(
    fn() { set_count(count + 1) },
    [count |> obscure],
  )

  // 定时器效果 - 演示更复杂的 useEffect 用法
  @react.use_effect_deps(
    fn() {
      if timer_count < 10 {
        // 模拟定时器效果
        println("⏰ 定时器: \{timer_count}")
      }
    },
    [timer_count |> obscure],
  )
  @react.div(
    style=respo_style(
      padding=20.0 |> Px,
      margin=10.0 |> Px,
      background_color=Hsl(120, 20, 95),
    ),
    [
      @react.h2([@react.Text("🎣 React Hooks API 演示")]),

      // 状态展示区域
      @react.div(style=@css.respo_style(margin_bottom=15.0 |> @css.Px), [
        @react.h3([@react.Text("📊 状态信息")]),
        @react.p([@react.Text("当前计数: \{count}")]),
        @react.p([@react.Text("消息: \{message}")]),
        @react.p([
          @react.Text(
            "操作状态: \{action_status}（进行中: \{is_action_pending}）",
          ),
        ]),
        @react.p([
          @react.Text("计算值 (count² + count×10): \{expensive_value}"),
        ]),
        @react.p([@react.Text("定时器计数: \{timer_count}")]),
      ]),

      // 操作按钮区域
      @react.div(style=@css.respo_style(margin_bottom=15.0 |> @css.Px), [
        @react.h3([@react.Text("🎮 操作控制")]),
        @react.button(
          on_click=fn(_e) { increment_callback() },
          style=@css.respo_style(
            margin_right=10.0 |> @css.Px,
            padding=8.0 |> @css.Px,
            background_color=@css.Hsl(200, 70, 50),
            color=@css.White,
            border_radius=4.0,
            cursor=Pointer,
            // border=None,
          ),
          [@react.Text("增加计数 (+1)")],
        ),
        @react.button(
          on_click=fn(_) {
            set_count(0)
            set_message("计数器已重置")
          },
          style=@css.respo_style(
            margin_right=10.0 |> @css.Px,
            padding=8.0 |> @css.Px,
            background_color=@css.Hsl(0, 70, 50),
            color=@css.White,
            border_radius=4.0,
            cursor=Pointer,
          ),
          [@react.Text("重置计数")],
        ),
        @react.button(
          on_click=fn(_) {
            let current = timer_ref.get()
            let new_val = current + 1
            timer_ref.set(new_val)
            set_timer_count(new_val)
          },
          style=@css.respo_style(
            padding=8.0 |> Px,
            background_color=Hsl(120, 70, 40),
            color=White,
            border_radius=4.0,
            cursor=Pointer,
          ),
          [Text("启动定时器")],
        ),
        @react.button(
          on_click=fn(_) {
            @react.start_transition(fn() { dispatch_action("操作已完成") })
          },
          style=@css.respo_style(
            margin_left=10.0 |> @css.Px,
            padding=8.0 |> @css.Px,
            background_color=@css.Hsl(280, 60, 45),
            color=@css.White,
            border_radius=4.0,
            cursor=Pointer,
          ),
          [Text("执行状态操作")],
        ),
      ]),

      // 功能说明区域
      @react.div(
        style=@css.respo_style(
          background_color=Hsl(60, 30, 95),
          padding=15.0 |> Px,
          border_radius=6.0,
          border=CssBorder(1.0, Solid, Hsl(60, 30, 80)),
        ),
        [
          @react.h3([Text("📚 功能说明")]),
          @react.ul([
            li([
              Text(
                "🎯 use_effect_once: 组件挂载时执行一次，查看控制台日志",
              ),
            ]),
            li([
              Text(
                "📊 use_effect_deps: 依赖计数器变化，每次点击增加都会触发",
              ),
            ]),
            li([
              Text(
                "🧮 use_memo_deps: 缓存计算结果，只在计数变化时重新计算",
              ),
            ]),
            li([
              Text("🎮 use_callback_deps: 缓存回调函数，优化性能"),
            ]),
            li([
              Text("📝 use_ref: 创建可变引用，用于定时器计数"),
            ]),
          ]),
        ],
      ),
    ],
  )
}
