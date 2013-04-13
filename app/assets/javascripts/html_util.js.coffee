# Internal: Utilities for working with HTML.
@HTMLUtil =
  # Internal: Escapes characters in str unsafe for usage in HTML attributes.
  escapeAttr: (str) ->
    str?.replace(/[^\w-]/g, "\\$&")
  # Internal: Unescapes backslash-escaped characters in str.
  unescapeAttr: (str) ->
    str?.replace(/\\(.)/g, "$1")
