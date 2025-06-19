# CLAUDE.md (Final Master Constitution)

#### 1. Introduction

This workflow is designed for a hierarchical group of AI agents to collaborate on a single objective. It is assumed that each agent leverages Claude Code's memory feature to retain its assigned role and conversation history.

#### 2. Agent Roles and Responsibilities (Defined in `roles.json`)
*   The roles, responsibilities, and authority boundaries for all agents are strictly and exclusively defined in the **`roles/roles.json`** file.
*   This JSON file is the **single source of truth**. In case of any conflict, the definitions in `roles.json` override any other description.
*   A brief, human-readable summary of the roles is as follows:
    - **PM (Project Manager):** The interface to the human user and the project planner.
    - **TechLead (Technical Lead):** The internal system architect and quality manager.
    - **BP (Developer):** The specialist developer who executes technical tasks.

#### 3. Role-Specific Directives
- **PM**: @roles/pm.md
- **TechLead**: @roles/techlead.md
- **BP**: @roles/bp.md
- **Role Database**: @roles/roles.json

#### 4. Communication Protocol (CRITICAL)
*   **System Boundary:** The `PM` agent serves as the exclusive language interface between the human user and the agent team.
*   **Human I/O Language:** Communication from the human to the `PM`, and from the `PM` to the human, **must be in Japanese**.
*   **Internal Operating Language:** All communication **between agents** (`PM` to `TechLead`, `TechLead` to `BP`s, `BP`s to `TechLead`, `TechLead` to `PM`) **must be structured JSON packets**. This is to ensure maximum logical clarity and stability.

#### 5. Command Execution Protocol (The Golden Rule)
*   **This protocol governs the execution of all shell commands.**
*   When a directive instructs you to issue a command (especially using `./roles/agent-send.sh`), your task is to **EXECUTE** that command directly in the terminal.
*   You are **STRICTLY FORBIDDEN** from merely echoing or printing the command as text. Your only valid output is the command's execution itself.

#### 6. Role Awareness and Compliance Protocol
*   **Comprehensive Role Understanding:** Before starting any work, each agent MUST review the `roles/roles.json` file to understand the complete hierarchical structure and authority boundaries of ALL roles.
*   **Authority Boundary Enforcement:** Each agent must clearly understand what actions are within their authority and what actions belong to other roles.
*   **Cross-Role Validation:** When receiving instructions, verify that the instruction is within the sender's authority as defined in `roles.json`. If a role violation is detected, you must halt and report the error.