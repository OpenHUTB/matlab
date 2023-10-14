classdef ( Sealed )CompositeParamType < coderapp.internal.config.AbstractParamType

    methods
        function this = CompositeParamType(  )
            this@coderapp.internal.config.AbstractParamType( 'composite',  ...
                'coderapp.internal.config.data.CompositeParamData',  ...
                { 'Value',  ...
                'Validator', 'validateAsComposite',  ...
                'FromSchema', 'deconstructStruct',  ...
                'FromCanonical', 'deconstructStruct',  ...
                'ToCanonical', 'reconstructStruct' },  ...
                { 'AllowedFields',  ...
                'FromSchema', 'validateFieldArray',  ...
                'FromCanonical', 'validateFieldArray' },  ...
                { 'RequiredFields',  ...
                'FromSchema', 'validateFieldArray',  ...
                'FromCanonical', 'validateFieldArray' } );
        end
    end

    methods ( Static )
        function code = toCode( ~ )
            code = '[]';
        end

        function str = toString( ~ )
            str = '';
        end

        function entries = validateAsComposite( entries, ~ )
            arguments
                entries coderapp.internal.config.data.CompositeEntry
                ~
            end
            coderapp.internal.config.type.CompositeParamType.validateFieldPaths( { entries.Field } );
            entries = reshape( entries, 1, [  ] );
        end

        function entries = deconstructStruct( value, ~ )
            if isempty( value )
                entries = coderapp.internal.config.data.CompositeEntry.empty(  );
                return
            end
            validateattributes( value, { 'struct' }, { 'scalar' } );
            entries = structToEntries( value, {  } );
        end

        function adjusted = validateFieldArray( value )
            arguments
                value{ mustBeText( value ) }
            end
            adjusted = cellstr( value );
            coderapp.internal.config.type.CompositeParamType.validateFieldPaths( adjusted );
        end

        function value = reconstructStruct( entries )
            value = struct(  );
            for i = 1:numel( entries )
                entry = entries( i );
                if isscalar( strsplit( entry.Field, '.' ) )
                    value.( entry.Field ) = entry.getValue(  );
                else
                    eval( sprintf( 'value.%s = entry.getValue();', entry.Field ) );
                end
            end
        end

        function validateFieldPaths( fieldPaths )
            assert( all( ~cellfun( 'isempty', regexp( fieldPaths,  ...
                '^[A-Z,a-z][0-9,A-Z,a-z,_]*(\.[A-Z,a-z][0-9,A-Z,a-z,_]*)*$', 'once' ) ) ),  ...
                'Field values must be valid field names or valid field names joined by periods' );
        end
    end
end


function entries = structToEntries( aStruct, pathFromRoot )
fields = fieldnames( aStruct );
entries = coderapp.internal.config.data.CompositeEntry.empty(  );

for i = 1:numel( fields )
    value = aStruct.( fields{ i } );
    if isstruct( value ) && isscalar( value )
        entries = [ entries, structToEntries( value, [ pathFromRoot, fields( i ) ] ) ];%#ok<AGROW>
    else
        entries( end  + 1 ).Field = strjoin( [ pathFromRoot, fields( i ) ], '.' );%#ok<AGROW>
        code = coderapp.internal.value.valueToExpression( value );
        if ~isempty( code )
            entries( end  ).Code = code;
        else
            entries( end  ).Bytes = matlab.net.base64encode( getByteStreamFromArray( value ) );
        end
    end
end
end

