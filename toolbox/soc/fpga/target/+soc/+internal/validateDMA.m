function result = validateDMA( fifoDepth, mm_dw, s_dw, bsize, type, BlkName )
result = hdlvalidatestruct;
mm_dw = str2double( mm_dw );
s_dw = str2double( s_dw );

if fifoDepth > 32 || fifoDepth < 2
result( end  + 1 ) = hdlvalidatestruct( 2, message( 'soc:msgs:checkFpgaADIDmaFifoSize', type, BlkName ) );
end 


if all( mm_dw ~= [ 32, 64, 128, 256, 512, 1024 ] )
result( end  + 1 ) = hdlvalidatestruct( 1, message( 'soc:msgs:checkFpgaADIDmaMMDataWidth', type, BlkName ) );
end 


if all( s_dw ~= [ 16, 32, 64, 128, 256, 512, 1024 ] )
result( end  + 1 ) = hdlvalidatestruct( 1, message( 'soc:msgs:checkFpgaADIDmaStreamDataWidth', BlkName ) );
end 


if ~isempty( bsize )
max_burst_size = min( 4096, 256 * ( mm_dw / 8 ) );
max_burst_length = max_burst_size * 8 / s_dw;
burst_size = ceil( bsize * s_dw / 8 );
if burst_size > max_burst_size
result( end  + 1 ) = hdlvalidatestruct( 2, message( 'soc:msgs:checkFpgaADIDmaBurstSize', max_burst_length, type, BlkName ) );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpm0OYME.p.
% Please follow local copyright laws when handling this file.

