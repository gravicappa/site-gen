# Site-gen

It is a relatively simple script for generating static sites from a tree of
markdown files. It has features:

  * appearance can be customized via templates
  * configurable markdown engine
  * can manage multilingual site

## Usage

If you just want to process your site type

    ./site-gen <docroot>

If your site is multilingual and you want your apache to make use of
HTTP request flag Accept-Language you can use convenience scripts

    ./build <docroot>

build executes next tools:

* configure
* site-gen
* postprocess

`configure` makes copy of template files from templates directory to docroot
and constructs .htaccess accordingly to language directories.

`site-gen` generates html files from md ones.

`postprocess` compresses new html files in order to save Internet bandwidth
and to speed up site loading.

### Sample Apache2 configuration

  In shell:

    sudo a2enmod headers
    sudo a2enmod rewrite
    sudo a2enmod expires

  In apache site configuration file /etc/apache2/sites-enabled/mysite:

    ...
    Alias /webroot "/real/directory"
    <Directory "/real/directory">
      DirectoryIndex index.html
      Options FollowSymLinks MultiViews
      AllowOverride All
      Order allow, deny
      allow from all
    </Directory>
    ...

  Note, that `/webroot/` is value for webroot parameter in conf file.

## Docroot structure

    <docroot>/
      conf
      index.md
      common.png
      _ru/
        index.md
        О нас.md
      _en/
        index.md
        about.md
      Subdir1/
        _ru/
          conf
          index.md
          one.md
          one.name
        _en/
          conf
          index.md

## Languages

Directory `dir/_<lang>` contains files for language *<lang>* for directory
`dir`. That means that in your directory `subone`

    subone/
      img1.png
      img2.png
      _en/
        index.md
        Help.md
      _ru/
        index.md
        Справка.md

for language *en* will be processed these files: `img1.png`, `img2.png`,
`_en/index.md`, `_en/Help.md`.

## File order

Files and directories appear in nav menu sorted lexicographically. Directories
always go first. If you want to change order of items you can add numbers to
your files names:

    dir/
      1_c.md
      2_b.md
      3_a.md
      subdir1/
      1_subdir2/

In nav menu such files will be seen without numbers, so for `dir` above menu
will look like:

    [subdir2/ subdir1/ c b a]

## conf file contents

File `conf` is an ordinary sh-file which is sourced by site-gen. When
processing a directory first `<dir>/conf` is sourced then
`<dir>/_<language>/conf`.

Sample conf:

    webroot='/wiki/'
    webname='Wiki'
    not_found_page='404/404.html'
    allowed_files='css html jpg png js ico gif tiff svg txt'
    template='path/template'
    nav_template='path/nav_template'
    path_template='path/path_template'
    name='Directory name'
    show=(yes|true|1|no|false|0)
    export tpl_X1=Value1
    export tpl_X2=Value2

    process_md() {
      tools/my_md_toolXX | sundown | tools/my_html_toolYY
    }

- *webroot*: sets `webroot` variable. `webroot` is a URL prefix of wiki.
- *webname*: is a name of root node in wiki.
- *not_found_page*: page is shown on 404 error
- *allowed_files*: list of file extensions, represent file types which
  are allowed to send to user. Try to get other files will result 404 error.
  If *allowed_files* is empty then every file is allowed to be sent to user.
- *template*: relative to docroot path to template file.
- *path_template*: relative to docroot path to path template script.
- *nav_template*: relative to docroot path to nav template script.
- *name*: sets displayed name of directory (useful for naming directories in
  different languages).
- *show*: sets whether directory is displayed on navigation menus
- *tpl_VAR*: sets variable for substitution in template. `&$VAR;` entry in
  template is replaced by exported variable `tpl_VAR`.
- *process_md*: is document processing function described below.

Variables *webroot* and *webname* should be used only in `<docroot>/conf` and
`<docroot>/_<language>/conf`.

Variables *not_found_page* and *allowed_files* should be used only in
`<docroot>/conf`.

### process_md function

process_md is a sh-function that can be redefined in `<docroot>/conf`. This
function converts source (markdown) file to html. Markdown file data goes to
its standard input and its standard output emits generated html. Variables
*webroot*, *webname* and *file* are exported to its environment. *file*
variable contains path (relative to `<docroot>`) of processed file. Also
exported in respective `conf` *tpl_XXX* variables are also visible there.
process_md is executed in `<docroot>` directory.

A typical usage:

    process_md() {
      tools/my_md_toolXX | tools/galery | sundown | tools/my_html_toolYY
    }

Where `tools/my_md_toolXX` and `tools/galery` are some markdown processing
scripts (`galery` script is provided with site-gen, you can find it in
`tools` directory). [Sundown](https://github.com/tanoku/sundown) is a markdown
processing tool. And `tools/my_html_toolYY` is some html processing tool.

## Names of items

Name of directory item can be configured in directory's `conf` file. If you
want that `sample.md` is listed in navigation as `A` then create file
`sample.name` with `A` as contents.

## Templates

### `<docroot>/template`

`<docroot>/template` file is an ordinary html-document which contains
placeholders for content items. Known placeholders are:

- *&$document;*: document's full name (e.g. *ChapterA/SectionB/SubsectionC*),
- *&$webroot;*: contents of *webroot* variable (see `conf` files description),
- *&$path;*: navigational item to move from current position to homepage,
- *&$nav;*: navigational menu to move to items in current section,
- *&$content;*: document's content.

Placeholders *&$path;*, *&$nav;*, *&$content;* must be the only items in line:

**wrong:**

    <div id='nav'>&$nav;</div>

**right:**

    <div id='nav'>
      &$nav;
    </div>

You can define custom placeholders for template in `conf`.

### `<docroot>/nav_template`

`<docroot>/nav_template` is an AWK script that is responsible to navigational
menu generation (*$nav* placeholder). It is invoked with `this` variable set
to current document relative name. Items are fed to its stdandard input per
line formatted like this: `flag<tab>name<tab>url` where

- *flag*: if it is `*` then item is a link, if it equals to `=` then item is a
  text;
- *name*: name of item;
- *url*: url of item.

### `<docroot>/path_template`

`<docroot>/path_template` is an AWK script that draws path navigational menu
(*$path* placeholder). It is invoked with `this` variable set to current
document relative name. Items are fed to its standard input per line formatted
like this: `name<tab>url` where

- *name*: name of item,
- *url*: url of item.
