///|
fnalias @preact.obscure

///|
/// Hooks Demo Component - 展示新增的 Preact Hooks API 功能
///
struct HooksDemoProps {} derive(Default)

///|
impl @preact.JsValueTrait for HooksDemoProps with to_value(_self) -> @preact.JsValue {
  @preact.JsObject::new().to_value()
}

///|
impl @preact.JsValueTrait for HooksDemoProps with from_value(
  _value : @preact.JsValue,
) -> HooksDemoProps {
  HooksDemoProps::default()
}

///|
/// 主要的 Hooks 演示组件
fn comp_hooks_demo(_props : HooksDemoProps) -> VirtualNode {
  // 基础状态管理
  let (count, set_count) = @preact.use_state(0)
  let (message, set_message) = @preact.use_state("初始消息")
  let (timer_count, set_timer_count) = @preact.use_state(0)

  // 演示 use_effect_once - 仅在组件挂载时执行一次
  @preact.use_effect_once(fn() {
    println("🎯 Hooks Demo 组件已挂载！")
    set_message("组件已成功挂载")
  })

  // 演示 use_effect_deps - 依赖于 count 变化
  @preact.use_effect_deps(
    fn() {
      println("📊 计数器变化: \{count}")
      if count > 0 {
        set_message("计数器已更新到: \{count}")
      }
    },
    [count |> obscure],
  )

  // 演示 use_ref - 创建一个可变引用
  let timer_ref = @preact.use_ref(0)

  // 演示 use_memo_deps - 计算昂贵的值
  let expensive_value = @preact.use_memo_deps(
    fn() {
      println("🧮 重新计算昂贵的值...")
      count * count + count * 10
    },
    [count |> obscure],
  )

  // 演示 use_callback_deps - 缓存回调函数
  let increment_callback = @preact.use_callback_deps(
    fn() { set_count(count + 1) },
    [count |> obscure],
  )

  // 定时器效果 - 演示更复杂的 useEffect 用法
  @preact.use_effect_deps(
    fn() {
      if timer_count < 10 {
        // 模拟定时器效果
        println("⏰ 定时器: \{timer_count}")
      }
    },
    [timer_count |> obscure],
  )
  @preact.div(
    style=respo_style(
      padding=20.0 |> Px,
      margin=10.0 |> Px,
      background_color=Hsl(120, 20, 95),
    ),
    [
      @preact.h2([Text("🎣 Preact Hooks API 演示")]),

      // 状态展示区域
      @preact.div(style=@css.respo_style(margin_bottom=15.0 |> @css.Px), [
        @preact.h3([Text("📊 状态信息")]),
        @preact.p([Text("当前计数: \{count}")]),
        @preact.p([Text("消息: \{message}")]),
        @preact.p([Text("计算值 (count² + count×10): \{expensive_value}")]),
        @preact.p([Text("定时器计数: \{timer_count}")]),
      ]),

      // 操作按钮区域
      @preact.div(style=@css.respo_style(margin_bottom=15.0 |> @css.Px), [
        @preact.h3([Text("🎮 操作控制")]),
        @preact.button(
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
          [Text("增加计数 (+1)")],
        ),
        @preact.button(
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
          [Text("重置计数")],
        ),
        @preact.button(
          on_click=fn(_) {
            let current = timer_ref.get()
            let new_val = current + 1
            timer_ref.set(new_val)
            set_timer_count(new_val)
          },
          style=@css.respo_style(
            padding=8.0 |> @css.Px,
            background_color=@css.Hsl(120, 70, 40),
            color=@css.White,
            border_radius=4.0,
            cursor=Pointer,
          ),
          [Text("启动定时器")],
        ),
      ]),

      // 功能说明区域
      @preact.div(
        style=@css.respo_style(
          background_color=@css.Hsl(60, 30, 95),
          padding=15.0 |> Px,
          border_radius=6.0,
          border=CssBorder(1.0, Solid, @css.Hsl(60, 30, 80)),
        ),
        [
          @preact.h3([Text("📚 功能说明")]),
          @preact.ul([
            @preact.li([
              Text(
                "🎯 use_effect_once: 组件挂载时执行一次，查看控制台日志",
              ),
            ]),
            @preact.li([
              Text(
                "📊 use_effect_deps: 依赖计数器变化，每次点击增加都会触发",
              ),
            ]),
            @preact.li([
              Text(
                "🧮 use_memo_deps: 缓存计算结果，只在计数变化时重新计算",
              ),
            ]),
            @preact.li([
              Text("🎮 use_callback_deps: 缓存回调函数，优化性能"),
            ]),
            @preact.li([
              Text("📝 use_ref: 创建可变引用，用于定时器计数"),
            ]),
          ]),
        ],
      ),
    ],
  )
}
