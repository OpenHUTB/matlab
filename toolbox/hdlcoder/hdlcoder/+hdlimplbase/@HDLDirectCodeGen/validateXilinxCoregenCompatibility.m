function v = validateXilinxCoregenCompatibility( ~, hC )



v = hdlvalidatestruct;

if targetcodegen.targetCodeGenerationUtils.isXilinxMode(  )
ioSignals = [ hC.PirInputSignals;hC.PirOutputSignals ];
for i = 1:length( ioSignals )
hBT = ioSignals( i ).Type.BaseType;
if hBT.isFloatType
v = hdlvalidatestruct( 1, message( 'hdlcoder:validate:UnsupportedForXilinx' ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpK13XsI.p.
% Please follow local copyright laws when handling this file.

