require 'erb'
require 'fileutils'
require 'pathname'

require_relative 'lib/target'
require_relative 'lib/tablegen/dump'
require_relative 'lib/supp'

ROOT_DIR = Pathname.new(__dir__)
APP_DIR = ROOT_DIR/'app'
VIEWS_DIR = APP_DIR/'views'
BUILD_DIR = ROOT_DIR/'build'

def render_erb(template, output)
  render_erb_in_layout(output) do
    ERB.new(File.read(template)).result(binding)
  end
end

def render_erb_in_layout(output)
  FileUtils.mkdir_p(output.dirname)
  content = ERB.new(File.read(VIEWS_DIR/'layout.erb')).result(binding)
  File.write(output, content)
end

def build_site
  # Load supported architecture data
  targets = %w[TriCore J2 X86 RISCV]
    .map do |t|
      puts "=== Loading: #{t} ==="

      puts "Loading supplementary data"
      data = SupplementaryData.load(File.join(__dir__, 'supp', "#{t}.yaml"))

      puts "Loading TableGen data"
      dump = TableGen::Dump.load(File.join(__dir__, 'tblgen_dump', "#{t}.json"))

      puts "Creating target"
      Target.new(t, dump, data)
    end

  # Recreate empty build directory
  FileUtils.rm_rf(BUILD_DIR) if File.exist?(BUILD_DIR)
  FileUtils.mkdir(BUILD_DIR)

  # Copy static assets
  FileUtils.cp_r(APP_DIR/"public\/.", BUILD_DIR)

  # Generate homepage
  @targets = targets
  render_erb VIEWS_DIR/'index.erb', BUILD_DIR/'index.html'

  # Generate each target page
  targets.each do |target|
    @target = target
    @instructions = target.instructions.values

    render_erb VIEWS_DIR/'target_index.erb', BUILD_DIR/'target'/target.name/'index.html'
  end
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
