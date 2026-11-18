# Changelog

All notable changes to Helpdesk are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-11-18

The first public release: a self-hosted shared inbox for small support teams.

### Email
- Incoming email becomes tickets through Action Mailbox, and replies thread onto the right ticket.
- Quoted text is stripped from email replies.
- Attachments on incoming email are saved to the ticket.
- Auto-replies and bounces are ignored, so two helpdesks can't email each other forever.
- Multiple inboxes (for example support@ and billing@). Replies go out from the ticket's inbox.

### Working tickets
- Three-pane inbox: views and inboxes on the left, the ticket list in the middle, the conversation and customer details on the right.
- Each ticket shows how long the customer has been waiting, and open views list the longest-waiting tickets first.
- Assign tickets, change status and move tickets between inboxes. Changes save instantly.
- Internal notes that agents see and customers don't.
- Canned replies with placeholders such as the customer's and agent's names.
- Send and close in one step.
- Tags and saved views.
- Full-text search across subjects, messages and customers (SQLite FTS5).
- Keyboard shortcuts: ⌘K / Ctrl+K to search, `/` for canned replies, ⌘↵ / Ctrl+↵ to send.
- Live updates with Turbo Streams, so the list and ticket refresh as teammates work.
- Email notification when a teammate assigns you a ticket.

### Customers
- A private portal link for each ticket, where the customer can read and reply.
- A one-click satisfaction rating after a ticket closes, with the score on the overview.

### Running it
- Admin role for inviting, deactivating and reactivating agents.
- Pending tickets close automatically after a configurable number of days.
- Deploy guide for a single server, and a Docker image published to `ghcr.io/royalpriest/helpdesk`.
- Codespaces setup with demo data, so anyone can try it in the browser.
- Browser tests for the main flows, plus CI for tests, lint and security scans.

[Unreleased]: https://github.com/royalpriest/helpdesk/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/royalpriest/helpdesk/releases/tag/v0.1.0
