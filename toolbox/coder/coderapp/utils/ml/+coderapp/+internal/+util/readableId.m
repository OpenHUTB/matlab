function id = readableId( prefix, opts )
arguments
    prefix{ fastScalarMustBeVarName( prefix ) } = 'id'
    opts.AlwaysAppendNumber( 1, 1 ){ mustBeNumericOrLogical( opts.AlwaysAppendNumber ) } = true
end

mlock;
persistent prefixes;

if isempty( prefixes )
    prefixes = struct(  );
end

if isfield( prefixes, prefix )
    counter = prefixes.( prefix ) + 1;
    id = char( prefix + string( counter ) );
    prefixes.( prefix ) = counter;
else
    if opts.AlwaysAppendNumber
        id = [ prefix, '1' ];
    else
        id = prefix;
    end
    prefixes.( prefix ) = 1;
end
end


function fastScalarMustBeVarName( arg )
assert( isvarname( arg ), 'Must be a valid variable name' );
end


