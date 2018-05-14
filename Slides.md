---
title: Slideshows with Pandoc on Github
author: Ivan Lazar Miljenovic
date: 17 January, 2017
...

About this configuration
========================

## Headings

* Pandoc puts top-level headings on their own page

    - I use setext style headers for them to help make them stand out
      in the markdown

* Level-2 headings create new slides

    - I prefer atx style headers for those to help add in metadata
      (e.g. images)

* You can use other headings as well

    - Level-6 headings have been configured in the CSS to help show up
      as image attribution.

## Image-based slide {data-background="images/haskell.png" data-background-color="white"}

* This slide has a background image

* You may need to put attribution last (Pandoc gets confused sometimes).

###### Attribution for image

## Speaker notes

* Pandoc has in-built support for speaker notes with reveal.js (hit
  `s` to reveal them).

*
    ```markdown
    ::: notes

    * Note 1
    * Note 2

    :::
    ```

::: notes

* Note 1
* Note 2

:::

## Other

* reveal.js settings - including specification of the CSS file - are
  set in a YAML block at the bottom of the markdown file.

* You can also abuse YAML blocks to add in comments (e.g. to help
  organise your file, or have a bibliography section with all your
  links).

---
# reveal.js settings
theme: night
transition: concave
backgroundTransition: zoom
center: true
history: true
css: custom.css
...
