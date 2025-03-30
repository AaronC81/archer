require 'erb'
require 'sass-embedded'
require 'fileutils'
require 'pathname'
require 'json'

require_relative 'lib/target'
require_relative 'lib/tablegen/dump'
require_relative 'lib/supp'
require_relative 'lib/load_logger'
require_relative 'lib/adapter'

ROOT_DIR = Pathname.new(__dir__)
APP_DIR = ROOT_DIR/'app'
VIEWS_DIR = APP_DIR/'views'
BUILD_DIR = ROOT_DIR/'build'

SUPPORTED_TARGETS = %w[X86 ARM RISCV PowerPC TriCore J2]

def render_erb(template, output, title: nil)
  @page_title = title

  render_erb_in_layout(output) do
    ERB.new(File.read(template)).result(binding)
  end
end

def render_erb_in_layout(output)
  content = ERB.new(File.read(VIEWS_DIR/'layout.erb')).result(binding)
  write_file content, output
end

def write_file(content, output)
  FileUtils.mkdir_p(output.dirname)
  File.write(output, content)
end

def build_site
  # Load supported architecture data
  targets = SUPPORTED_TARGETS
    .map do |t|
      target = nil
      logger = LoadLogger.collect do
        LoadLogger.debug "=== Loading: #{t} ==="

        LoadLogger.debug "Loading supplementary data"
        data = SupplementaryData.load(File.join(__dir__, 'supp', "#{t}.yaml"))

        LoadLogger.debug "Loading TableGen data"
        dump = TableGen::Dump.load(File.join(__dir__, 'llvm', 'dump', "#{t}.json"))

        LoadLogger.debug "Creating target"
        target = Target.new(t, dump, data)
      end

      # Keep the log messages around so we know what went wrong while loading it
      target.logger = logger

      target
    end

  # Recreate empty build directory
  FileUtils.rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
  FileUtils.mkdir(BUILD_DIR)

  # Copy static assets
  FileUtils.cp_r(APP_DIR/"public\/.", BUILD_DIR)

  # Compile styles
  Dir.entries((APP_DIR/'style').to_s).each do |f|
    path = APP_DIR/'style'/f
    next unless path.file?

    compiled = Sass.compile(path.to_s)

    write_file compiled.css, BUILD_DIR/(path.basename.sub_ext(".css"))
  end

  # Build JavaScript
  FileUtils.mkdir(BUILD_DIR/'js')
  system("npx webpack")
  unless $?.success?
    abort "Error: JavaScript bundle failed. Have you run `npm install`?"
  end

  # Generate homepage
  @targets = targets
  render_erb VIEWS_DIR/'index.erb', BUILD_DIR/'index.html'

  # Generate target pages
  targets.each do |target|
    target_dir = BUILD_DIR/'target'/target.name
  
    @target = target
    @adapter = Adapter.new(target)

    render_erb VIEWS_DIR/'target_index.erb', target_dir/'index.html', title: "#{target.title} - archer"
    render_erb VIEWS_DIR/'target_info.erb', target_dir/'info'/'index.html', title: "#{target.title} info - archer"

    # Write JSON data
    write_file @adapter.adapt_details.to_json, target_dir/'data'/'details.json'
    write_file @adapter.adapt_instructions.to_json, target_dir/'data'/'instructions.json'
  end
end

# For faster testing
if ARGV.delete("--fast")
  SUPPORTED_TARGETS.clear
  SUPPORTED_TARGETS << 'TriCore'
end

case ARGV
when []
  build_site
when ['--watch'], ['-w']
  # MacOS-specific
  Dir.chdir(__dir__) do
    exec("fswatch app lib supp | ruby \"#{File.expand_path(__FILE__)}\" --rebuild-on-stdin")
  end
when ['--rebuild-on-stdin'] # to implement `--watch`
  build_site
  loop do
    $stdin.gets
    build_site
  end
else
  abort "Usage: #{$0} [-w/--watch]"
end
