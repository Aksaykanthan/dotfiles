import type { HookAPI } from "@oh-my-pi/pi-coding-agent/extensibility/hooks";

// Caveman (https://github.com/JuliusBrussee/caveman) — terse output mode,
// wired natively into omp.
//
// caveman has no "pi"/omp entry in its own agent matrix (INSTALL.md lists
// Claude Code, Gemini CLI, opencode, Cursor, Windsurf, and 25+ others, but
// not omp/Pi), and its Claude Code integration relies on a SessionStart hook
// that omp doesn't expose under that name. The closest native equivalent is
// `before_agent_start`, which can inject a message before the first turn —
// this mirrors the "always-on rule file" fallback caveman itself documents
// for hookless agents (Cursor/Windsurf/Cline/Copilot), just delivered via
// omp's hook API instead of a static file the agent may or may not read.
//
// Injected once per session (not every turn) to avoid re-paying the
// activation cost caveman's own docs quote (~1-1.5k input tokens/turn) on
// every single message. Rule text is copied verbatim from
// src/rules/caveman-activate.md in the caveman repo — this file does not
// duplicate or reinterpret their compression policy.
//
// Disable: delete this file (or move it out of ~/.omp/agent/extensions).

const CAVEMAN_ACTIVATE = `Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
- Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
- Pattern: [thing] [action] [reason]. [next step].
- Not: "Sure! I'd be happy to help you with that."
- Yes: "Bug in auth middleware. Fix:"

Switch level: /caveman lite|full|ultra|wenyan
Stop: "stop caveman" or "normal mode"

Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

Boundaries: code/commits/PRs written normal.`;

export default function caveman(pi: HookAPI): void {
  let injected = false;

  pi.on("before_agent_start", async () => {
    if (injected) return;
    injected = true;
    return {
      message: {
        content: [{ type: "text", text: CAVEMAN_ACTIVATE }],
        customType: "caveman-activate",
      },
    };
  });
}
