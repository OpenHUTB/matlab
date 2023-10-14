function out = throwDeprecationError( in )

arguments
    in logical{ mustBeScalarOrEmpty } = logical.empty(  )
end

persistent throw
if isempty( throw )
    throw = true;
end

if nargout
    out = throw;
end
if nargin
    throw = in;
end
end



