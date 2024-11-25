require_relative 'provider'

require 'http'
require 'nokogiri'

module Documentation
  # A documentation provider which links to Félix Cloutier's unofficial x86 documentation.
  class FelixCloutierX86Provider < Provider
    ENDPOINT = 'https://www.felixcloutier.com/x86'

    def initialize
      @mnemonic_links = scrape_documentation_links
    end

    def documentation_url(ins)      
      # Pages are always named after the Intel opcode
      intel_opcode = ins
        .assembly_format_for_variant(1)
        .split
        .first
      
      @mnemonic_links[intel_opcode]
    end

    private def scrape_documentation_links
      links = {}

      raw_content = HTTP.get(ENDPOINT).body.to_s
      xml_content = Nokogiri::XML(raw_content)

      xml_content.css("tr").each do |row|
        # The page URLs are formatted like:
        #   /x86/fld1:fldl2t:fldl2e:fldpi:fldlg2:fldln2:fldz
        # for all of the different Intel mnemonics they cover
        link = row.css("td a")&.first
        next unless link
        href = link.attributes['href']
        next unless /^\/x86\/(.+)$/ === href
        page_name = $1
        mnemonics = page_name.split(':')

        # Get instruction description
        desc = row.css("td").last.text

        # Add link for each mnemonic
        mnemonics.each do |mnemonic|
          links[mnemonic] = Link.new(
            "#{ENDPOINT}/#{page_name}",
            "\"#{desc}\" (Félix Cloutier)"
          )
        end
      end

      links
    end
  end
end
