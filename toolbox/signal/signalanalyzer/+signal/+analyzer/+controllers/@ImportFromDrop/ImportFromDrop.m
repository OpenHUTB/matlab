classdef ImportFromDrop<handle




    properties(Hidden)
        Model;
        Dispatcher;
        Appstate;
        InputArguments=[];
    end

    properties(Constant)
        ControllerID='importFromDrop';
    end

    methods(Static)

        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                appStateCtrl=signal.analyzer.controllers.AppState.getController();
                ctrlObj=signal.analyzer.controllers.ImportFromDrop(dispatcherObj,appStateCtrl);
            end


            ret=ctrlObj;
        end
    end

    methods(Hidden)

        function this=ImportFromDrop(dispatcherObj,appStateCtrl)

            this.Dispatcher=dispatcherObj;
            this.Appstate=appStateCtrl;
            this.reset();

            import signal.analyzer.controllers.ImportFromDrop;
            this.Dispatcher.subscribe(...
            [ImportFromDrop.ControllerID,'/','drop'],...
            @(arg)cb_DroppedSignal(this,arg));
            this.Dispatcher.subscribe(...
            [ImportFromDrop.ControllerID,'/','clearinputarguments'],...
            @(arg)cb_ClearInputArguments(this,arg));
        end


        function cb_DroppedSignal(this,arg)




            this.importData(arg);
        end


        function cb_ClearInputArguments(this,~)

            this.reset();
        end


        function updateRepository(this,varNames,plotFlag,clientID,checkForRepeatedVariables,varargin)




            successFlag=this.checkForRepeatedVariableAndEmitForDialog(varNames,plotFlag,clientID,checkForRepeatedVariables,varargin{:});

            if successFlag

                return;
            end

            this.Model.updateRepository(varNames,plotFlag,clientID,varargin{:});


            this.updateAppSessionInfo();
        end

    end

    methods(Access=protected)

        function importData(this,arg)
            clientID=0;
            plotFlag=false;
            checkForRepeatedVariables=true;

            if isfield(arg.data,'plotFlag')
                plotFlag=arg.data.plotFlag;
            end
            if isfield(arg.data,'clientID')
                clientID=arg.data.clientID;
            end
            if isfield(arg.data,'isShowVarOverwriteDialog')

                this.Appstate.setIsShowVarOverwriteDialog(arg.data.isShowVarOverwriteDialog);
            end
            if isfield(arg.data,'checkForRepeatedVariables')

                checkForRepeatedVariables=arg.data.checkForRepeatedVariables;
            end
            if~isempty(this.InputArguments)


                this.updateRepository(arg.data.droppedVars,plotFlag,clientID,checkForRepeatedVariables,this.InputArguments{:});
                this.reset();
            else
                this.updateRepository(arg.data.droppedVars,plotFlag,clientID,checkForRepeatedVariables);
            end
        end


        function updateAppSessionInfo(~)

            if signal.analyzer.Instance.isSDIRunning()
                gui=signal.analyzer.Instance.gui();
                gui.updateSessionInfo();
            end
        end


        function successFlag=checkForRepeatedVariableAndEmitForDialog(this,varNames,plotFlag,clientID,checkForRepeatedVariables,varargin)



            successFlag=false;
            runIDs=this.Model.getRunIDs('SignalAnalyzer');
            this.Model.setTargetRunIDs(runIDs);

            if nargin>5&&strcmp(varargin{1},'MetaStructure')
                this.Model.checkIfRepeatedVariablesMetaChanged(varargin{2},varNames);
            end

            if checkForRepeatedVariables&&this.Appstate.isShowVarOverwriteDialog()

                repeatedVarName=this.Model.getRepeatedVariableNames(varNames);

                if~isempty(repeatedVarName)
                    evtStruct.repeatedVarName=repeatedVarName;
                    evtStruct.args.droppedVars=varNames;
                    evtStruct.args.plotFlag=plotFlag;
                    evtStruct.args.clientID=clientID;
                    if nargin>5
                        this.InputArguments=varargin;
                    end
                    this.Dispatcher.publishToClient(num2str(clientID),...
                    'treeTableWidget','launchDialogForRepeatedVariables',evtStruct);
                    successFlag=true;
                end
            end
        end


        function reset(this)
            this.InputArguments=[];
        end
    end

    methods

        function value=get.Model(this)
            if isempty(this.Model)
                eng=Simulink.sdi.Instance.engine;
                this.Model=signal.sigappsshared.models.ImportFromDrop(eng);
            end
            value=this.Model;
        end
    end
end