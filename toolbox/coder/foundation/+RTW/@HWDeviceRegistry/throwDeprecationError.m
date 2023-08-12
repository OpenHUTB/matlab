function out = throwDeprecationError( in )















R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpEXD12N.p.
% Please follow local copyright laws when handling this file.

