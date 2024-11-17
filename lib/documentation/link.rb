module Documentation
  # A link to some external documentation.
  Link = Struct.new('Link',
    # [String] The URL to the documentation.
    :url,

    # [String] The text to use when rendering the link.
    :text,
  )
end
