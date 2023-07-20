

classdef ImportViewModel<edffileanalyzer.internal.viewModels.ViewModelBase


    methods
        function this=ImportViewModel(controller,dispatcher,signalPlotter)
            this@edffileanalyzer.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"ImportComplete",@(src,args)this.cb_ImportComplete(src,args));
            addlistener(this.Controller,"PlotSignals",@(src,args)this.cb_PlotSignals(src,args));
            addlistener(this.Controller,"OpenFileBrowserComplete",@(src,args)this.cb_OpenFileBrowserComplete(src,args));
        end

        function cb_ImportComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "signalsTable"
                controllerID="signalsTableWidget";
                messageID="addToTable";
                data=args.Data.data;
            case "headerPropertiesTable"
                controllerID="headerPropertiesTableWidget";
                messageID="addToTable";
                data=args.Data.data;
            case "signalPropertiesTable"
                controllerID="signalPropertiesTableWidget";
                messageID="addToTable";
                data=args.Data.data;
            case "annotationsTable"
                controllerID="annotationsTableWidget";
                messageID="addToTable";
                data=args.Data.data;
            case "setNameTextFieldInErrorState"
                controllerID="importFileWidget";
                data=args.Data.data;
            case "closeDialog"
                controllerID="importFileWidget";
                data=struct;
            case "setToolstrip"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "addAxes"
                controllerID="plotAxisWidget";
                data=args.Data.data;
            case "updateMultiplier"
                controllerID="plotAxisWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="importFileWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data)
        end

        function cb_OpenFileBrowserComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "setValueInNameTextField"
                controllerID="importFileWidget";
                data=args.Data.data;
            end

            this.publishToClient(controllerID,messageID,data)
        end
    end
end