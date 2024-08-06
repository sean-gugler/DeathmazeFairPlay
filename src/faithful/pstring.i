; Pascal-style string, prefixed by length
  .macro Pstring str
    .byte .strlen(str), str
  .endmacro
