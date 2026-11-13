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
