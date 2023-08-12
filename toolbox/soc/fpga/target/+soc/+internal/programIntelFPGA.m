function programIntelFPGA( bitstreamfile, chainposition )








assert( exist( bitstreamfile, 'file' ) == 2, message( 'soc:msgs:BitstreamNotFound', bitstreamfile ) );


disp( [ '### ', message( 'soc:msgs:CheckingProgrammingTool' ).getString ] );
[ retval, ~ ] = system( 'quartus_pgm --help' );
assert( retval == 0, message( 'soc:msgs:QuartusPgmNotFound' ) );


disp( [ '### ', message( 'soc:msgs:LoadingInProgress', bitstreamfile ).getString ] );

if chainposition > 1
programCmd = [ 'quartus_pgm -m JTAG -o "p;', bitstreamfile, '@', num2str( chainposition ), '"' ];
else 
programCmd = [ 'quartus_pgm -m JTAG -o "p;', bitstreamfile, '"' ];
end 

[ retval, msg ] = system( programCmd );

assert( retval == 0, message( 'soc:msgs:LoadingFailed', msg ) );

disp( [ '### ', message( 'soc:msgs:LoadingPassed', bitstreamfile ).getString ] );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpclzmxQ.p.
% Please follow local copyright laws when handling this file.

