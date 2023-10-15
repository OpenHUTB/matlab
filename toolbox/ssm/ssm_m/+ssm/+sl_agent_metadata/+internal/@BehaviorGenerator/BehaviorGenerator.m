














classdef BehaviorGenerator < handle




    properties

        ModelName( 1, : )char{ ssm.sl_agent_metadata.internal.utils.validateActorModelName }


        ProtoFileName( 1, : )char
        ExtraInformation( 1, 1 )struct
    end

    properties ( Access = private )
        bhaviorInfo( 1, 1 )struct
    end

    methods
        function obj = BehaviorGenerator( ModelName, options )
            arguments
                ModelName
                options.ProtoFileName = strcat( baseModelName( ModelName ), '.slprotodata' )
            end

            obj.ModelName = baseModelName( ModelName );
            obj.ProtoFileName = options.ProtoFileName;
        end

        function genBehaviorProto( obj )
            modelFullPath = which( obj.ModelName );
            [ ~, ~, mdlext ] = fileparts( modelFullPath );



            obj.bhaviorInfo.model_name = string( obj.ModelName );




            obj.bhaviorInfo.behavior_format = 0;
            if strcmpi( mdlext, '.slx' ) || strcmpi( mdlext, '.mdl' )
                obj.bhaviorInfo.behavior_format = 1;
            elseif strcmpi( mdlext, '.m' )
                obj.bhaviorInfo.behavior_format = 2;
            end


            if strcmpi( mdlext, '.slx' ) || strcmpi( mdlext, '.mdl' )
                obj.addParameterSimulink(  );
            elseif strcmpi( mdlext, '.m' )
                obj.addParameterSystemObject(  );
            end

            obj.addExtraInformation(  );

            obj.writeToFile(  );
        end
    end

    methods ( Access = private )

        addParameterSimulink( obj );
        addParameterSystemObject( obj );

        function addExtraInformation( obj )

            if ~isempty( obj.ExtraInformation )
                fieldNames = fields( obj.ExtraInformation );
                for idx = 1:numel( fieldNames )
                    fieldName = fieldNames{ idx };
                    obj.bhaviorInfo.( fieldName ) = obj.ExtraInformation.( fieldName );
                end
            end

        end

        function writeToFile( obj )
            protoMdlInfo = ssm.sl_agent_metadata.MxArrayToProto( obj.bhaviorInfo );
            [ pfolder, ~, ~ ] = fileparts( obj.ProtoFileName );


            tempFileName = [ obj.ProtoFileName, '.temp' ];
            [ fid, ~ ] = fopen( tempFileName, 'w' );
            if fid ==  - 1
                errMsg = message( 'ssm:actorMetadata:FailedToCreateBehaviorOutputFile', pwd );
                error( errMsg );
            else
                fclose( fid );
                delete( tempFileName );
            end


            if ( ~isempty( obj.ProtoFileName ) ) && ( exist( pfolder, 'dir' ) == 7 || isempty( pfolder ) )
                protoMdlInfo.serializeToFile( obj.ProtoFileName )
            else
                errMsg = message( 'ssm:actorMetadata:InvalidBehaviorOutputFile', obj.ProtoFileName );
                error( errMsg );
            end
        end
    end
end

function ModelName = baseModelName( ModelName )
[ ~, ModelName, ~ ] = fileparts( ModelName );
end


