classdef ( Abstract, Hidden )AbstractFileParamType < coderapp.internal.config.AbstractParamType

    methods
        function this = AbstractFileParamType( name, doClass, varargin )
            this@coderapp.internal.config.AbstractParamType( name, doClass,  ...
                { 'AllowedFileTypes',  ...
                'ToCanonical', 'fileTypeToString',  ...
                'FromCanonical', 'toFileType',  ...
                'FromSchema', 'schemaToFileType' },  ...
                varargin{ : } );
        end
    end

    methods
        function resolveMessages( this, dataObj, unresolvedMsgs )
            resolved = false( size( unresolvedMsgs ) );
            for i = 1:numel( unresolvedMsgs )
                unresolved = unresolvedMsgs( i );
                if iscell( unresolved.Path ) && strcmp( unresolved.Path{ 1 }, 'AllowedFileTypes' )
                    idx = unresolved.Path{ 2 };
                    if idx <= numel( dataObj.AllowedFileTypes ) && isempty( dataObj.AllowedValues( idx ).Description )
                        dataObj.AllowedValues( idx ).Description = message( unresolved.MessageKey ).getString(  );
                        resolved( i ) = true;
                    end
                end
            end
            resolveMessages@coderapp.internal.config.AbstractParamType( this, dataObj, unresolvedMsgs( ~resolved ) );
        end

        function choices = getTabCompletions( ~, input, dataObj )
            baseDir = dataObj.InitialDir;
            if isempty( baseDir )
                baseDir = pwd(  );
            end

            if ~isempty( dataObj.AllowedFileTypes )
                files = cellfun( @( ext )dir( fullfile( baseDir, sprintf( '**.%s', ext ) ) ),  ...
                    { dataObj.AllowedFileType.Extension }, 'UniformOutput', false );
                files = vertcat( files{ : } );
            else
                files = dir( fullfile( baseDir, '**' ) );
                files( ismember( { files.name }, { '.', '..' } ) ) = [  ];
            end
            files( [ files.isdir ] ~= dataObj.AllowFolders ) = [  ];

            choices = sort( fullfile( { files.folder }, { files.name } ) );
            if ~isempty( input )
                relPaths = extractAfter( choices, [ baseDir, filesep(  ) ] );
                choices = choices( startsWith( lower( relPaths ), lower( input ) ) );
            end
        end
    end

    methods ( Access = protected )
        function attrs = doGetMessageKeyAttributes( this )
            attrs = [ doGetMessageKeyAttributes@coderapp.internal.config.AbstractParamType( this ), { 'AllowedFileTypes' } ];
        end
    end

    methods ( Static )
        function code = toCode( value )
            code = coderapp.internal.config.type.AbstractStringParamType.toCode( value );
        end

        function str = toString( values )
            str = coderapp.internal.config.type.AbstractStringParamType.toString( values );
        end

        function value = validateFile( value, dataObj )
            arguments
                value
                dataObj = [  ]
            end
            if isempty( value )
                value = '';
                return
            end
            mustBeTextScalar( value );
            value = char( value );
            if ~isempty( dataObj ) && ~isempty( dataObj.AllowedFileTypes )
                [ ~, ~, ext ] = fileparts( value );
                exts = dataObj.AllowedFileTypes;
                exts = regexprep( { exts.Extension }, '^[^\.]', '.$&' );
                if ispc(  )
                    exts = lower( exts );
                    ext = lower( ext );
                end
                if ~ismember( ext, exts )
                    pterror( message( 'coderApp:config:coderGeneral:invalidFileType' ) );
                end
            end
        end

        function type = toFileType( raw )
            if isa( raw, 'coderapp.internal.util.FileType' )
                type = raw;
            else
                if ischar( raw ) || iscellstr( raw ) || isstring( raw )
                    raw = cellstr( raw );
                    type = repmat( coderapp.internal.util.FileType, 1, numel( raw ) );
                    for i = 1:numel( raw )
                        type( i ).Extension = raw{ i };
                    end
                else
                    if isstruct( raw )
                        raw = num2cell( raw );
                    end
                    type = repmat( coderapp.internal.util.FileType, 1, numel( raw ) );
                    for i = 1:numel( type )
                        type( i ).Extension = raw{ i }.extension;
                        if isfield( raw{ i }, 'description' )
                            type( i ).Description = raw{ i }.description;
                        end
                    end
                end
            end
            for i = 1:numel( type )
                if startsWith( type( i ).Extension, '.' )
                    type( i ).Extension = type( i ).Extension( 2:end  );
                end
            end
        end

        function [ types, unresolvedMsgs ] = schemaToFileType( val, mfzModel, escapeMode )
            types = coderapp.internal.config.type.AbstractFileParamType.toFileType( val );
            unresolvedMsgs = coderapp.internal.config.schema.UnresolvedMessage.empty(  );
            for i = 1:numel( types )
                if isempty( types( i ).Description )
                    continue
                end
                [ str, isMsg ] = coderapp.internal.config.type.AbstractFileParamType.unescapeString( types( i ).Description, escapeMode );
                if isMsg
                    idx = numel( unresolvedMsgs ) + 1;
                    unresolvedMsgs( idx ) = coderapp.internal.config.schema.UnresolvedMessage( mfzModel );
                    unresolvedMsgs( idx ).MessageKey = str;
                    unresolvedMsgs( idx ).Path = { 'AllowedValues', i };
                    str = '';
                end
                types( i ).Description = str;
            end
        end

        function exts = fileTypeToString( types )
            if ~isempty( types )
                exts = { types.Extension };
            else
                exts = {  };
            end
        end
    end
end


