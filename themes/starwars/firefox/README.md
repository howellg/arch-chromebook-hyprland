# Imperial Command Firefox

Copy `imperial.css` and `tie-fighter.svg` into the active Firefox profile’s
`chrome` directory. Find the profile directory in Firefox’s `about:support`.
Add this line at the top of `chrome/userChrome.css`, before any styling rules:

```css
@import url("imperial.css");
```

Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`
and restart Firefox. Remove the import and restart to restore the previous
appearance. The stylesheet targets Firefox’s browser window and retains its
native controls, button actions and website favicons.

For Imperial HoloNet on Firefox Home and New Tab, also copy `holonet.css`,
`holonet-wordmark.svg`, and `holonet-viewport.svg` into the same directory.
Add `@import url("holonet.css");` at the top of `chrome/userContent.css`.
Restart Firefox. Remove that import and restart to restore the stock pages.

For the minimal console layout, turn off Recent Activity and Weather in
Firefox Home settings. In Firefox 160 the corresponding
`browser.newtabpage.activity-stream.` preferences are
`feeds.section.highlights`, `showWeather`, and `widgets.weather.enabled`.
Set these to false in `about:config` to cover both weather layouts.
