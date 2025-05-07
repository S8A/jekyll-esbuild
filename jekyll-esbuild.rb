# frozen_string_literal: true

require 'pathname'
require 'open3'

module Esbuild
  class Engine
    def initialize(source, options = {})
      @script = File.expand_path(options[:script] || 'node_modules/.bin/esbuild', source)
      unless File.exist?(@script)
        Jekyll.logger.error "Esbuild:", "Esbuild binary not found. Ensure it is installed in your Jekyll source."
        Jekyll.logger.error "Esbuild:", "Couldn't find #{@script}"
        exit 1
      end

      @bundle = options.fetch(:bundle, true)
      @minify = options.fetch(:minify, 'environment')
      @sourcemap = options.fetch(:sourcemap, 'none')
    end

    def process(file_path)
      args = [@script, file_path, "--outfile=#{file_path}"]
      args << '--bundle' if @bundle
      args << '--minify' if @minify == 'always' || (@minify == 'environment' && ENV['NODE_ENV'] == 'production')
      args << "--sourcemap=#{@sourcemap}" unless @sourcemap == 'none'

      stdout, stderr, status = Open3.capture3(*args)
      unless status.success?
        Jekyll.logger.error "Esbuild Error:", stderr
        raise "Esbuild failed with status #{status.exitstatus}"
      end
      Jekyll.logger.info "Esbuild:", "Processed #{file_path}"
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  config = site.config['esbuild'] || {}
  engine = Esbuild::Engine.new(site.source, {
    script: config['script'],
    bundle: config['bundle'],
    minify: config['minify'],
    sourcemap: config['sourcemap'],
  })

  output_dir = site.dest
  files = config['files'] || Dir[File.join(output_dir, '**', '*.js')]

  files.each do |file|
    file_path = File.join(output_dir, file)
    next unless File.file?(file_path)

    engine.process(file_path)
  end
end
