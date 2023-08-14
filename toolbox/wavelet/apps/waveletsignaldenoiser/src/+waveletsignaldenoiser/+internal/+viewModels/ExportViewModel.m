

classdef ExportViewModel<waveletsignaldenoiser.internal.viewModels.ViewModelBase


    methods

        function this=ExportViewModel(controller,dispatcher,signalPlotter)
            this@waveletsignaldenoiser.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"ExportDenoisedSignalComplete",@(src,args)this.cb_ExportDenoisedSignalComplete(src,args));
            addlistener(this.Controller,"GenerateMATLABScriptComplete",@(src,args)this.cb_GenerateMATLABScriptComplete(src,args));
        end

        function cb_ExportDenoisedSignalComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "showConfirmationDialogForExportDenoisedSignal"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "showAlertDialog"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "setTextInStatusLabel"
                controllerID="statusBarWidget";
                data=args.Data;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_GenerateMATLABScriptComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "showAlertDialog"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "hideBusyOverlay"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end
    end
end