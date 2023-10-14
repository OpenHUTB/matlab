classdef ArtifactServer < handle

    properties ( Access = protected )
        ServerPath
        DefaultServices = [ "FileVersion", "Webview" ]
        StorageType = 'LocalStorage'
    end

    methods
        function server = getService( obj, name )
            path = fullfile( obj.ServerPath, strcat( name, '.xml' ) );
            server = evolutions.internal.artifactserver.services ...
                .( name )( path, obj.StorageType );
        end

        function obj = ArtifactServer( config )
            obj.ServerPath = fullfile( config.Path, 'ArtifactFiles' );
            enableWebView = evolutions.internal.getFeatureState( 'EnableWebview' );


            if enableWebView
                obj.DefaultServices = [ "FileVersion", "Webview" ];
            else
                obj.DefaultServices = "FileVersion";
            end

            storageType = config.Storage;
            switch storageType
                case 'LocalStorage'
                    obj.setLocalStorage;
                otherwise
                    assert( isequal( storageType, 'GitStorage' ),  ...
                        'Cannot set given storage type' );
                    obj.setGitStorage;
            end
        end

        function generateArtifacts( obj, file, version, services )
            arguments
                obj
                file char
                version char
                services = [ obj.DefaultServices ]
            end


            data = obj.getData( file, version );

            try
                for idx = 1:numel( services )
                    service = services( idx );
                    obj.getService( service ).create( data );
                end
            catch ME


                obj.deleteArtifacts( version );


                rethrow( ME );
            end
        end

        function readArtifacts( obj, file, version )



            if ~obj.getVersion( file, version )
                newME = MException( 'Evolutions:FileReadFail',  ...
                    getString( message( 'evolutions:manage:FileReadFail' ) ) );
                throw( newME );
            end
        end

        function deleteArtifacts( obj, id )
            data = struct;
            data.Id = id;

            if nargin > 3
                neededServices = [ obj.DefaultServices, services ];
            else
                neededServices = [ obj.DefaultServices ];
            end

            for idx = 1:numel( neededServices )
                service = neededServices( idx );
                obj.getService( service ).deleteArtifact( data );
            end
        end

        function setGitStorage( obj )
            obj.StorageType = 'GitStorage';
        end

        function setLocalStorage( obj )
            obj.StorageType = 'LocalStorage';
        end
    end

    methods

        function out = createVersion( obj, file, id )
            out = obj.getService( "FileVersion" ).create( obj.getData( file, id ) );
        end

        function out = getVersion( obj, file, id )
            out = obj.getService( "FileVersion" ).read( obj.getData( file, id ) );
        end

        function [ fileName, meta ] = getVersionMeta( obj, file, id )
            [ fileName, meta ] = obj.getService( "FileVersion" ).getFileData( obj.getData( file, id ) );
        end

        function out = createWebview( obj, file, id )
            enableWebView = evolutions.internal.getFeatureState( 'EnableWebview' );

            if enableWebView
                out = obj.getService( "Webview" ).create( obj.getData( file, id ) );
            else
                out = char.empty;
            end
        end

        function out = readWebview( obj, file, id )
            enableWebView = evolutions.internal.getFeatureState( 'EnableWebview' );

            if enableWebView
                out = obj.getService( "Webview" ).read( obj.getData( file, id ) );
            else
                out = char.empty;
            end
        end
    end

    methods ( Static = true )
        function data = getData( file, id )
            data = struct;
            data.File = file;
            data.Id = id;
        end
    end
end

