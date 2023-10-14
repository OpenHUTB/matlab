function mustHaveNVPair( aNVPairStruct, aNVPairName )

arguments
    aNVPairStruct( 1, 1 ){ mustBeA( aNVPairStruct, 'struct' ) }
    aNVPairName( 1, 1 )string
end
if ~isfield( aNVPairStruct, aNVPairName )
    throwAsCaller( MException( message( 'coderApp:util:RequiredNVPair', aNVPairName ) ) );
end
end


