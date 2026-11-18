# Contributing

Thanks for helping out!

1. Pick an issue, or open one to talk about your idea first. Comment on it so others know you're on it.
2. Fork the repo and create a branch.
3. Run `bin/setup` once, then make your change with tests.
4. Before opening a pull request, make sure these pass:

   ```sh
   bin/rails test
   bin/rubocop
   bin/brakeman --no-pager
   ```

5. Open a pull request that says which issue it closes (for example `Closes #3`).

Keep pull requests small and focused. If you get stuck, ask on the issue. That's what it's for.
