classdef Webview < evolutions.internal.artifactserver.services.Service

    properties
        StorageType
    end

    methods
        function obj = Webview( ServiceDBPath, storageType )
            arguments
                ServiceDBPath
                storageType( 1, : )char = 'LocalStorage'
            end
            obj@evolutions.internal.artifactserver.services.Service( ServiceDBPath );
            obj.StorageType = storageType;
        end

        storage = getStorageService( obj )

        tf = create( obj, data )

        file = read( obj, data )

        tf = deleteArtifact( obj, data )
    end

    methods ( Access = protected )
        function tempDir = getTempDir( obj )
            tempDir = fullfile( obj.getServerDirectory, 'slprj', 'webviews' );
        end
    end
end




