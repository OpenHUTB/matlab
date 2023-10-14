classdef FileVersion < evolutions.internal.artifactserver.services.Service

    properties
        StorageType
    end

    methods
        function obj = FileVersion( ServiceDBPath, storageType )
            arguments
                ServiceDBPath
                storageType( 1, : )char = 'LocalStorage'
            end
            obj@evolutions.internal.artifactserver.services.Service( ServiceDBPath );
            obj.StorageType = storageType;
        end
        storage = getStorageService( obj )

        tf = create( obj, data )

        tf = read( obj, data )

        tf = deleteArtifact( obj, data );

        [ filePath, data ] = getFileData( obj, data );

        unshelveFile( ~, shelvedFile, unshelveFile );
    end
end



