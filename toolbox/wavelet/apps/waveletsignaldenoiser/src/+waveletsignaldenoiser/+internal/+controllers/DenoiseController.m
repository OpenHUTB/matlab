

classdef DenoiseController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
DenoiseComplete
GetWaveletNumbersComplete
GetLevelsAndThresholdingRulesComplete
GetMaxLevelsComplete
AddNewScenarioComplete
PlotSignals
    end

    properties(Constant)
        ControllerID="DenoiseController";
    end


    methods(Hidden)
        function this=DenoiseController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"denoise",'callback',@this.cb_Denoise);
            struct('messageID',"getwaveletnumbers",'callback',@this.cb_GetWaveletNumbers);
            struct('messageID',"getlevelsandthresholdingrules",'callback',@this.cb_GetLevelsAndThresholdingRules);
            struct('messageID',"getmaxlevels",'callback',@this.cb_GetMaxLevels);
            struct('messageID',"addnewdenoisedsignal",'callback',@this.cb_AddNewScenario);
            ];
        end


        function cb_Denoise(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            [signalIDsToBeAddedOrRemoved,numberOfsignals,approxSignalID,isDenoisingRequired]=...
            this.Model.denoise(selectedScenarioID,args.data.denoisingParams);

            if isDenoisingRequired

                currentWaveletParametersTableData.messageID="currentWaveletParametersTableData";
                currentWaveletParametersTableData.data=this.Model.getDataForCurrentWaveletParametersTable(selectedScenarioID);
                this.notify("DenoiseComplete",sigwebappsutils.internal.EventData(currentWaveletParametersTableData));


                if numberOfsignals
                    coefficientsAxesData.data.signalIDs=signalIDsToBeAddedOrRemoved;

                    if numberOfsignals>0
                        coefficientsAxesData.data.lastSignalIDs=approxSignalID;
                        coefficientsAxesData.data.create=true;
                        coefficientsAxesData.messageID="updateCoefficientsLevels";
                    else
                        coefficientsAxesData.data.destroy=true;
                        coefficientsAxesData.messageID="removeCoefficientsLevels";
                    end
                else


                    coefficientsAxesData.messageID="updateFitToViewFlag";
                    coefficientsAxesData.data=true;
                end

                this.notify("DenoiseComplete",sigwebappsutils.internal.EventData(coefficientsAxesData));


                signalData=this.Model.getSignalData(selectedScenarioID,...
                args.data.originalCoefficientsCheckBoxStatus,...
                args.data.denoisedCoefficientsCheckBoxStatus);
                this.notify("PlotSignals",sigwebappsutils.internal.EventData(signalData));
            else

                busyOverLayData.messageID="hideBusyOverlay";
                this.notify("DenoiseComplete",sigwebappsutils.internal.EventData(busyOverLayData));
            end
        end

        function cb_GetWaveletNumbers(this,args)

            data.messageID="setWaveletNumbers";
            data.data.WaveletNumbers=this.Model.getWaveletNumber(args.data.waveletName);
            data.data.updateMaxLevels=true;
            this.notify("GetWaveletNumbersComplete",sigwebappsutils.internal.EventData(data));


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("GetWaveletNumbersComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_GetLevelsAndThresholdingRules(this,args)

            denoisingMethod=args.data.denoisingMethod;
            data.messageID="setLevelsAndThresholdingRules";
            data.data.MaxLevels=this.Model.getMaxLevels(denoisingMethod,args.data.wname);
            data.data.ThresholdRules=this.Model.getThresholdRules(denoisingMethod);
            this.notify("GetLevelsAndThresholdingRulesComplete",sigwebappsutils.internal.EventData(data));


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("GetLevelsAndThresholdingRulesComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_GetMaxLevels(this,args)

            data.messageID="setMaxLevels";
            data.data.MaxLevels=this.Model.getMaxLevels(args.data.denoisingMethod,args.data.wname);
            this.notify("GetMaxLevelsComplete",sigwebappsutils.internal.EventData(data));


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("GetMaxLevelsComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_AddNewScenario(this,args)
            selectedScenarioID=args.data.selectedScenarioID;

            if args.data.isDuplicate
                newScenarioID=this.Model.duplicateScenario(selectedScenarioID);
            else
                newScenarioID=this.Model.addNewScenario();
            end


            coefficientSignalIDsToBeRemoved=this.Model.getOriginalCoefficientSignalIDsForScenario(selectedScenarioID);

            coefficientSignalIDsToBeAdded=this.Model.createSignalIDs(newScenarioID);


            toolstripData.messageID="setValuesInToolstrip";
            toolstripData.data=this.Model.getDataForToolstrip(newScenarioID);
            toolstripData.data.enableSignalDenoiserTab=false;
            this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(toolstripData));


            denoisedImportTableData.messageID="denoisedTableData";
            denoisedImportTableData.data=this.Model.getDataForDenoisedSignalsTable(newScenarioID);
            this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(denoisedImportTableData));


            currentWaveletParametersTableData.messageID="currentWaveletParametersTableData";
            currentWaveletParametersTableData.data=this.Model.getDataForCurrentWaveletParametersTable(newScenarioID);
            this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(currentWaveletParametersTableData));


            coefficientsAxesData.messageID="replaceCoefficientsLevels";
            coefficientsAxesData.data=struct;
            coefficientsAxesData.data.signalIDs=coefficientSignalIDsToBeAdded;
            coefficientsAxesData.data.signalIDsToBeRemoved=coefficientSignalIDsToBeRemoved;
            coefficientsAxesData.data.destroy=false;
            coefficientsAxesData.data.create=true;
            this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(coefficientsAxesData));


            signalData=this.Model.getSignalData(newScenarioID,...
            args.data.originalCoefficientsCheckBoxStatus,...
            args.data.denoisedCoefficientsCheckBoxStatus);
            this.notify("PlotSignals",sigwebappsutils.internal.EventData(signalData));


            denoisingAxesData.messageID="updateDenoisingSignalWidth";
            denoisingAxesData.data.previousDenoisingSignalID=this.Model.getDenoisedSignalIDInScenario(selectedScenarioID);
            this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(denoisingAxesData));
        end
    end
end