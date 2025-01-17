require_relative 'provider'

module Documentation
  # A documentation provider which parses a Ghidra manual index file (.idx) and uses it to link to
  # specific pages of online PDFs.
  class GhidraIndexProvider < Provider
    def initialize(name, url, index_text)
      @name = name
      @url = url
      @index_text = index_text

      @index = build_index()
    end

    def documentation_url(ins)      
      mnemonic = ins
        .assembly_format_for_variant(0)
        .split
        .first

      @index[mnemonic]
    end

    # Parse the index text and create a mapping of mnemonics to links.
    # @return [{ String => Link }]
    private def build_index
      @index_text
        .split("\n")
        .reject { it.start_with?('@') } # Comments
        .map { it.split(',').map(&:strip) }
        .to_h do |(mnemonic, page)|
          mnemonic = mnemonic.downcase # For consistency with how we present instructions

          page_url = "#{@url}#page=#{page}"
          link = Link.new(page_url, "\"#{mnemonic}\" (#{@name})")

          [mnemonic, link]
        end
    end
  end
end
