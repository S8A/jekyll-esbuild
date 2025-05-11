# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-esbuild'
  spec.version       = '0.1.1'
  spec.authors       = ['Samuel Ochoa']
  spec.email         = ['samuelochoap@proton.me']

  spec.summary       = 'Jekyll plugin for processing JavaScript files with esbuild.'
  spec.description   = <<~DESCRIPTION
    This plugin uses esbuild to process the targeted JavaScript static
    files in a Jekyll site whenever the site is built. By default, it
    targets all static files with .js extension, but it can be
    configured to target only the files specified in a list, which
    also allows including files of other content types supported by
    esbuild, such as TypeScript or JSX (still untested with this
    plugin, however). There are also other options to toggle bundling,
    minification, and source maps.
  DESCRIPTION
  spec.homepage      = 'https://github.com/S8A/jekyll-esbuild'
  spec.license       = 'Unlicense'

  if spec.respond_to?(:metadata)
    spec.metadata['license'] = 'https://unlicense.org/'
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files         = ['lib/jekyll-esbuild.rb']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'jekyll', '>= 3.0'
  spec.add_dependency 'open3'

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'rake', '>= 12.0'
  spec.add_development_dependency 'rubocop'
end
