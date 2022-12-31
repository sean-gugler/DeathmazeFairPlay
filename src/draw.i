; 0-based indexing for consistency with zp_row,zp_col convention

.define modulo(val,mod) ((val) - ((val)/(mod)) * mod)

.define raster(row,col,line) (screen_HGR2 + ((row)/8 * 40) + (modulo((row),8) * $80) + ((line) * $400) + (col))
.define raster_hi(row,col,line) .hibyte(raster row,col,line)
.define raster_lo(row,col,line) .lobyte(raster row,col,line)
