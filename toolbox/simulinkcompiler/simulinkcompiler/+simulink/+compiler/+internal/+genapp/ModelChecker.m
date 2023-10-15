classdef ModelChecker

    properties ( Access = private )
        ModelDataSvc
        SigLoggingUtils
    end

    properties ( Access = private, Dependent )
        Model
    end

    methods
        function obj = ModelChecker( modelDataSvc, sigLoggingUtils )

            arguments
                modelDataSvc( 1, 1 )simulink.compiler.internal.ModelDataService
                sigLoggingUtils( 1, 1 )simulink.compiler.internal.SignalLoggingUtils
            end

            obj.ModelDataSvc = modelDataSvc;
            obj.SigLoggingUtils = sigLoggingUtils;
        end

        function modelName = get.Model( obj )
            modelName = obj.ModelDataSvc.ModelName;
        end

        function checkDirtyState( obj )


            if ( isequal( get_param( obj.Model, 'Dirty' ), 'on' ) )
                msgKey = "simulinkcompiler:genapp:ModelHasUnsavedChanges";
                error( message( msgKey, obj.Model ) );
            end
        end

        function checkRunningSim( obj )


            simStatus = get_param( obj.Model, 'SimulationStatus' );
            isSimStopped = isequal( simStatus, 'stopped' );

            if ~isSimStopped
                msgKey = "simulinkcompiler:genapp:ModelIsSimulating";
                error( message( msgKey, obj.Model ) );
            end
        end

        function checkSaveFormat( obj )



            if ( ( isequal( get_param( obj.Model, 'SaveOutput' ), 'on' ) ||  ...
                    isequal( get_param( obj.Model, 'SaveState' ), 'on' ) ) &&  ...
                    ( isequal( get_param( obj.Model, 'SaveFormat' ), 'Array' ) ||  ...
                    isequal( get_param( obj.Model, 'SaveFormat' ), 'Structure' ) ) )


                msgKey = "simulinkcompiler:genapp:SaveFormatIsNotSupported";
                error( message( msgKey, obj.Model ) );
            end
        end

        function checkSignalAvailability( obj )


            noOutports = isequal( numel( obj.ModelDataSvc.getRootOutports(  ) ), 0 );
            noScopes = ~obj.ModelDataSvc.modelHasScopes(  );
            noLoggedSignals = isequal( obj.SigLoggingUtils.getNumLoggedSignals(  ), 0 );

            if noOutports && noScopes && noLoggedSignals
                msgKey = "simulinkcompiler:genapp:NoSignalsWillBeAvailableInApp";
                warning( message( msgKey, obj.Model ) );
            end
        end

    end
end

