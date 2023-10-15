























classdef MetadataGenerator < handle




    properties

        ModelName( 1, : )char{ ssm.sl_agent_metadata.internal.utils.validateActorModelName }


        ArchName( 1, : )char
        MetaFileName( 1, : )char
    end

    methods ( Static, Hidden = true )


        dtBlks = findTargetBlocks( ModelName, targetBlockTypes, topicFieldNames );

        dtBlks = getTopicBusObjectValue( ModelName, dtBlks );

        addBusInterfaceForDTBlocks( zcModel, dtBlks );

        addPortForDTBlocks( zcModel, dtBlks );

        dtMap = getDatatableAttributes(  );

        addDTStereotypeToProfile( profile, dtMap );

        addParametersToZCModel( zcModel, params );

        addServiceInterface( mf0, interfaceValues, interfaceName );
    end

    methods

        function obj = MetadataGenerator( ModelName, options )
            arguments
                ModelName
                options.MetaFileName = strcat( baseModelName( ModelName ), '_meta.xml' )
                options.ArchName = strcat( baseModelName( ModelName ), '_arch' )
                options.ProtoFileName = strcat( baseModelName( ModelName ), '.slprotodata' )
            end

            obj.ModelName = baseModelName( ModelName );
            obj.MetaFileName = options.MetaFileName;
            obj.ArchName = options.ArchName;

        end

        function genMetadata( obj )

            if bdIsLoaded( obj.ArchName )
                close_system( obj.ArchName, 0 );
            end

            zcModel = obj.getZCModelInstance(  );
            objZCCleanup = onCleanup( @(  )close_system( obj.ArchName, 0 ) );

            modelFullPath = which( obj.ModelName );
            [ ~, ~, mdlext ] = fileparts( modelFullPath );

            if strcmpi( mdlext, '.slx' ) || strcmpi( mdlext, '.mdl' )

                obj.setupZCModelSimulink( zcModel );

            elseif strcmpi( mdlext, '.m' )

                obj.setupZCModelSystemObject( zcModel );
            end


            mf0 = get_param( obj.ArchName, 'SystemComposerMf0Model' );
            ssm.sl_agent_metadata.AgentMetadataWrapper.serializeMF0ToXML( mf0, obj.MetaFileName );
        end

    end

    methods ( Hidden = true )
        function zcModel = getZCModelInstance( obj )
            mf0 = mf.zero.Model;
            zcMdlCreator = ssm.sl_agent_metadata.ZCModelCreator( mf0 );
            zcMdlCreator.p_modelName = obj.ArchName;
            zcMdlCreator.create;

            load_system( obj.ArchName );
            zcModel = systemcomposer.arch.Model( obj.ArchName );
        end

        function setupZCModelSimulink( obj, zcModel )


            if ~bdIsLoaded( obj.ModelName )
                load_system( obj.ModelName );
                objModelCleanup = onCleanup( @(  )close_system( obj.ModelName, 0 ) );
            end



            dtBlks = obj.findTargetBlocks( obj.ModelName, { 'DataTableReader' }, { 'BusType', 'TableType' } );


            dtBlks = obj.getTopicBusObjectValue( obj.ModelName, dtBlks );


            obj.addBusInterfaceForDTBlocks( zcModel, dtBlks );


            obj.addPortForDTBlocks( zcModel, dtBlks );


            params = Simulink.internal.getModelParameterInfo( obj.ModelName );
            obj.addParametersToZCModel( zcModel, params );


            mf0 = get_param( obj.ArchName, 'SystemComposerMf0Model' );
            obj.addServiceInterface( mf0, {  }, 'ExecutionInterface' );
        end

        function setupZCModelSystemObject( obj, zcModel )

            params = ssm.sl_agent_metadata.internal.utils.getSystemObjectParameterInfo( obj.ModelName );
            obj.addParametersToZCModel( zcModel, params );
        end
    end
end

function ModelName = baseModelName( ModelName )
[ ~, ModelName, ~ ] = fileparts( ModelName );
end



