function v = validateMatrices( ~, hC, maxSupportedDims )

v = hdlvalidatestruct;

if ishandle( hC.SimulinkHandle )
blkPath = getfullname( hC.SimulinkHandle );
else 
blkPath = hC.Name;
end 
maxDims = maxSupportedDims + 1;
sigs = [ hC.PirInputSignals;hC.PirOutputSignals ];
for ii = 1:numel( sigs )
hT = sigs( ii ).Type;
if hT.isArrayType
ndims = hT.NumberOfDimensions;
if ndims > maxDims
portName = sigs( ii ).Name;
v = hdlvalidatestruct( 1,  ...
message( 'hdlcoder:matrix:toomanydimsforblock', blkPath, ndims, portName ) );
elseif ndims == maxDims
v = hdlvalidatestruct( 1,  ...
message( 'hdlcoder:matrix:blocknotsupported', blkPath ) );
end 
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpQtSFyp.p.
% Please follow local copyright laws when handling this file.

