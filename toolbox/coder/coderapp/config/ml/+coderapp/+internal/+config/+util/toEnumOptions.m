function options = toEnumOptions( value, displayKey, varargin )
R36
value{ mustBeTextScalar( value ) }
displayKey{ mustBeTextScalar( displayKey ) }
end 
R36( Repeating )
varargin{ mustBeTextScalar( varargin ) }
end 


values = [ { value }, varargin( 1:2:end  ) ];
dispKeys = [ { displayKey }, varargin( 2:2:end  ) ];
options = repmat( coderapp.internal.config.data.EnumOption, 1, numel( values ) );
for i = 1:numel( values )
options( i ).Value = values{ i };
if ~isempty( dispKeys{ i } )
options( i ).DisplayValue = message( dispKeys{ i } ).getString(  );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpyhKpfH.p.
% Please follow local copyright laws when handling this file.

