# MEMORY.md

## Superpowers Skills 集合

**来源:** obra/superpowers (GitHub)  
**安装路径:** `/root/.openclaw/skills/superpowers/`  
**加载时间:** 2026-03-14

### 已安装 Skills (14个)

| Skill | 触发条件 | 说明 |
|-------|----------|------|
| `superpowers:brainstorming` | 任何创造性工作之前 | 头脑风暴流程，探索需求并获得设计批准后才进入实现 |
| `superpowers:dispatching-parallel-agents` | 2+ 独立任务无依赖时 | 并行分派代理处理多个独立问题 |
| `superpowers:executing-plans` | 有书面实施计划时 | 在独立会话中按计划执行任务 |
| `superpowers:finishing-a-development-branch` | 实现完成、测试通过后 | 完成开发分支（合并/PR/清理） |
| `superpowers:receiving-code-review` | 收到代码审查反馈时 | 技术性评估，验证后实施，不盲目接受 |
| `superpowers:requesting-code-review` | 完成任务或主要功能后 | 请求代码审查 |
| `superpowers:subagent-driven-development` | 实施独立任务计划时 | 当前会话中执行，每任务新鲜子代理+审查 |
| `superpowers:systematic-debugging` | 遇到任何 bug/测试失败时 | 系统化调试，先找根因再修复 |
| `superpowers:test-driven-development` | 实现功能或修复 bug 前 | TDD 红-绿-重构循环 |
| `superpowers:using-git-worktrees` | 开始需要隔离的功能工作时 | 创建隔离的 git 工作树 |
| `superpowers:using-superpowers` | 每次对话开始时 | 如何发现和使用 skills |
| `superpowers:verification-before-completion` | 声称完成之前 | 验证后才声明成功 |
| `superpowers:writing-plans` | 有多步骤任务的需求时 | 编写详细实施计划 |
| `superpowers:writing-skills` | 创建新 skill 时 | skill 创建的 TDD 方法论 |

### 核心原则汇总

1. **brainstorming** → 先设计，后实现，获得批准才动手
2. **TDD** → 红-绿-重构，先写测试
3. **systematic-debugging** → 找根因，不猜症状
4. **verification-before-completion** → 先验证，后声明
5. **using-superpowers** → 1% 可能适用就调用 skill

### 典型工作流

```
需求 → brainstorming → writing-plans → using-git-worktrees
                                        ↓
                    subagent-driven-development / executing-plans
                                        ↓
                    requesting-code-review (每任务后)
                                        ↓
                    finishing-a-development-branch
```
