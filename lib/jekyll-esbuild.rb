# frozen_string_literal: true

require 'pathname'
require 'jekyll'
require 'open3'

module Jekyll
  module Esbuild
    # Class that applies esbuild to JavaScript files using specified options
    class Engine
      def initialize(source, options = {})
        Jekyll.logger.debug 'JekyllEsbuild:', 'Initializing engine'
        @script = File.expand_path(options[:script] || 'node_modules/.bin/esbuild', source)
        unless File.exist?(@script)
          Jekyll.logger.error 'JekyllEsbuild:', "Script #{@script} not found."
          exit 1
        end

        @bundle = options.fetch(:bundle, true)
        @minify = options.fetch(:minify, 'environment')
        @sourcemap = options.fetch(:sourcemap, 'environment')
      end

      def get_command_args(file_path)
        is_prod = ENV.fetch('NODE_ENV', 'development') == 'production'
        args = [@script, file_path.to_s, "--outfile=#{file_path}", '--allow-overwrite']
        args << '--bundle' if @bundle
        args << '--minify' if @minify == 'always' ||
                              (@minify == 'environment' && is_prod)

        args << '--sourcemap' if @sourcemap == 'always' ||
                                 (@sourcemap == 'environment' && !is_prod)
        args
      end

      def process(file_path)
        args = get_command_args(file_path)
        _, stderr, status = Open3.capture3(*args)
        unless status.success?
          Jekyll.logger.error 'JekyllEsbuild:', "Failed with error: #{stderr}"
          raise "Esbuild failed with status #{status.exitstatus}"
        end
        Jekyll.logger.info 'JekyllEsbuild:', "Processed #{file_path}"
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  Jekyll.logger.debug 'JekyllEsbuild:', 'Site post-write hook triggered.'

  options = {
    script: site.config.dig('esbuild', 'script'),
    bundle: site.config.dig('esbuild', 'bundle'),
    minify: site.config.dig('esbuild', 'minify'),
    sourcemap: site.config.dig('esbuild', 'sourcemap')
  }
  engine = Jekyll::Esbuild::Engine.new(site.source, options)

  files = site.config.dig('esbuild', 'files')

  site.static_files.each do |static_file|
    relative_path = static_file.relative_path

    next unless files.nil? ? relative_path.end_with?('.js') : files.include?(relative_path)

    file_path = Pathname.new(static_file.destination(site.dest))

    engine.process(file_path)
  end

  Jekyll.logger.debug 'JekyllEsbuild:', 'Site post-write hook completed.'
end
