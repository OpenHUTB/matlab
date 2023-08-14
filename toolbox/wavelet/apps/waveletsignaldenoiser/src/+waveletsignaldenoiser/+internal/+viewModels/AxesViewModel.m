

classdef AxesViewModel<waveletsignaldenoiser.internal.viewModels.ViewModelBase


    methods(Hidden)
        function this=AxesViewModel(controller,dispatcher,signalPlotter)
            this@waveletsignaldenoiser.internal.viewModels.ViewModelBase(controller,dispatcher,signalPlotter);
            this.subscribeToControllerEvents();
        end

        function subscribeToControllerEvents(this)
            addlistener(this.Controller,"ToggleSignalsAndCoefficientsComplete",@(src,args)this.cb_ToggleSignalsAndCoefficientsComplete(src,args));
            addlistener(this.Controller,"ToggleSignalsAndCoefficientsFromLegendComplete",@(src,args)this.cb_ToggleSignalsAndCoefficientsFromLegendComplete(src,args));
        end

        function cb_ToggleSignalsAndCoefficientsComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "updateSignalsVisibility"
                controllerID="denoisingAxesWidget";
                data=args.Data.data;
            case "updateCoefficientsVisibility"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            case "changeTestDivTagToHidden"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end

        function cb_ToggleSignalsAndCoefficientsFromLegendComplete(this,~,args)
            messageID=args.Data.messageID;

            switch messageID
            case "updateCoefficientsVisibility"
                controllerID="coefficientsDisplayWidget";
                data=args.Data.data;
            case "toggleCheckboxStatus"
                controllerID="toolstripWidget";
                data=args.Data.data;
            case "changeTestDivTagToHidden"
                controllerID="toolstripWidget";
                data=struct;
            end

            this.publishToClient(controllerID,messageID,data);
        end
    end
end