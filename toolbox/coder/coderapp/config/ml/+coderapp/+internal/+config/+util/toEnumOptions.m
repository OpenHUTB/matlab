function options = toEnumOptions( value, displayKey, varargin )
arguments
    value{ mustBeTextScalar( value ) }
    displayKey{ mustBeTextScalar( displayKey ) }
end
arguments( Repeating )
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


