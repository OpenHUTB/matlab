classdef ImportLabelerFunction<handle




    properties(Hidden)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='ImportLabelerFunction';
    end

    events
ImportCustomLabelerFunction
    end

    methods(Static)

        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                ctrlObj=signal.labeler.controllers.ImportLabelerFunction(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end

    methods(Hidden)

        function this=ImportLabelerFunction(dispatcherObj)

            this.Dispatcher=dispatcherObj;
            import signal.labeler.controllers.ImportLabelerFunction;

            this.Dispatcher.subscribe(...
            [ImportLabelerFunction.ControllerID,'/','importcustomlabelerfunction'],...
            @(arg)cb_ImportLabelerFunction(this,arg));
        end


        function cb_ImportLabelerFunction(this,arg)




            this.importFunction(arg);
        end
    end

    methods(Access=protected)

        function importFunction(this,args)
            if isfield(args.data,'functionName')
                functionName=args.data.functionName;
                functionDesc=args.data.functionDesc;
                functionLabelType=args.data.functionLabelType;

                functionLabelDataType=args.data.functionLabelDataType;

                prefStruct=struct('name',functionName,'description',functionDesc,'functionLabelType',functionLabelType,'functionLabelDataType',functionLabelDataType);
                setpref('LACustomLabelerFunctionList',functionName,prefStruct);

                functionToAdd={prefStruct};
                this.notify('ImportCustomLabelerFunction',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'data',functionToAdd)));
            end
        end
    end
end