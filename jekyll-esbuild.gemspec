Gem::Specification.new do |spec|
  spec.name          = "jekyll-esbuild"
  spec.version       = "0.1.0"
  spec.authors       = ["Samuel Ochoa"]
  spec.email         = ["samuelochoap@proton.me"]

  spec.summary       = "A Jekyll plugin to process JavaScript files with esbuild."
  spec.description   = "This plugin uses esbuild to process JavaScript files in a Jekyll site after the site is written."
  spec.homepage      = "https://github.com/S8A/jekyll-esbuild"
  spec.license       = "Unlicense"
  spec.metadata      = {
    "license" => "https://unlicense.org/"
  }

  spec.files         = ["lib/jekyll-esbuild.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 3.0"
  spec.add_dependency "open3"

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", ">= 12.0"
end
