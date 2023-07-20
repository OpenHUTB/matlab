

classdef AxesController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
ToggleSignalsAndCoefficientsComplete
ToggleSignalsAndCoefficientsFromLegendComplete
    end

    properties(Constant)
        ControllerID="AxesController";
    end


    methods(Hidden)
        function this=AxesController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"togglesignalsandcoefficients",'callback',@this.cb_ToggleSignalsAndCoefficients);
            struct('messageID',"togglesignalsandcoefficientsfromlegend",'callback',@this.cb_ToggleSignalsAndCoefficientsFromLegend);
            ];
        end



        function cb_ToggleSignalsAndCoefficients(this,args)

            operationType=args.data.operationType;
            switch operationType
            case "signalData"
                signalIDs=this.Model.getSignalIDForImportedSignal();
                messageID="updateSignalsVisibility";
            case "approximationData"
                signalIDs=this.Model.getSignalIDForApproxSignal();
                messageID="updateSignalsVisibility";
            case "originalCoefficients"
                signalIDs=this.Model.getAllOriginalCoefficientSignalIDs();
                messageID="updateCoefficientsVisibility";
            case "denoisedCoefficients"
                signalIDs=this.Model.getAllDenoisedCoefficientSignalIDs();
                messageID="updateCoefficientsVisibility";
            end


            axesData.messageID=messageID;
            axesData.data.signalIDs=signalIDs;
            axesData.data.isVisible=args.data.isVisible;
            this.notify("ToggleSignalsAndCoefficientsComplete",sigwebappsutils.internal.EventData(axesData));


            busyOverLayData.messageID="changeTestDivTagToHidden";
            this.notify("ToggleSignalsAndCoefficientsComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_ToggleSignalsAndCoefficientsFromLegend(this,args)
            selectedScenarioID=args.data.selectedScenarioID;
            toggledSignalID=args.data.toggledSignalID;
            isVisible=args.data.isVisible;

            originalCoefficientSignalIDs=this.Model.getOriginalCoefficientSignalIDsForScenario(selectedScenarioID);
            denoisedCoefficientSignalIDs=this.Model.getDenoisedCoefficientSignalIDsForScenario(selectedScenarioID);

            isDenoisedSignalID=false;
            isCoefficientSignalID=false;
            switch toggledSignalID
            case originalCoefficientSignalIDs(1)
                signalIDs=this.Model.getAllOriginalCoefficientSignalIDs();
                legendType="originalCoefficients";
                isCoefficientSignalID=true;
            case denoisedCoefficientSignalIDs(1)
                signalIDs=this.Model.getAllDenoisedCoefficientSignalIDs();
                legendType="denoisedCoefficients";
                isCoefficientSignalID=true;
            case this.Model.getSignalIDForImportedSignal()
                legendType="signalData";
            case this.Model.getSignalIDForApproxSignal()
                legendType="approximationData";
            otherwise
                isDenoisedSignalID=true;
            end

            if isCoefficientSignalID

                axesData.messageID="updateCoefficientsVisibility";
                axesData.data.signalIDs=signalIDs;
                axesData.data.isVisible=isVisible;
                this.notify("ToggleSignalsAndCoefficientsFromLegendComplete",sigwebappsutils.internal.EventData(axesData));
            end

            if~isDenoisedSignalID

                toolstripData.messageID="toggleCheckboxStatus";
                toolstripData.data.type=legendType;
                toolstripData.data.isChecked=isVisible;
                this.notify("ToggleSignalsAndCoefficientsFromLegendComplete",sigwebappsutils.internal.EventData(toolstripData));
            end


            busyOverLayData.messageID="changeTestDivTagToHidden";
            this.notify("ToggleSignalsAndCoefficientsFromLegendComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end
    end
end