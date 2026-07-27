import type { HookAPI } from "@oh-my-pi/pi-coding-agent/extensibility/hooks";

// RTK auto-rewrite for omp's Bash tool.
//
// omp's `tool_call` hook can only block or allow — it cannot rewrite the
// command in place the way Claude Code's `updatedInput` mechanism does
// (see the "What hooks cannot mutate" section of the hooks doc). So this
// mirrors rtk's own Claude Code PreToolUse hook (.claude/hooks/rtk-rewrite.sh)
// as closely as the API allows: `rtk rewrite <cmd>` is the single source of
// truth for the mapping (never duplicated here), and when it finds an
// equivalent we block the raw command and hand back the compressed form as
// the block reason so the agent retries with it — self-correcting instead of
// a silent no-op.
//
// rtk rewrite exit codes: 0 = rewrite, auto-allow-equivalent · 1 = no match,
// pass through · 2 = deny rule, pass through · 3 = rewrite, but flagged for
// confirmation. Only 1 and 2 mean "nothing to do here"; 0 and 3 both carry a
// usable rewritten command on stdout (matches the shell hook's own case
// statement).

export default function rtkRewrite(pi: HookAPI): void {
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return;

    const cmd = String((event.input as Record<string, unknown>).command ?? "");
    if (!cmd || cmd.includes("<<")) return; // empty or heredoc — rtk skips these too
    if (cmd.trimStart().startsWith("rtk ")) return; // already rewritten

    let proc: Bun.SyncSubprocess<"ignore", "pipe"> | undefined;
    try {
      proc = Bun.spawnSync(["rtk", "rewrite", cmd], {
        stdout: "pipe",
        stderr: "ignore",
      });
    } catch {
      return; // rtk not on PATH — pass through silently
    }
    if (!proc) return;

    if (proc.exitCode !== 0 && proc.exitCode !== 3) return; // 1 (no match) or 2 (deny)

    const rewritten = new TextDecoder().decode(proc.stdout).trim();
    if (!rewritten || rewritten === cmd) return;

    return {
      block: true,
      reason: `rtk has a compressed equivalent for this command — rerun as:\n${rewritten}`,
    };
  });
}
