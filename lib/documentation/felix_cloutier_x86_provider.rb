require_relative 'provider'

module Documentation
  # A documentation provider which links to Félix Cloutier's unofficial x86 documentation.
  class FelixCloutierX86Provider < Provider
    def documentation_url(ins)
      # TODO: test existence, could scrape table on index first
      
      # Pages are always named after the Intel opcode
      intel_opcode = ins
        .assembly_format_for_variant(1)
        .split
        .first
      
      if intel_opcode
        Link.new(
          "https://www.felixcloutier.com/x86/#{intel_opcode.downcase}",
          "Documentation (Félix Cloutier)"
        )
      else
        nil
      end
    end
  end
end
