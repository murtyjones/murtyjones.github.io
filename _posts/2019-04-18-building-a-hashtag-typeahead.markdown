---
layout: post
title:  "Building an Instagram Hashtag Typeahead in JavaScript"
date:   2019-04-19 16:37:00 -0400
categories: [tailwind]
tags: [javascript]
---
# Building an Instagram Hashtag Typeahead in JavaScript

At Tailwind, one of our core features is to give users suggestions about hashtags to use when crafting a post, so that our users can maximize the reach of their Instagram posts.

One way that we accomplish this is by providing the list of suggested hashtags that the user can select while writing a post caption — You can see this in the image below.

![The different colors for the suggested hashtags help the user identify the relevance of each suggested tag.](https://cdn-images-1.medium.com/max/2000/1*5TqWDibZjdIXgedY7KGg-Q.png)

*The different colors for the suggested hashtags help the user identify the relevance of each suggested tag.*

One major UX improvement that our design and engineering team collaborated on was to be able to make suggestions as soon as the user starts to type a hashtag. If I start typing `#foo` in the post above, for example, we’d like a list to come up that shows hashtag suggestions including things like `#football` and `#footballgames`.

Enabling a typeahead for users will make creating a post easier and faster when the user has to decide which hashtags to use in the post’s caption.

### The goal

As the user types, we‘d like to suggest hashtags that begin with the letters the user has entered so far. The suggestions should be brought up in context, right below the text that the user is typing so that the user can quickly select one and continue editing the post caption. We also want to provide reach metrics so that the user can choose the best possible tag. Here’s how it will all look when put together:

![*See it in action at [tailwindapp.com](http://tailwindapp.com)*](https://cdn-images-1.medium.com/max/2000/1*V360JEpJEgSQOJEMVI6DAA.png)

*See it in action at [tailwindapp.com](http://tailwindapp.com)*

Sounds pretty straightforward, right? Turns out, there are several technical challenges and constraints that we had to consider.

Let’s walk through the main challenges of building and rendering a typeahead.

## How to detect whether a hashtag is being created/edited

When a user is in the process of editing an Instagram post caption, one of several different things can be true:

1\. The user might be typing a new hashtag or editing an existing one

2\. The user may be focused on a hashtag, but not actually editing the hashtag at the moment

3\. The user could be editing the post caption but not typing a hashtag

In which cases would we want to display a typeahead?

As it turns out, we would like to display the typeahead for case #1, but not cases #2 and #3. Typeaheads are powerful components, but they should be used only in cases where you *know* they are helpful to your user, which is why we only want to show our typeahead when the user is typing a hashtag.

## To render the typeahead or not to render — That is the question

In order to determine whether the typeahead should be shown, we need to get the hashtag (we’ll call that the `activeHashtag`) that the user is creating/editing. To do that, we need:

1\. A `keydown` event handler that will fire every time the user presses a key (or a key combination such as `shift + a`)

The event handler is pretty straightforward. It will call the `getActiveHashtag` method and return the resulting hashtag that it finds:
```js
// Event handler for when the user presses 
// a key inside of the post editor
onKeyPress = event => {
    const content = event.target.value;
    const key = event.key;
    const caretIndex = event.target.selectionStart;
    return getActiveHashtag(content, key, caretIndex)
}
```

2\. A function called `getActiveHashtag` that takes the following arguments:

- `content` — The content of the post caption that the user is editing. E.g. `Hello #world!`

- `key` — The key that the user pressed to trigger this keydown event. We retrieve this from the event object. E.g. if the user presses thea key, then event.key would be a. There’s more information available as part of the event object that can determine whether a key combination was pressed (such as `shift + A`), but in our case, `event.key` is all we care about.

- `caretIndex` — In order to determine what part of the post caption the user is editing, we need to know where the caret is. so that we know exactly what part of the post caption the user is editing. E.g. if the user’s caret is here: `#hello worl|` , then the caret index would be `11`. We get this information from `event.target.selectionStart`.

The `getActiveHashtag` function will either return the hashtag the user is editing (e.g. `#worl`), or `null` if no hashtag is actively being edited by the user.

With these arguments in mind and this desired output (either a string that is the hashtag, or `null`), let’s build some pseudocode test cases that we can use to determine whether or not a user is editing the post caption! At Tailwind, we do Test-Driven Development, using [tape](https://www.npmjs.com/package/tape), to reduce bugs and ensure that we’ve planned our implementation correctly before we write the actual code.

**Case 1 — User is creating or editing a hashtag:**
```js
const test = () => {
    // Arrange
    const content = 'Hello #worl';
    const key = 'l';
    const caretIndex = 11; // End of line

    // Act
    const r = getActiveHashtag(content, key, caretIndex);

    // Assert
    test.assert(r, `#worl`);
};
```
**Case 2 — User’s caret is inside of a hashtag but the user is not editing it:**
```js
const test = () => {
    // Arrange
    const content = 'Hello #world';
    const key = 'ArrowLeft';
    const caretIndex = 11; // Between the `l` and the `d`

    // Act
    const r = getActiveHashtag(content, key, caretIndex);

    // Assert
    test.assert(r, null);
};
```
**Case 3 — User’s caret is not focused on a hashtag:**
```js
const test = () => {
    // Arrange
    const content = '#Hello worl';
    const key = 'l';
    const caretIndex = 11; // End of line

    // Act
    const r = getActiveHashtag(content, key, caretIndex);

    // Assert
    test.assert(r, null);
};
```
Now that we know what results `getActiveHashtag` should return, let’s look at the implementation:
```js
// Keys that never used in the process of
// editing a hashtag.
const nonEditingKeys = [
   'ArrowLeft',
   'ArrowRight',
   'Control',
   'Shift',
   // ...etc
];

// Returns the actively-being-edited hashtag, or null
// if none is found.  
const getActiveHashtag = (content, key, caretIndex) => {
    // If the user pressed a key that isn't a character, they
    // are not actively editing a hashtag:
    if (nonEditingKeys.includes(key)) {
        return null;
    }

    // Figure out what word or hashtag the user is editing
    // using the caret position and the content:
    const activeWordOrHashtag = extractActiveWordOrHashtag(content, caretIndex);

    // if the word that the user is editing is a hashtag, return it.
    // otherwise, return null.
    return activeWordOrHashtag[0] === '#' ? activeWordOrHashtag : null;
};
```
You’ll notice that we have a supporting function, `extractActiveWordOrHashtag`, that is responsible for getting the word or hashtag that the user is editing from the post caption. Here’s how it looks:
```js
// Regex pattern that matches to a word or a hashtag.
// Test it out here: [https://regex101.com/r/0Bl07o/2](https://regex101.com/r/0Bl07o/2)
const hashtagOrWordRegex = /#*\w.*/g;

// Gets the word that the user's caret is positioned on.
const extractActiveWordOrHashtag = (content, caretIndex) => {
    // First, backtrack until we find a character that can't
    // be part of a word or hashtag.
    let index = caretIndex;
    let character = content[index];
    do {
      let matches = char.match(hashtagOrWordRegex);
      // if this character is not part of a hashtag (e.g.
      // it's a space or a period), return the word or
      // hashtag in front of it.
      if (!matches || !matches.length) {
        return content
           .slice(index + 1, content.length)
           .match(hashtagOrWordRegex)[0];
      }
    // Otherwise, go to the previous character
    index -= 1
    } while (index > 0)
}
```
## Rendering the Typeahead using React

Thanks to our keydown handler and `getActiveHashtag`, the logic for whether or not to render the typeahead is in place. In our keydown handler, we return the result of `getActiveHashtag`. If this result isn’t `null`, we know that we need to render the typeahead; so we can pass `activeHashtag` as a prop to our `HashtagTypeahead` component and use it it in the render method like so:
```js
class HashtagTypeahead extends Component {

    ...

    render () {
        // If the user is editing a hashtag,
        // render the typeahead to give the
        // user suggestions for hashtags to use
        if (this.props.activeHashtag) {
            return (
                <HashtagTypeaheadMenu
                    activeHashtag={this.props.activeHashtag}
                    hashtagOptions={...}
                    onSelect={...)
                />
            )
        }
        // Otherwise, return nothing
        return null;
    }
}
```
I abstracted away some of the React implementation details, because how this is done depends on the specific typeahead library being used; picking a typeahead library and implement it could easily be its own blog post! At Tailwind, we use React extensively and have some internally-built components that do typeaheads for us. Some excellent off-the-shelf typeahead components include [React Bootstrap Typeahead](https://www.npmjs.com/package/react-bootstrap-typeahead) or [React Autosuggest](https://react-autosuggest.js.org/). These might spare you the time and energy of building your own typeahead.

This is my first project since starting at Tailwind and I had a ton of fun working on it. If you’re interested in solving interesting frontend and backend problems, [we’re hiring](https://www.tailwindapp.com/careers)!
