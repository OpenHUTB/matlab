classdef ( Abstract )DeployScriptGenerator

    properties ( Access = protected )
        adapter
        generatorOptions
    end

    properties ( Constant, Access = protected )
        BUILD_RESULTS_VAR = "buildResult";
    end

    methods
        function obj = DeployScriptGenerator( adapter )
            arguments
                adapter( 1, 1 )compiler.internal.deployScriptDataAdapter.DataAdapter
            end
            obj.adapter = adapter;
        end
    end

    methods ( Abstract )
        script = generateScript( obj )
    end

    methods ( Access = protected )
        function defaultValue = getDefaultValue( obj, option )
            mustBeMember( option, obj.generatorOptions );
            defaultValue = '';
        end

        function optionLine = serializeOption( obj, option, scriptVarName )
            optionValue = obj.adapter.getOptionValue( option );

            prePropertyLines = [  ];
            if isstruct( optionValue )
                prePropertyLines = optionValue.preLines;
                optionValue = optionValue.value;
            end

            optionName = option.optionName(  );
            defaultValue = obj.getDefaultValue( option );
            if ( ~isequal( optionValue, defaultValue ) && ~isempty( optionValue ) )
                if ( isa( optionValue, "string" ) )
                    optionValue = obj.wrapInQuotes( optionValue );
                elseif ( isa( optionValue, "char" ) || iscellstr( optionValue ) )
                    optionValue = obj.wrapInQuotes( string( optionValue ) );
                elseif ( isrow( optionValue ) && isnumeric( optionValue ) )
                    optionValue = string( char( optionValue ) );
                else
                    optionValue = string( optionValue );
                end
                optionLine = strcat( scriptVarName, ".", optionName, " = ", optionValue, ";" );
            else
                optionLine = "";
            end

            if ~isempty( prePropertyLines )
                optionLine = strjoin( [ prePropertyLines, optionLine ], newline );
            end
        end

        function formattedString = wrapInQuotes( obj, rawText )
            arguments
                obj
                rawText( 1, : )string{ mustBeText( rawText ) }
            end
            if isscalar( rawText )
                formattedString = strcat( '"', rawText, '"' );
            else
                strText = string( rawText );
                wrapped = arrayfun( @( s )obj.wrapInQuotes( s ), strText );
                formattedString = strjoin( [ "[" + wrapped( 1 ), wrapped( 2:end  - 1 ), wrapped( end  ) + "]" ], ", " );
            end
        end
    end
end


