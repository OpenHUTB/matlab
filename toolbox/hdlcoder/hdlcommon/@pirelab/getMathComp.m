function mathComp = getMathComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions )




if nargin < 7
nfpOptions.Latency = int8( 0 );
nfpOptions.MantMul = int8( 0 );
nfpOptions.Denormals = int8( 0 );
nfpOptions.ModRemCheckResetToZero = true;
nfpOptions.ModRemMaxIterations = uint8( 32 );
nfpOptions.Radix = int32( 2 );
else 

if ~isfield( nfpOptions, 'ModRemCheckResetToZero' )
nfpOptions.ModRemCheckResetToZero = true;
end 
if ~isfield( nfpOptions, 'ModRemMaxIterations' )
nfpOptions.ModRemMaxIterations = uint8( 32 );
end 
if ~isfield( nfpOptions, 'Radix' )
nfpOptions.Radix = int32( 2 );
end 
end 

if nfpOptions.Latency == 4 && targetcodegen.targetCodeGenerationUtils.isNFPMode(  )
out = hOutSignals;
if targetmapping.mode( out )
if ~strcmpi( fname, 'reciprocal' )
error( message( 'hdlcommon:nativefloatingpoint:CustomLatencyUnsupported', compName ) );
end 
end 
end 

mathComp = pircore.getMathComp( hN, hInSignals, hOutSignals, compName, slbh, fname, nfpOptions );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpicqjMZ.p.
% Please follow local copyright laws when handling this file.

