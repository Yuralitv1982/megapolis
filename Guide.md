---

### Guide.md

```markdown
# Operating Manual and Freedom

## 1. Your New Superpowers (How it works)

* **`ll`** — View the file list beautifully. This is a shortcut for "list". Now you’ll see them with icons, colors, and sizes.
* **`z <folder_name>`** — Teleportation. You no longer need to type long paths like `/home/user/projects/my_site`. Just type `z site`, and the system will figure out where you want to jump. It learns from your actions.
* **`micro <file>`** — Your new editor. Don't be afraid. It’s like Notepad in Windows. The mouse works, text selection works, and it uses familiar shortcuts like **Ctrl + S** (save) and **Ctrl + Q** (exit).
* **`Ctrl + R`** — Time Machine (Smart History). You’ll never lose a successful command again. Press it and start typing part of a command you wrote yesterday or three days ago, and it will appear instantly.
* **`yazi`** — File Manager. If you’re tired of commands, just type this. It opens a full-featured file explorer where you can navigate with arrow keys, browse folders, and preview images directly in the terminal.

## 2. Safety and Rollback

* **Backups:** Our script doesn't break anything. It doesn't delete your old settings; it carefully renames them to `.bak`.
* **Timeshift (Your Insurance):** We strongly recommend installing this program. It’s like "Restore Points" in Windows. Take a system snapshot, and you can experiment as much as you want. Messed up? System broken? Roll back in 2 minutes. Use it through the GUI or terminal. This is your total freedom of action.

## 3. Recommendations: How Not to Lose Your Mind

We’ve set up the environment, but if you prefer working in full IDEs, that’s perfectly fine. They will work even better now:
* **WebStorm / VS Code:** Install them freely; they play very well with our terminal setup.
* **What if something goes wrong?** If something hangs, press **Ctrl + C**. This is the universal "brake" in Linux. If you have questions or the script throws an error, feel free to post in the GitHub Issues.

## 4. How to Customize Everything (Freedom)

* **Themes:** Go to `~/.config/starship.toml` to change the rocket icon to anything else.
* **Your own commands:** Open `~/.zshrc` to add your own aliases (command shortcuts).
