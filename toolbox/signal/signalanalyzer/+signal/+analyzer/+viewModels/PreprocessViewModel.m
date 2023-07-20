

classdef PreprocessViewModel<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ObjID='PreprocessViewModel';
    end


    methods(Static)
        function ret=getViewModel()

            persistent viewModelObj;
            mlock;
            if isempty(viewModelObj)||~isvalid(viewModelObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                viewModelObj=signal.analyzer.viewModels.PreprocessViewModel(dispatcherObj);
            end

            ret=viewModelObj;
        end
    end



    methods(Hidden)

        function this=PreprocessViewModel(dispatcherObj)

            this.Dispatcher=dispatcherObj;
            import signal.analyzer.viewModels.PreprocessViewModel;


            this.addListeners();
        end

        function addListeners(this)

            addlistener(signal.analyzer.controllers.PreprocessMode.ImportPreprocessModeController.getController(),'ImportComplete',@(src,evt)this.cb_ImportComplete(src,evt));
            addlistener(signal.analyzer.controllers.PreprocessMode.ImportPreprocessModeController.getController(),'PlotSelectedSignalsComplete',@(src,evt)this.cb_PlotSelectedSignalsComplete(src,evt));
            addlistener(signal.analyzer.controllers.PreprocessMode.ExportPreprocessModeController.getController(),'CloseModeComplete',@(src,evt)this.cb_CloseModeComplete(src,evt));
            addlistener(signal.analyzer.controllers.Preprocessing.Preprocessor.getController(),'FinalizePreprocessApplyComplete',@(src,evt)this.cb_FinalizePreprocessComplete(src,evt));
            addlistener(signal.analyzer.controllers.Preprocessing.Preprocessor.getController(),'FinalizeUndoOperationComplete',@(src,evt)this.cb_FinalizePreprocessComplete(src,evt));
            addlistener(signal.analyzer.controllers.Preprocessing.Preprocessor.getController(),'FinalizeRedoOperationComplete',@(src,evt)this.cb_FinalizePreprocessComplete(src,evt));
            addlistener(signal.analyzer.controllers.Preprocessing.Preprocessor.getController(),'FinalizeDuplicateOperationComplete',@(src,evt)this.cb_ImportComplete(src,evt));
            addlistener(signal.analyzer.controllers.Preprocessing.Preprocessor.getController(),'FinalizeExtractOperationComplete',@(src,evt)this.cb_ImportComplete(src,evt));
            addlistener(signal.analyzer.controllers.Preprocessing.Preprocessor.getController(),'FinalizeSplitOperationComplete',@(src,evt)this.cb_FinalizeSplitOperationComplete(src,evt));
            addlistener(signal.analyzer.controllers.Preprocessing.Preprocessor.getController(),'UpdatePreprocessProgressBarComplete',@(src,evt)this.cb_UpdatePreprocessProgressBarComplete(src,evt));
        end





        function cb_ImportComplete(this,~,args)

            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;

            switch messageID
            case 'addSignalsToTable'
                controllerID='signalsTableWidget';
            case 'enableSelectAndPanMode'
                controllerID='toolstripWidget';
            end

            this.Dispatcher.publishToClient(clientID,controllerID,messageID,data);
        end

        function cb_PlotSelectedSignalsComplete(this,~,args)

            messageID=args.Data.messageID;
            clientID=args.Data.clientID;

            switch messageID
            case 'plotSignalsInDisplay'

                args.Data.clientID=str2double(clientID);
                args.Data.messageID='updateMultipleSignalsInPlot';
                message.publish('/sdi/tableApplication',args.Data);
            case 'togglePreserveStartTimeCheckbox'
                clientID=args.Data.clientID;
                controllerID='toolstripWidget';
                this.Dispatcher.publishToClient(clientID,controllerID,...
                messageID,args.Data.data);
            end
        end

        function cb_CloseModeComplete(this,~,args)

            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;

            switch messageID
            case 'clearSignalsInTable'
                controllerID='signalsTableWidget';
            case 'closeMode'
                controllerID='appViewController';
            end

            this.Dispatcher.publishToClient(clientID,controllerID,messageID,data);
        end

        function cb_FinalizePreprocessComplete(this,~,args)

            messageID=args.Data.messageID;

            switch messageID
            case 'updateSignalsInDisplay'

                args.Data.messageID='importMultipleSignalsInPlot';
                message.publish('/sdi/tableApplication',args.Data);
            case 'updateRowsDataInTable'

                clientID=args.Data.clientID;
                controllerID='signalsTableWidget';
                this.Dispatcher.publishToClient(clientID,controllerID,...
                messageID,args.Data.data);
            end
        end

        function cb_FinalizeSplitOperationComplete(this,~,args)

            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;

            switch messageID
            case 'addSignalsToTable'
                controllerID='signalsTableWidget';
            case 'showSplitWarningDialog'
                controllerID='toolstripWidget';
            end

            this.Dispatcher.publishToClient(clientID,controllerID,messageID,data);
        end

        function cb_UpdatePreprocessProgressBarComplete(this,~,args)
            data=args.Data.data;
            clientID=args.Data.clientID;
            messageID=args.Data.messageID;

            switch messageID
            case 'updatePreprocessProgressBar'
                controllerID='toolstripWidget';
            end

            this.Dispatcher.publishToClient(clientID,controllerID,messageID,data);
        end
    end
end