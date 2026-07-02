# 🏋️ Kestra Practice Exercises — Beginner to Advanced

A hands-on companion to the Kestra Core Concepts Cheat-Sheet. Work through each level in order — every exercise builds on skills from the previous one. Try to solve each question yourself before checking the answer/tutorial at the end of the file.

---

## 🗺️ How This File Is Organized

1. [🟢 Beginner](#-beginner) — flow basics, inputs, outputs, logging
2. [🟡 Intermediate](#-intermediate) — variables, triggers, control flow
3. [🟠 Advanced](#-advanced) — error handling, concurrency, subflows
4. [🔴 Expert / Real-World](#-expert--real-world) — production-grade pipeline design
5. [✅ Answers & Tutorials](#-answers--tutorials)

---

## 🟢 Beginner

**B1.** Write a flow called `hello_kestra` in namespace `practice.beginner` with a single `Log` task that prints `"Hello, Kestra!"`.

**B2.** Add a `STRING` input called `username` (default: `"Guest"`) to the flow above, and update the log message to greet that user by name.

**B3.** Create a flow with two tasks: the first uses `io.kestra.plugin.core.debug.Return` to output the value `42`, and the second logs that output using the correct expression syntax.

**B4.** What is the difference between an **Input** and a **Variable** in Kestra? Give one real-world example of when you'd use each.

**B5.** Create a flow with three sequential `Log` tasks. Explain, in your own words, what determines the execution order of tasks in Kestra.

---

## 🟡 Intermediate

**I1.** Define a `variables:` block with a base URL (`https://api.open-meteo.com`) and a task that builds a full request URI by combining that variable with a query string. Remember the special function needed to render nested expressions.

**I2.** Add a `Schedule` trigger to a flow so it runs every weekday at 8:00 AM, and pass a fixed input value through the trigger.

**I3.** Write a flow that uses an `If` task to branch behavior: if an input `environment` equals `"prod"`, log `"Running in production"`; otherwise log `"Running in dev"`.

**I4.** You have a list of three regions: `["us-east", "eu-west", "ap-south"]`. Write a flow that logs a message for each region using a flow-control task. Should you use `ForEach` or `EachParallel` if the regions must be processed one at a time in a strict order? Why?

**I5.** What does the `pluginDefaults:` block do, and why is it useful when you have 15 `Log` tasks across a large flow that should all log at `WARN` level?

---

## 🟠 Advanced

**A1.** A task calling a flaky third-party weather API should be retried up to 4 times with a 15-second constant delay before the flow is marked failed. Write the relevant YAML.

**A2.** Design an `errors:` block that sends a Slack notification (conceptually — pseudo-plugin is fine) whenever the flow fails, including the flow ID and execution ID in the message.

**A3.** You have a nightly ETL flow that must never have two instances running simultaneously — if a new run is triggered while one is active, it should be rejected outright (not queued). Write the `concurrency:` configuration.

**A4.** Refactor a large monolithic flow (ingest → transform → load, ~20 tasks) into a modular design using **Subflows**. Describe which pieces you'd split out and why, and show the YAML for calling one subflow from the parent flow.

**A5.** A task downloads a CSV file and a separate task needs to read that exact file from disk (not from Kestra's structured outputs). What Kestra construct do you need to wrap both tasks in, and why can't you just use `outputs.<task_id>` here?

---

## 🔴 Expert / Real-World

**E1. (Production Resilience)** You're running a daily financial data pipeline. Design a flow that: (a) retries transient API failures, (b) allows a non-critical "send summary email" step to fail without failing the whole run, (c) always cleans up a temp directory whether the run succeeds or fails, and (d) pages the on-call engineer via Slack only on hard failure. Sketch the YAML skeleton (task bodies can be simplified).

**E2. (Event-Driven Architecture)** Redesign a pipeline that currently runs on a fixed hourly `Schedule` trigger so that it instead reacts the moment a new file lands in an S3 bucket. What trigger type would you use, and what are the trade-offs versus polling on a schedule?

**E3. (Multi-Team Governance)** Your organization has 5 teams each publishing flows into a shared Kestra instance. Propose a namespace and labeling convention that would let you: filter executions by team in the UI, prevent naming collisions, and track cloud cost per team. 

**E4. (Backfill Strategy)** A `Schedule` trigger has been silently misconfigured for the last 10 days, so a daily flow never ran. Describe, step by step, how you would safely backfill the missing 10 executions in Kestra without breaking today's live run.

**E5. (Composability & Testing)** You want to unit-test a critical subflow (`compute_risk_score`) in isolation before wiring it into the larger production pipeline. Explain how Kestra's flow/subflow model supports this, and write the YAML for a lightweight "test harness" flow that calls `compute_risk_score` with sample inputs and asserts on its outputs (conceptually, since Kestra has no native `assert` — describe how you'd approximate it with an `If` task).

---

## ✅ Answers & Tutorials

---

### 🟢 Beginner Answers

**B1 — Tutorial:** Every Kestra flow needs a top-level `id` and `namespace`, then a `tasks:` array. The `Log` task is the simplest possible task type.
```yaml
id: hello_kestra
namespace: practice.beginner

tasks:
  - id: say_hello
    type: io.kestra.plugin.core.log.Log
    message: "Hello, Kestra!"
```
*Key takeaway:* `id` + `namespace` uniquely identify a flow; every task also needs its own unique `id` within the flow.

**B2 — Tutorial:** Inputs are declared in a root `inputs:` array and referenced anywhere with `{{ inputs.<id> }}`.
```yaml
id: hello_kestra
namespace: practice.beginner

inputs:
  - id: username
    type: STRING
    defaults: "Guest"

tasks:
  - id: say_hello
    type: io.kestra.plugin.core.log.Log
    message: "Hello, {{ inputs.username }}!"
```
*Key takeaway:* Because `defaults` is set, this flow can run with zero input and still succeed — good practice for flows that may be triggered automatically.

**B3 — Tutorial:** The `Return` (aka `debug.Return`) task simply outputs whatever `format`/`value` you give it. Downstream tasks access it via `outputs.<task_id>.<field>`.
```yaml
id: output_demo
namespace: practice.beginner

tasks:
  - id: produce_value
    type: io.kestra.plugin.core.debug.Return
    format: "42"

  - id: log_value
    type: io.kestra.plugin.core.log.Log
    message: "The answer is: {{ outputs.produce_value.value }}"
```
*Key takeaway:* Outputs are always namespaced by the producing task's `id` — this is what makes task-to-task data flow explicit and traceable.

**B4 — Tutorial:**
- An **Input** is supplied *from outside* the flow at trigger/execution time (like a function argument) — it can differ on every run.
- A **Variable** is fixed *inside* the flow definition itself (like a local constant) — it's the same every run unless you edit the YAML.
- Real-world example: `target_environment` (dev/staging/prod) is a great **Input** because it changes per run. A `base_api_url` computed once and reused across five tasks is a great **Variable** because it avoids repeating the same string.

**B5 — Tutorial:**
```yaml
id: sequence_demo
namespace: practice.beginner

tasks:
  - id: step_one
    type: io.kestra.plugin.core.log.Log
    message: "Step 1"
  - id: step_two
    type: io.kestra.plugin.core.log.Log
    message: "Step 2"
  - id: step_three
    type: io.kestra.plugin.core.log.Log
    message: "Step 3"
```
*Key takeaway:* By default, Kestra executes tasks in the **order they're listed** under `tasks:`, sequentially, unless you explicitly introduce parallelism (`Parallel`, `EachParallel`) or dependency graphs. There's no need for explicit "wire this to that" linkage for simple linear flows.

---

### 🟡 Intermediate Answers

**I1 — Tutorial:** Variables that reference other expressions need `render()` to be deep-parsed at consumption time.
```yaml
id: weather_url_builder
namespace: practice.intermediate

variables:
  base_url: "https://api.open-meteo.com"
  full_uri: "{{ vars.base_url }}/v1/forecast?latitude=41.87&longitude=-87.62"

tasks:
  - id: fetch_weather
    type: io.kestra.plugin.core.http.Request
    uri: "{{ render(vars.full_uri) }}"
```
*Key takeaway:* Forgetting `render()` on nested expressions is one of the most common beginner-to-intermediate bugs — the raw `{{ vars.base_url }}` string would otherwise be sent literally instead of being resolved.

**I2 — Tutorial:**
```yaml
triggers:
  - id: weekday_morning
    type: io.kestra.plugin.core.trigger.Schedule
    cron: "0 8 * * 1-5"
    inputs:
      environment: prod
```
*Key takeaway:* Cron follows standard 5-field syntax (`minute hour day month weekday`). `1-5` covers Monday–Friday. Trigger-level `inputs:` let one flow definition serve multiple schedules with different parameters.

**I3 — Tutorial:**
```yaml
id: env_branch
namespace: practice.intermediate

inputs:
  - id: environment
    type: STRING
    defaults: "dev"

tasks:
  - id: branch_by_env
    type: io.kestra.plugin.core.flow.If
    condition: "{{ inputs.environment == 'prod' }}"
    then:
      - id: log_prod
        type: io.kestra.plugin.core.log.Log
        message: "Running in production"
    else:
      - id: log_dev
        type: io.kestra.plugin.core.log.Log
        message: "Running in dev"
```
*Key takeaway:* `condition` expressions use standard comparison operators inside `{{ }}`; both `then` and `else` accept full task lists, not just single tasks.

**I4 — Tutorial:** Use `ForEach` (not `EachParallel`) because the requirement is strict sequential order. `EachParallel` runs iterations concurrently with no order guarantee — great for throughput, wrong when ordering matters (e.g., rate-limited APIs, dependent writes).
```yaml
- id: process_regions
  type: io.kestra.plugin.core.flow.ForEach
  values: ["us-east", "eu-west", "ap-south"]
  tasks:
    - id: log_region
      type: io.kestra.plugin.core.log.Log
      message: "Processing region: {{ taskrun.value }}"
```
*Key takeaway:* Choosing between `ForEach` and `EachParallel` is a correctness decision, not just a performance one.

**I5 — Tutorial:** `pluginDefaults:` injects shared config into every task of a given `type`, so you don't repeat `level: WARN` 15 times.
```yaml
pluginDefaults:
  - type: io.kestra.plugin.core.log.Log
    values:
      level: WARN
```
*Key takeaway:* This is analogous to a base class setting a default that all subclasses inherit — individual tasks can still override it locally if one specific `Log` task needs a different level.

---

### 🟠 Advanced Answers

**A1 — Tutorial:**
```yaml
- id: fetch_weather
  type: io.kestra.plugin.core.http.Request
  uri: "https://api.open-meteo.com/v1/forecast"
  retry:
    type: constant
    interval: PT15S
    maxAttempt: 4
```
*Key takeaway:* `PT15S` is ISO-8601 duration notation (15 seconds). After 4 failed attempts, the task — and by default the flow — is marked `FAILED`.

**A2 — Tutorial:**
```yaml
errors:
  - id: notify_slack_on_failure
    type: io.kestra.plugin.core.log.Log   # substitute with a real Slack plugin in production
    message: >
      🚨 Flow {{ flow.namespace }}.{{ flow.id }}
      failed on execution {{ execution.id }}.
```
*Key takeaway:* Tasks in `errors:` only run when the main `tasks:` block fails — they have full access to `flow.*` and `execution.*` context variables for rich alerting.

**A3 — Tutorial:**
```yaml
concurrency:
  limit: 1
  behavior: FAIL
```
*Key takeaway:* `behavior: FAIL` immediately rejects the new execution attempt (vs. `QUEUE`, which would hold it until the active run finishes, or `CANCEL`, which kills the *existing* run in favor of the new one). For an ETL job where overlapping runs could corrupt data, `FAIL` is the safest choice.

**A4 — Tutorial:** Split along natural functional boundaries — e.g., `ingest_raw_data`, `transform_data`, `load_warehouse` — each becomes its own flow with clear inputs/outputs. This improves reusability (other pipelines can call `transform_data` too), isolates failures, and makes each piece independently testable.
```yaml
tasks:
  - id: run_transform_step
    type: io.kestra.plugin.core.flow.Subflow
    namespace: practice.advanced
    flowId: transform_data
    inputs:
      source_path: "{{ outputs.run_ingest_step.uri }}"
    wait: true
    transmitFailed: true
```
*Key takeaway:* `wait: true` makes the parent block until the child completes; `transmitFailed: true` propagates the child's failure up to the parent — without it, a failed subflow wouldn't necessarily fail the caller.

**A5 — Tutorial:** Use `WorkingDirectory`. It gives a group of tasks a shared, ephemeral file-system scope so files (not just JSON-serializable outputs) persist between them.
```yaml
- id: wdir
  type: io.kestra.plugin.core.flow.WorkingDirectory
  tasks:
    - id: download_csv
      type: io.kestra.plugin.core.http.Download
      uri: "https://example.com/data.csv"
    - id: read_csv
      type: io.kestra.plugin.scripts.python.Script
      script: |
        import pandas as pd
        df = pd.read_csv("data.csv")
        print(len(df))
```
*Key takeaway:* `outputs.<task_id>` only works for structured, serialized values Kestra explicitly tracks (like a URI to internal storage) — it's not a general-purpose shared filesystem. `WorkingDirectory` is the correct tool when tasks need to read/write literal files by name.

---

### 🔴 Expert / Real-World Answers

**E1 — Tutorial:**
```yaml
id: daily_financial_pipeline
namespace: practice.expert

tasks:
  - id: wdir
    type: io.kestra.plugin.core.flow.WorkingDirectory
    tasks:
      - id: fetch_market_data
        type: io.kestra.plugin.core.http.Request
        uri: "https://api.example.com/market-data"
        retry:
          type: exponential
          interval: PT10S
          maxAttempt: 5

      - id: transform_data
        type: io.kestra.plugin.scripts.python.Script
        script: |
          print("transforming data...")

      - id: send_summary_email
        type: io.kestra.plugin.core.log.Log   # substitute real email plugin
        message: "Summary sent"
        allowFailure: true

errors:
  - id: page_oncall
    type: io.kestra.plugin.core.log.Log   # substitute real Slack/PagerDuty plugin
    message: "🚨 Critical failure in {{ flow.id }}, execution {{ execution.id }}"

finally:
  - id: cleanup_temp
    type: io.kestra.plugin.core.log.Log
    message: "Cleaning temp working directory for execution {{ execution.id }}"
```
*Key takeaway:* This combines four resilience patterns at once — `retry` for transient issues, `allowFailure` for optional steps, `finally` for guaranteed cleanup, and `errors` for hard-failure alerting. In production, layering these is what separates a fragile pipeline from a resilient one.

**E2 — Tutorial:** Replace the `Schedule` trigger with an S3-event-based trigger (e.g., `io.kestra.plugin.aws.s3.Trigger`), which polls (or subscribes to) the bucket and fires an execution as soon as a matching object appears.
```yaml
triggers:
  - id: on_new_file
    type: io.kestra.plugin.aws.s3.Trigger
    bucket: "my-data-bucket"
    prefix: "incoming/"
    interval: PT1M
```
*Trade-offs:*
- **Schedule (polling by time):** simple, predictable load, but wastes runs when there's no new data and adds latency (up to the schedule interval) when data *does* arrive.
- **Event/file trigger:** near-real-time reaction, no wasted runs — but adds complexity (cloud IAM permissions, potential duplicate-trigger handling) and ties your flow's timing to an external system's reliability.

**E3 — Tutorial:**
- **Namespaces:** `company.<team>.<domain>` (e.g., `company.data-eng.ingestion`, `company.marketing.reporting`) — prevents collisions and lets you filter/search by prefix in the UI.
- **Labels:** apply `team`, `cost_center`, and `env` labels to every flow/execution:
```yaml
labels:
  team: data-eng
  cost_center: cc-4821
  env: production
```
*Key takeaway:* Namespace = structural/organizational boundary (also scopes secrets and namespace files); Labels = flexible metadata for filtering and cost attribution. Use both together rather than overloading one for the other's job.

**E4 — Tutorial:**
1. **Fix the trigger first** (correct the cron expression / condition) and deploy the fix so *today's* runs are no longer affected.
2. Verify the corrected trigger works with a manual test execution before relying on backfill.
3. Use Kestra's **backfill** feature on the `Schedule` trigger, specifying the historical date range (the 10 missing days).
4. Backfilled executions run using the *historical* scheduled date as their `execution.scheduleDate` context, not "now" — so any date-dependent logic in the flow behaves correctly.
5. Monitor concurrency: if `concurrency.limit` is set low, backfilled runs may queue or fail depending on `behavior` — temporarily raise the limit or set `behavior: QUEUE` during backfill so historical runs don't clobber each other or the live daily run.
*Key takeaway:* Always fix forward first, confirm correctness on a single manual run, *then* backfill — backfilling a still-broken trigger just multiplies the bad output.

**E5 — Tutorial:** Because a Subflow is itself just an ordinary flow with its own `inputs:`/`outputs:`, you can call it directly with fixed sample inputs from a throwaway "test harness" flow, then use an `If` task to compare its output against an expected value and log a pass/fail message.
```yaml
id: test_compute_risk_score
namespace: practice.expert.tests

tasks:
  - id: run_subflow
    type: io.kestra.plugin.core.flow.Subflow
    namespace: practice.expert
    flowId: compute_risk_score
    inputs:
      portfolio_value: 100000
      volatility_index: 0.18
    wait: true
    transmitFailed: true

  - id: assert_expected_output
    type: io.kestra.plugin.core.flow.If
    condition: "{{ outputs.run_subflow.vars.risk_score == 'MEDIUM' }}"
    then:
      - id: test_passed
        type: io.kestra.plugin.core.log.Log
        message: "✅ TEST PASSED: risk_score matched expected value"
    else:
      - id: test_failed
        type: io.kestra.plugin.core.log.Log
        message: "❌ TEST FAILED: unexpected risk_score"
```
*Key takeaway:* Kestra has no native `assert` task, so the community pattern is: call the subflow with known inputs, compare its declared flow-level output against the expected value inside an `If`, and log a clear pass/fail signal — this can even be wired into CI by checking the test flow's final execution status.