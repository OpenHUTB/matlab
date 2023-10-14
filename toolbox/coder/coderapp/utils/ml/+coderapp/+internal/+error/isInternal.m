function internal = isInternal( exception )

arguments
    exception( 1, 1 )MException
end

if isa( exception, 'coderapp.internal.error.DecoratedException' )
    internal = exception.IsInternal;
elseif isempty( exception.identifier )

    internal = true;
else
    try
        message( exception.identfier );
        internal = false;
    catch
        internal = true;
    end
end
end


