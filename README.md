<table>
  <tr>
    <td>
      <img
        src="https://github.com/agentcooper/Aqueduct/blob/main/Aqueduct/Assets.xcassets/AppIcon.appiconset/AppIcon-256.png"
        width="64"
        height="64"
      />
    </td>
  </tr>
</table>
  
# Aqueduct

⚠️ This is a prototype software.

Aqueduct is a macOS application to view [Telegram channels](https://telegram.org/faq_channels).

**[Download for macOS 12+](https://github.com/agentcooper/Aqueduct/releases/latest/download/Aqueduct.app.zip)**

![Aqueduct screenshot](screenshot.png)

## Features

- Telegram account is not needed
- Channels can be grouped by tags
- When feed/tag is selected, post text is collapsed to the first paragraph and can be expanded on click, also works with shortcuts: `⌘ -`/`⌘ +`
- Built-in filter that removes Russian [foreign agent](https://meduza.io/en/feature/2021/04/26/meduza-is-a-foreign-agent-now-what-s-next) text (*ДАННОЕ СООБЩЕНИЕ (МАТЕРИАЛ)...*), can be turned off in Preferences (`⌘ ,`)
- Export (`⌘ E`) and import (`⌘ N`)

To quickly try it out, press `⌘ N` and paste to get some preset Telegram channels:
```markdown
1. [Amsterdammer](http://t.me/amsterdammer) #Culture
2. [addmeto](http://t.me/addmeto) #Technology
3. [Пивоваров (Редакция)](http://t.me/redakciya_channel) #Russia
4. [Медуза — LIVE](http://t.me/meduzalive) #Russia
5. [Backtracking](http://t.me/backtracking) #Technology
6. [Антон Долин](http://t.me/anton_dolin) #Culture
7. [r/ретранслятор](http://t.me/retra) #Memes
8. [Уроки истории с Тамарой Эйдельман](http://t.me/eidelman) #Culture
9. [N + 1](http://t.me/nplusone) #Technology
10. [Новая газета](http://t.me/novaya_pishet) #Russia
11. [Медиазона](http://t.me/mediazzzona) #Russia
12. [Pigeons in The Hague](http://t.me/pigeonsdenhaag) #Culture
```

## Things that do not work

- Only recent posts are fetched for every channel, app does not fetch on scroll
- Stickers are not shown

## Name

Telegram has channels. Word "channel" can refer to "the path of a narrow body of water". [Aqueduct](https://en.wikipedia.org/wiki/Aqueduct_(water_supply)) is a construction that helps to manage the water flow.