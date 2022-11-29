<h1 align="center">
  <br>
  snip-lookup.nvim
  <br>
  <!-- <br> -->
  <!-- put gif here -->
  <!-- <br> -->
</h1>
<h2 align="center">
  <img alt="PR" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat"/>
  <img alt="Lua" src="https://img.shields.io/badge/lua-%232C2D72.svg?&style=flat&logo=lua&logoColor=white"/>
</h2>

Do you have common snippets that you are constantly needing to reference or use?
Do you find yourself with too many things you _want_ as snippets, but not enough time to _create all of them_?
Enter: snip-lookup.nvim!

Create a `yaml` snippets file somewhere on your OS, then start throwing your snippets inside

Each root-level entry in your file should follow the below structure:

```yaml
<Snippet Category>:
  icon: <emoji/symbol>
  snippets:
    - <snippet name>: <snippet contents>
    - ...
```

Example:

```yaml
Email Addresses:
  icon: 📧
  snippets:
    - john: john.doe@gmail.com
    - jane: jane.doe@gmail.com
    - robert: rob.lastname@yahoo.com
    - dvorak: d.aoeuhts@long.email.domain.com
Phone Numbers:
  icon: ☎️
  snippets:
    - john: (111) 111-1111
    - jane: (222) 222-2222
    - robert: (333) 333-3333
    - dvorak: (444) 444-4444
```
