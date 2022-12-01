<h1 align="center">
  <br>
  snip-lookup.nvim
  <br>
  <br>
  
  ![aoeu](https://user-images.githubusercontent.com/47462344/204839108-6dc32a57-1c4b-4921-911e-5220de4a7de8.gif)
</h1>
<h2 align="center">
  <img alt="PR" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat"/>
  <img alt="Lua" src="https://img.shields.io/badge/lua-%232C2D72.svg?&style=flat&logo=lua&logoColor=white"/>
  <img alt="Rust" src="https://img.shields.io/badge/-Rust-orange"/>
</h2>

Do you have common snippets that you are constantly needing to reference or use?
Do you find yourself with too many things you _want_ as snippets, but not enough time to _create all of them_?
Enter: snip-lookup.nvim!

Create a `yaml` snippets file somewhere on your OS, then start throwing your snippets inside

Your snippets file should follow the below structure:

```
categories:
  <snippet category>:
    icon: <emoji/symbol>
    snippets:
      - <snippet name>: <snippet contents>
      - ...
  ...
```

Example:

```yaml
categories:
  Email Addresses:
    icon: "📧"
    snippets:
      - John Doe: john.doe@gmail.com
      - Jane Doe: jane.doe@gmail.com
  Phone Numbers:
    icon: "☎️ "
    snippets:
      - Jack Black: (111) 111-1111
      - Jill Dill: (222) 222-2222
```
