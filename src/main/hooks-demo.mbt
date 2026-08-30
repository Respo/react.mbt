///|
using @react {obscure, li}

///|
/// Hooks Demo Component - 展示新增的 React Hooks API 功能
///
struct HooksDemoProps {} derive(Default)

///|
struct ContextReaderProps {
  context : @react.ReactContext[String]
  label : String
}

///|
struct FormActionDemoState {
  calls : Int
  message : String
}

///|
struct FormStatusProps {} derive(Default)

///|
extern "js" fn wait_for_controlled_form_result() -> @js_async.Promise[Bool] =
  #| () => {
  #|   if (globalThis.__moonbitFormActionResolve) {
  #|     throw new Error("A controlled form Action is already pending");
  #|   }
  #|   return new Promise((resolve) => {
  #|     globalThis.__moonbitFormActionResolve = resolve;
  #|   });
  #| }

///|
extern "js" fn resolve_controlled_form_result(succeeded : Bool) -> Unit =
  #| (succeeded) => {
  #|   const resolve = globalThis.__moonbitFormActionResolve;
  #|   if (!resolve) return;
  #|   delete globalThis.__moonbitFormActionResolve;
  #|   resolve(succeeded);
  #| }

///|
fn comp_context_reader(props : ContextReaderProps) -> VirtualNode {
  let value = @react.use_context(props.context)
  @react.p([Text("\{props.label}: \{value}")])
}

