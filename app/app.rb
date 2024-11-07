require 'sinatra'
require_relative '../lib/target'
require_relative '../lib/tablegen/dump'

TARGETS = %w[X86 TriCore J2]
  .map do |t|
    puts "Loading: #{t}"
    dump = TableGen::Dump.load(File.join(__dir__, '..', 'tblgen_dump', "#{t}.json"))
    target = Target.new(t, dump)
    [t, target]
  end
  .to_h

get '/target/:target' do
  @target = TARGETS.fetch(params[:target])

  if params[:filtered]
    @instructions = @target.instructions.values

    @mnemonic_filter = params[:mnemonic]
    if !(@mnemonic_filter.nil? || @mnemonic_filter.empty?)
      # TODO: actually use mnemonics - this is searching the entire instruction, bad
      @instructions.filter! { |i| i.assembly_format.include?(@mnemonic_filter) }
    end

    @store_filter = (params[:store] == 'on')
    @instructions.filter!(&:may_store?) if @store_filter

    @load_filter = (params[:load] == 'on')
    @instructions.filter!(&:may_load?) if @load_filter
  end

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
