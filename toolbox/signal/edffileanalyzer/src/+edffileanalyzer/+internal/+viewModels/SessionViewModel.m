

classdef SessionViewModel<edffileanalyzer.internal.viewModels.ViewModelBase


    methods

        function this=SessionViewModel(controller,dispatcher,signalPlotter)
            this@edffileanalyzer.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"NewSessionComplete",@(src,args)this.cb_NewSessionComplete(src,args));
        end

        function cb_NewSessionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "resetToolstrip"
                controllerID="toolstripWidget";
                data=struct;
            case "signalsTable"
                controllerID="signalsTableWidget";
                messageID="clearAllData";
                data=struct;
            case "headerPropertiesTable"
                controllerID="headerPropertiesTableWidget";
                messageID="clearAllData";
                data=struct;
            case "signalPropertiesTable"
                controllerID="signalPropertiesTableWidget";
                messageID="clearAllData";
                data=struct;
            case "annotationsTable"
                controllerID="annotationsTableWidget";
                messageID="clearAllData";
                data=struct;
            case "importAfterNewSession"
                controllerID="importFileWidget";
                data=struct;
            case "setNameTextFieldInErrorState"
                controllerID="importFileWidget";
                data=args.Data.data;
            case "removeAxes"
                controllerID="plotAxisWidget";
                data=struct;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end
    end
end