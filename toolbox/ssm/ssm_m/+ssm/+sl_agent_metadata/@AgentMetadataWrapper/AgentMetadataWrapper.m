


















classdef AgentMetadataWrapper < handle
    properties ( Access = protected, Hidden )
        MF0Model
        thisImpl = [  ];
    end

    methods ( Static )
        function serializeToFile( model, metaFileName )
            arguments
                model( 1, 1 )string{ modelFileMustExist } = ""
                metaFileName( 1, 1 )string = ""
            end

            metaFileName = processFileNames( model, metaFileName, "_meta", ".xml" );

            load_system( model );
            objClean = onCleanup( @(  )close_system( model, 0 ) );


            set_param( model, 'HasSystemComposerArchInfo', 'on' );
            MF0 = get_param( model, 'SystemComposerMf0Model' );

            ssm.sl_agent_metadata.AgentMetadataWrapper.serializeMF0ToXML( MF0, metaFileName );
        end

        function exportToArchAndMeta( model, archFileName, metaFileName )
            arguments
                model( 1, 1 )string{ modelFileMustExist } = ""
                archFileName( 1, 1 )string = ""
                metaFileName( 1, 1 )string = ""
            end

            metaFileName = processFileNames( model, metaFileName, "_meta", ".xml" );
            archFileName = processFileNames( model, archFileName, "_arch", "" );

            load_system( model );
            objClean1 = onCleanup( @(  )close_system( model, 0 ) );


            systemcomposer.internal.arch.exportToArch( model, archFileName );
            load_system( archFileName );
            objClean2 = onCleanup( @(  )close_system( archFileName, 0 ) );

            MF0 = get_param( archFileName, 'SystemComposerMf0Model' );

            ssm.sl_agent_metadata.AgentMetadataWrapper.serializeMF0ToXML( MF0, metaFileName );
        end

        function serializeMF0ToXML( MF0, metaFileName )

            zcModel = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( MF0 );


            agtMeta = ssm.sl_agent_metadata.AgentMetadata( MF0 );
            agtMeta.setRootZCModel( zcModel );

            serializer = mf.zero.io.XmlSerializer;
            serializer.serializeToFile( MF0, metaFileName );
        end
    end

    methods
        function impl = getImpl( this )
            impl = this.thisImpl;
        end

        function serializeFromFile( this, metadatafile )
            arguments
                this( 1, 1 )
                metadatafile( 1, 1 )string{ fileMustExist } = ""
            end

            this.MF0Model = mf.zero.Model;
            this.thisImpl = ssm.sl_agent_metadata.AgentMetadata.serializeFromFile( this.MF0Model, metadatafile );
        end

        function ports = getPorts( this )
            ports = [  ];
            if isempty( this.thisImpl )
                return ;
            end

            ports = this.thisImpl.getRootArchitecture.getPorts(  );
        end

        function ptNames = getPortNames( this )
            ptNames = {  };
            if isempty( this.thisImpl )
                return ;
            end
            ptNames = this.thisImpl.getRootArchitecture.getPortNames;
        end

        function arch = getRootArchitecture( this )
            arch = [  ];
            if isempty( this.thisImpl )
                return ;
            end
            arch = this.thisImpl.getRootArchitecture;
        end

    end
end

function modelFileMustExist( fileNames )

existStatus = exist( fileNames, 'file' );
if existStatus ~= 4
    error( "model " + fileNames + " does not exist." );
end
end

function fileMustExist( fileNames )

existStatus = exist( fileNames, 'file' );
if existStatus ~= 2
    error( fileNames + " does not exist." );
end
end

function fullFileName = processFileNames( modelName, fullFileName, expName, expExt )

[ ~, model, ~ ] = fileparts( modelName );
[ filePath, fileName, fileExt ] = fileparts( fullFileName );


if strlength( fileName ) == 0 && strlength( model ) ~= 0
    fileName = model + expName;
end


if strlength( expExt ) ~= 0
    fileExt = expExt;
end

fullFileName = fullfile( filePath, fileName + fileExt );
end



