function mustHaveNVPair( aNVPairStruct, aNVPairName )
















R36
aNVPairStruct( 1, 1 ){ mustBeA( aNVPairStruct, 'struct' ) }
aNVPairName( 1, 1 )string
end 
if ~isfield( aNVPairStruct, aNVPairName )
throwAsCaller( MException( message( 'coderApp:util:RequiredNVPair', aNVPairName ) ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3Kphgg.p.
% Please follow local copyright laws when handling this file.

