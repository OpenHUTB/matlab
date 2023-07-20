classdef ImportFunction<handle




    properties(Hidden)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='ImportFunction';
    end

    methods(Static)

        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                ctrlObj=signal.analyzer.controllers.ImportFunction(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end

    methods(Hidden)

        function this=ImportFunction(dispatcherObj)

            this.Dispatcher=dispatcherObj;


            import signal.analyzer.controllers.ImportFunction;
            this.Dispatcher.subscribe(...
            [ImportFunction.ControllerID,'/','importcustomfunction'],...
            @(arg)cb_ImportFunction(this,arg));
        end


        function cb_ImportFunction(this,arg)




            this.importFunction(arg);
        end
    end

    methods(Access=protected)

        function importFunction(~,arg)
            if isfield(arg.data,'functionName')
                functionName=arg.data.functionName;
                functionDesc=arg.data.functionDesc;

                prefStruct=struct('name',functionName,'description',functionDesc);
                setpref('SACustomFunctionList',functionName,prefStruct);

                functionToAdd={prefStruct};
                signal.sigappsshared.Utilities.publishCustomPreprocessAddCompleted(functionToAdd);
            end
        end
    end
end