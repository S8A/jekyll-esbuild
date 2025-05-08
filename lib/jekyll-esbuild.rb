# frozen_string_literal: true

require 'pathname'
require "jekyll"
require 'open3'

module Jekyll
  module Esbuild
    class Engine
      def initialize(source, options = {})
        Jekyll.logger.debug "JekyllEsbuild:",
                            "Initializing engine with source:
                             #{source}, options: #{options}"
        @script = File.expand_path(options[:script] || 'node_modules/.bin/esbuild', source)
        unless File.exist?(@script)
          Jekyll.logger.error "JekyllEsbuild:",
                              "#{@script} not found.
                               Make sure esbuild is installed in your
                               Jekyll source."
          exit 1
        end

        @bundle = options.fetch(:bundle, true)
        @minify = options.fetch(:minify, 'environment')
        @sourcemap = options.fetch(:sourcemap, 'environment')
      end

      def process(file_path)
        Jekyll.logger.debug "JekyllEsbuild:", "Processing #{file_path}"

        node_env = ENV.fetch('NODE_ENV', 'development')

        args = [@script, "#{file_path}", "--outfile=#{file_path}", "--allow-overwrite"]
        args << '--bundle' if @bundle

        if @minify == 'always' || (@minify == 'environment' && node_env == 'production')
          args << '--minify'
        end

        if @sourcemap == 'always' || (@sourcemap == 'environment' && node_env == 'development')
          args << "--sourcemap"
        end

        stdout, stderr, status = Open3.capture3(*args)
        unless status.success?
          Jekyll.logger.error "JekyllEsbuild:", "Failed with error: #{stderr}"
          raise "Esbuild failed with status #{status.exitstatus}"
        end

        Jekyll.logger.info "JekyllEsbuild:", "Processed #{file_path}"
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  Jekyll.logger.debug "JekyllEsbuild:", "Site post-write hook triggered."

  engine = Jekyll::Esbuild::Engine.new(site.source, {
    script: site.config.dig('esbuild', 'script'),
    bundle: site.config.dig('esbuild', 'bundle'),
    minify: site.config.dig('esbuild', 'minify'),
    sourcemap: site.config.dig('esbuild', 'sourcemap')
  })

  files = site.config.dig('esbuild', 'files')

  site.static_files.each do |static_file|
    relative_path = static_file.relative_path

    next unless files.nil? ? relative_path.end_with?('.js') : files.include?(relative_path)

    file_path = Pathname.new(static_file.destination(site.dest))

    engine.process(file_path)
  end

  Jekyll.logger.debug "JekyllEsbuild:", "Site post-write hook completed."
end
