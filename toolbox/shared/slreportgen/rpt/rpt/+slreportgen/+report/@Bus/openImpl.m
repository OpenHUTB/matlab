function result = openImpl( reporter, impl, varargin )
if isempty( varargin )
key = [ 'E2CxocC0AQVPieCaF6zwyymEfleDPfJOqGXlOz3jgfYEGmGiJh64a7JA6Dmq' ...
, 'MCrMWGhDZcy+oNxGHt2D3Q7W+Q2KtabMTvKPT2Y92KC6ihl1yDFXjaT6sIYl' ...
, 'FajJ+LUNvGr7Onrv9z5/O+Otc0kSx9MAwZsj3SZ25IW4bmmwl+P9/6Bu/IK4' ...
, 'ePEKljoGt21J+iNBE7epwJh/lmCGXOzdRXzSkFqmvTVcpVd/1U8vfWKj8A7k' ...
, 'n9QG0u27qiqQdtu9unZtIknJsD6EnNVvpm6i+R5iUmXkFCP/qiqNRYsS+10=' ];
else 
key = varargin{ 1 };
end 
result = open( impl, key, reporter );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpYJB80I.p.
% Please follow local copyright laws when handling this file.

