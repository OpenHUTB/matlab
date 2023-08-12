function v = validateXilinxCoregenCompatibility( ~, hC )



v = hdlvalidatestruct;

if targetcodegen.targetCodeGenerationUtils.isXilinxMode(  )
ioSignals = [ hC.PirInputSignals;hC.PirOutputSignals ];
for i = 1:length( ioSignals )
[ ~, hBT ] = pirelab.getVectorTypeInfo( ioSignals( i ) );
if ( isa( hBT, 'hdlcoder.tp_single' ) || isa( hBT, 'hdlcoder.tp_double' ) )
v = hdlvalidatestruct( 1, message( 'hdlcoder:validate:UnsupportedForXilinx' ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpomsTGV.p.
% Please follow local copyright laws when handling this file.

