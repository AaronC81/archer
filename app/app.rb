require 'sinatra'
require_relative '../lib/target'
require_relative '../lib/tablegen/dump'
require_relative '../lib/supp'

TARGETS = %w[TriCore J2 X86]
  .map do |t|
    puts "=== Loading: #{t} ==="

    puts "Loading supplementary data"
    data = SupplementaryData.load(File.join(__dir__, '..', 'supp', "#{t}.yaml"))

    puts "Loading TableGen data"
    dump = TableGen::Dump.load(File.join(__dir__, '..', 'tblgen_dump', "#{t}.json"))

    puts "Creating target"
    target = Target.new(t, dump, data)
    [t, target]
  end
  .to_h

get '/target/:target' do
  @target = TARGETS.fetch(params[:target])
  @instructions = @target.instructions.values

  erb :target_index
end

get '/target/:target/info' do
  @target = TARGETS.fetch(params[:target])
  erb :target_info
end

get '/target/:target/instruction/:ins' do
  @target = TARGETS.fetch(params[:target])
  @instruction = @target.instructions.fetch(params[:ins].to_sym)
  erb :target_instruction
end

get '/' do
  @targets = TARGETS
  erb :index
end
