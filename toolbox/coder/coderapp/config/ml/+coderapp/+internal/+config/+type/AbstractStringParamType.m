classdef ( Abstract )AbstractStringParamType < coderapp.internal.config.AbstractParamType

    methods
        function this = AbstractStringParamType( name, doClass, varargin )
            this@coderapp.internal.config.AbstractParamType( name, doClass,  ...
                { 'RegexDescription', 'FromSchema', 'regexDescriptionFromSchema' },  ...
                varargin{ : } );
        end

        function resolveMessages( this, dataObj, unresolvedMsgs )
            resolved = false( size( unresolvedMsgs ) );
            for i = 1:numel( unresolvedMsgs )
                unresolved = unresolvedMsgs( i );
                if isequal( unresolved.Path, 'RegexDescription' )
                    if isempty( dataObj.RegexDescription )
                        dataObj.RegexDescription = message( unresolved.MessageKey ).getString(  );
                    end
                    resolved( i ) = true;
                end
            end
            resolveMessages@coderapp.internal.config.AbstractParamType( this, dataObj, unresolvedMsgs( ~resolved ) );
        end
    end

    methods ( Access = protected )
        function attrs = doGetMessageKeyAttributes( this )
            attrs = [ doGetMessageKeyAttributes@coderapp.internal.config.AbstractParamType( this ), { 'RegexDescription' } ];
        end
    end

    methods ( Static )
        function code = toCode( value )

            code = mat2str( string( value ) );
        end

        function str = toString( values )
            str = strjoin( strcat( '"', values, '"' ), ', ' );
        end

        function value = validateString( value, dataObj )
            arguments
                value
                dataObj = [  ]
            end
            if isempty( value )
                value = '';
            else
                mustBeTextScalar( value )
                value = char( value );
            end
            if ~isempty( dataObj )
                if ~isempty( dataObj.Regex ) && isempty( regexp( value, dataObj.Regex, 'once', 'emptymatch' ) )
                    if ~isempty( dataObj.RegexDescription )
                        pterror( struct( 'identifier', 'coderApp:config:invalidValue', 'message', dataObj.RegexDescription ) );
                    else
                        pterror( message( 'coderApp:config:coderGeneral:invalidStringValue', value ) );
                    end
                end
            end
        end

        function [ value, unresolved ] = validateRegexDescription( varargin )
            [ value, unresolved ] = coderapp.internal.config.AbstractParamType.schemaImportPossibleMessage(  ...
                varargin{ : }, 'RegexDescription' );
        end
    end
end



