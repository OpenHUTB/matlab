classdef Packager < handle

    properties ( SetAccess = immutable, GetAccess = private )
        ExportedArxmlFolder;
        ZipFileName;
        DictionaryFolders;
    end

    properties ( Access = private )
        PackNGoZipFiles;
    end

    methods

        function this = Packager( exportedArxmlFolder, zipFileName, dictionaryFolders )
            arguments
                exportedArxmlFolder
                zipFileName
                dictionaryFolders
            end

            this.ExportedArxmlFolder = exportedArxmlFolder;
            this.ZipFileName = zipFileName;
            this.DictionaryFolders = dictionaryFolders;
        end


        function packageComponentModel( this, componentModel )
            this.PackNGoZipFiles{ end  + 1 } = this.callPackNGo( componentModel );
        end


        function createFinalCompositionPackage( this )
            this.doCreateFinalCompositionPackage(  );
        end
    end

    methods ( Access = private )



        function zipFile = callPackNGo( this, componentModel )
            bDir = RTW.getBuildDir( componentModel ).BuildDirectory;
            bi = load( fullfile( bDir, 'buildInfo.mat' ) );
            if isempty( this.ExportedArxmlFolder )


                zipFile = this.ZipFileName;
            else
                zipFile = fullfile( this.ExportedArxmlFolder, [ componentModel, '.zip' ] );
            end
            packNGo( bi.buildInfo,  ...
                'packType', 'hierarchical',  ...
                'fileName', zipFile,  ...
                'nestedZipFiles', false );
        end




        function doCreateFinalCompositionPackage( this )

            origDir = pwd;
            cdObj = onCleanup( @(  )cd( origDir ) );



            tempDir = tempname;
            mkdir( tempDir );
            cd( tempDir );
            cleanupTempFolder = onCleanup( @(  )rmdir( tempDir, 's' ) );


            srcFolderName = 'src';
            arxmlFolderName = 'arxml';
            srcFolder = fullfile( pwd, srcFolderName );
            arxmlFolder = fullfile( pwd, arxmlFolderName );
            [ status, msg, msgId ] = mkdir( srcFolder );
            if ~status
                error( msgId, '%s', msg );
            end

            [ status, msg, msgId ] = mkdir( arxmlFolder );
            if ~status
                error( msgId, '%s', msg );
            end






            for zIdx = 1:length( this.PackNGoZipFiles )
                zipfile = this.PackNGoZipFiles{ zIdx };
                unzip( zipfile, srcFolder );


                arxmlFiles = autosar.composition.build.Packager.findFilesWithExtension( srcFolder, '.arxml' );
                cellfun( @( x )delete( x ), arxmlFiles );
            end



            arxmlFiles = autosar.composition.build.Packager.findFilesWithExtension(  ...
                this.ExportedArxmlFolder, '.arxml' );
            stubFolderName = autosar.mm.arxml.Exporter.StubFolderName;


            for dictIdx = 1:length( this.DictionaryFolders )
                dictFolder = this.DictionaryFolders{ dictIdx };
                sharedArxmlFiles = autosar.composition.build.Packager.findFilesWithExtension(  ...
                    dictFolder, '.arxml' );
                for i = 1:length( sharedArxmlFiles )
                    arxmlFiles{ end  + 1 } = sharedArxmlFiles{ i };%#ok
                end
            end

            for i = 1:length( arxmlFiles )
                arxmlFile = arxmlFiles{ i };
                [ fPath, n, e ] = fileparts( arxmlFile );


                if strcmp( fPath, fullfile( this.ExportedArxmlFolder, stubFolderName ) )
                    stubFolder = fullfile( arxmlFolder, stubFolderName );
                    if ~exist( stubFolder, 'dir' )
                        [ status, msg, msgId ] = mkdir( stubFolder );
                        if ~status
                            error( msgId, '%s', msg );
                        end
                    end
                    copyfile( arxmlFile, fullfile( stubFolder, [ n, e ] ), 'f' );
                else
                    copyfile( arxmlFile, fullfile( arxmlFolder, [ n, e ] ), 'f' );
                end
            end


            zipFiles = autosar.composition.build.Packager.findFilesWithExtension(  ...
                this.ExportedArxmlFolder, '.zip' );
            cellfun( @( x )delete( x ), zipFiles );


            zip( this.ZipFileName, { srcFolderName, arxmlFolderName } );
        end
    end

    methods ( Static, Access = public )


        function files = findFilesWithExtension( folder, fileExt )
            files = {  };
            n_findFilesWithExtension( folder, fileExt );

            function n_findFilesWithExtension( folder, fileExt )
                [ children, isDir ] = n_listFiles( folder );
                leafs = children( ~isDir );
                for i = 1:length( leafs )
                    [ ~, ~, lExt ] = fileparts( leafs( i ).name );
                    if strcmp( lExt, fileExt )
                        files{ end  + 1 } = fullfile( folder, leafs( i ).name );%#ok<AGROW>
                    end
                end

                subFolders = children( isDir );
                for ii = 1:numel( subFolders )
                    n_findFilesWithExtension( fullfile( folder, subFolders( ii ).name ), fileExt );
                end
            end

            function [ children, isDir ] = n_listFiles( folder )
                children = dir( folder );
                children = children( ~ismember( { children.name }, { '.', '..' } ) );
                isDir = [ children.isdir ];
            end
        end
    end
end


