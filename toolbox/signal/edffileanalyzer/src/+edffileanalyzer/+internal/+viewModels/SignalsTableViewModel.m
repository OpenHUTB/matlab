

classdef SignalsTableViewModel<edffileanalyzer.internal.viewModels.ViewModelBase


    methods

        function this=SignalsTableViewModel(controller,dispatcher,signalPlotter)
            this@edffileanalyzer.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"UpdateSelectionComplete",@(src,args)this.cb_UpdateSelectionComplete(src,args));
        end

        function cb_UpdateSelectionComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "signalPropertiesTable"
                controllerID="signalPropertiesTableWidget";
                messageID="replaceAllData";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="signalsTableWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end
    end
end