///|
fn comp_form_status(_props : FormStatusProps) -> VirtualNode {
  let status = @react.use_form_status()
  let submitted = match status.data() {
    Some(data) => data.get_string("item").unwrap_or("")
    None => ""
  }
  @react.p(id="form-action-status", [
    Text(
      "Form 状态: pending=\{status.pending()}, method=\{status.submission_method()}, submitted=\{submitted}",
    ),
  ])
}

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
  let (saved_form_value, set_saved_form_value) = @react.use_state("baseline")
  let (optimistic_form_value, set_optimistic_form_value) = @react.use_optimistic(
    saved_form_value,
    fn(_current : String, submitted : String) { submitted },
  )
  let (form_result, submit_form_action, is_form_action_pending) = @react.use_async_action_state(
    { calls: 0, message: "idle" },
    async fn(previous : FormActionDemoState, data : @react.ReactFormData) {
      let submitted = data.get_string("item").unwrap_or("")
      set_optimistic_form_value(submitted)
      let succeeded = wait_for_controlled_form_result().wait()
      if succeeded {
        set_saved_form_value(submitted)
        { calls: previous.calls + 1, message: "saved" }
      } else {
        { calls: previous.calls + 1, message: "rejected" }
      }
    },
  )
  let demo_context = @react.use_memo_deps(
    fn() { @react.create_context("默认值") },
    [],
  )

  // 演示 use_effect_once - 仅在组件挂载时执行一次
  @react.use_effect_once(fn() { set_message("组件已成功挂载") })

  // 演示 use_effect_event：读取最新状态但不使 effect 因回调身份变化重订阅
  let update_count_message = @react.use_effect_event(fn() {
    if count > 0 {
      set_message("计数器已更新到: \{count}")
    }
  })

  // 演示 use_effect_deps - 依赖于 count 变化
  @react.use_effect_deps(fn() { update_count_message() }, [count |> obscure])

  // 演示 use_ref - 创建一个可变引用
  let timer_ref = @react.use_ref(0)
  let dom_ref = @react.use_dom_ref()
  let (show_dom_ref, set_show_dom_ref) = @react.use_state(true)
  let (dom_ref_status, set_dom_ref_status) = @react.use_state("未检查")
  let dom_ref_attrs = @react.ElementAttrs::new()
  dom_ref_attrs.set_js_value("ref", dom_ref.to_js_obscure())

  // 演示 use_memo_deps - 计算昂贵的值
  let expensive_value = @react.use_memo_deps(
    fn() { count * count + count * 10 },
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
      if timer_count > 0 {
        set_message("定时器已更新到: \{timer_count}")
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
        @react.component(
          comp_context_reader,
          { context: demo_context, label: "无 Provider" },
          [],
        ),
        demo_context.provider("外层值", [
          @react.component(
            comp_context_reader,
            { context: demo_context, label: "外层 Provider" },
            [],
          ),
          demo_context.provider("内层值", [
            @react.component(
              comp_context_reader,
              { context: demo_context, label: "内层 Provider" },
              [],
            ),
          ]),
          @react.component(
            comp_context_reader,
            { context: demo_context, label: "恢复外层" },
            [],
          ),
        ]),
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

      // React 19 Forms and Actions：可控 Promise 让 pending 与回滚可确定测试
      @react.div(style=@css.respo_style(margin_bottom=15.0 |> @css.Px), [
        @react.h3([Text("📝 React 19 Forms and Actions")]),
        @react.p(id="form-action-canonical", [
          Text("已保存: \{saved_form_value}"),
        ]),
        @react.p(id="form-action-optimistic", [
          Text("乐观值: \{optimistic_form_value}"),
        ]),
        @react.p(id="form-action-result", [
          Text(
            "Action 结果: \{form_result.message}, calls=\{form_result.calls}, pending=\{is_form_action_pending}",
          ),
        ]),
        @react.form(
          id="controlled-action-form",
          action=@react.form_action(submit_form_action),
          [
            @react.input(
              id="form-action-input",
              name="item",
              default_value="candidate",
              disabled=is_form_action_pending,
            ),
            @react.component(comp_form_status, FormStatusProps::default(), []),
            @react.button(
              button_type="submit",
              disabled=is_form_action_pending,
              [Text("提交 Action")],
            ),
          ],
        ),
        @react.button(
          id="resolve-form-success",
          button_type="button",
          disabled=!is_form_action_pending,
          on_click=fn(_) { resolve_controlled_form_result(true) },
          [Text("完成成功")],
        ),
        @react.button(
          id="resolve-form-failure",
          button_type="button",
          disabled=!is_form_action_pending,
          on_click=fn(_) { resolve_controlled_form_result(false) },
          [Text("完成失败")],
        ),
      ]),

      // DOM ref 挂载与卸载语义
      @react.div(style=@css.respo_style(margin_bottom=15.0 |> @css.Px), [
        @react.h3([Text("🔗 DOM Ref")]),
        if show_dom_ref {
          @react.input(
            id="dom-ref-target",
            attrs=dom_ref_attrs,
            placeholder="DOM ref target",
          )
        } else {
          @react.p([Text("DOM ref target 已卸载")])
        },
        @react.p(id="dom-ref-status", [
          Text("DOM ref 状态: \{dom_ref_status}"),
        ]),
        @react.button(
          on_click=fn(_) {
            match dom_ref.current() {
              Some(element) => element.focus()
              None => ()
            }
          },
          [Text("聚焦 DOM ref")],
        ),
        @react.button(on_click=fn(_) { set_show_dom_ref(!show_dom_ref) }, [
          Text(if show_dom_ref { "卸载 DOM ref" } else { "挂载 DOM ref" }),
        ]),
        @react.button(
          on_click=fn(_) {
            set_dom_ref_status(
              match dom_ref.current() {
                Some(_) => "已挂载"
                None => "空"
              },
            )
          },
          [Text("检查 DOM ref")],
        ),
        @react.input(
          id="controlled-readonly-input",
          value="只读受控值",
          read_only=true,
        ),
        @react.input(
          id="uncontrolled-default-input",
          default_value="非受控初始值",
        ),
        @react.select(
          id="uncontrolled-multiple-select",
          default_values=["alpha", "gamma"],
          multiple=true,
          [
            @react.option(value="alpha", [Text("Alpha")]),
            @react.option(value="beta", [Text("Beta")]),
            @react.option(value="gamma", [Text("Gamma")]),
          ],
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
              Text("🎯 use_effect_once: 组件挂载时初始化状态消息"),
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
