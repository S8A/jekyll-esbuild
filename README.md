# jekyll-esbuild

This plugin uses esbuild to process the targeted JavaScript static files in a Jekyll site whenever the site is built.


## Installation

Add `jekyll-esbuild` to your `Gemfile` in the `:jekyll_plugins` section to install the gem and enable it in Jekyll automatically (since Jekyll v4):

```ruby
group :jekyll_plugins do
  gem 'jekyll-esbuild'
end
```

For earlier versions of Jekyll, you'll also have to add `jekyll-esbuild` to the `plugins` section of your `_config.yml`:

```yaml
plugins:
  - jekyll-esbuild
```

In any case, don't forget to install `esbuild` using `npm` at the root of your Jekyll source directory:

```bash
npm install esbuild
```


## Configuration

To configure this plugin, add a section called `esbuild` to your `_config.yml` and set one or more of the following options:

- `script`: String path. Default: `node_modules/.bin/esbuild`. Path to esbuild's executable binary in your system. If you installed esbuild locally in your Jekyll source directory as recommended above, the default value should work.
- `bundle`: Boolean (`true` / `false`). Default: `true`. Enables or disables the `--bundle` option that tells esbuild to bundle the files, that is, to inline any imported dependencies into the file itself.
- `minify`: String with three possible values (`always` / `never` / `environment`). Default: `environment`. Specifies whether or not to enable the `--minify` option that tells esbuild to minify the files. If set to `environment`, it enables the option only if the value of `NODE_ENV` environment variable is set to `production`.
- `sourcemap`: String with three possible values (`always` / `never` / `environment`). Default: `environment`. Specifies whether or not to enable the `--sourcemap` option that tells esbuild to generate source maps for the files and link them. If set to `environment`, it enables the option only if the value of `NODE_ENV` environment variable is not set to `production`.
- `files`: List of string paths. Default: not set. Specifies the relative paths of each of the JavaScript static files that you want to process with esbuild. Actually, esbuild also [supports other content types](https://esbuild.github.io/content-types/) besides vanilla JavaScript, so you can use this option to specify TypeScript files or JSX files, for example, but that hasn't been tested yet with this plugin. The paths must be relative to the root of your Jekyll source directory, and they must have a leading slash. If not set, the plugin will process every single static file with `.js` extension in your site.

Example:

```yaml
esbuild:
  script: node_modules/.bin/esbuild
  bundle: true
  minify: environment
  sourcemap: never
  files:
    - /assets/js/main.js
    - /assets/js/another.js
```

If you like the default settings, you can simply use the plugin without adding any settings to your `_config.yml`, or you can set only the settings that you want to change and skip those where you're satisfied with the default value.


## Usage

Build your site with `jekyll build` or `jekyll serve` as usual. This plugin will automatically process the targeted files using esbuild with the configured options, logging to console the paths of the processed files or any error that occurs.

Example console output:

```
Configuration file: /srv/jekyll/_config.yml
            Source: /srv/jekyll
       Destination: /srv/jekyll/_site
 Incremental build: disabled. Enable with --incremental
      Generating... 
     JekyllEsbuild: Processed /srv/jekyll/_site/assets/js/main.js
     JekyllEsbuild: Processed /srv/jekyll/_site/assets/js/another.js
                    done in 1.234 seconds.
 Auto-regeneration: enabled for '/srv/jekyll'
    Server address: http://0.0.0.0:4000/
  Server running... press ctrl-c to stop.
```
