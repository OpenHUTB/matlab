function [ operatable, sizeOrPlaceholder ] = binaryOperatorHelper( aVal, bVal, requiredClass, opts )

arguments
    aVal
    bVal
    requiredClass( 1, 1 )string
    opts.Placeholder
    opts.DebugName( 1, 1 )string = "operation"
end

operatable = false;

if isempty( aVal )
    expectedSize = size( aVal );
elseif isempty( bVal )
    expectedSize = size( bVal );
else
    assert( numel( aVal ) == numel( bVal ) || isscalar( aVal ) || isscalar( bVal ),  ...
        'Arguments have incompatible sizes for %s', opts.DebugName );
    assert( isvector( aVal ) || isevector( bVal ),  ...
        'Arguments to %s must both be vectors', opts.DebugName );



    if isa( aVal, requiredClass ) && isa( bVal, requiredClass )
        operatable = true;
    end


    if isscalar( aVal )
        expectedSize = size( bVal );
    else
        expectedSize = size( aVal );
    end
end


if isfield( opts, 'Placeholder' )
    sizeOrPlaceholder = repmat( opts.Placeholder, expectedSize );
else
    sizeOrPlaceholder = expectedSize;
end
end


