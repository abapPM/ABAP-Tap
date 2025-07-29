METHOD log.

  result =
    create_by_id(
      id     = 'AA01'
      param1 = msg
      level  = if_aunit_constants=>severity-low ).

ENDMETHOD.
