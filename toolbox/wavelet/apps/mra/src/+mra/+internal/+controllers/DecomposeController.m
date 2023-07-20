classdef DecomposeController<handle





    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
DecomposeComplete
GetWaveletNumberComplete
AddNewScenarioComplete
UpdateTimeInfoComplete
PlotSignals
    end

    properties(Constant)
        ControllerID="DecomposeController";
    end


    methods(Hidden)
        function this=DecomposeController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"decompose",'callback',@this.cb_Decompose);
            struct('messageID',"getwaveletnumbers",'callback',@this.cb_GetWaveletNumber);
            struct('messageID',"addnewdecomposition",'callback',@this.cb_AddNewScenario);
            struct('messageID',"updatetimeinfo",'callback',@this.cb_UpdateTimeInfo);
            ];
        end


        function cb_Decompose(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            [signalIDsTobeAddedOrRemoved,numberOfsignals,...
            lastDecompositionSignalID,...
            isDecompositionRequired,newScenarioParams]=...
            this.Model.decompose(selectedScenarioID,args.data.decompositionParams);

            if newScenarioParams.Type=="vmd"

                toolstripData.messageID="setVMDFields";
                isTimeInfoNeeded=false;
                if isDecompositionRequired


                    toolstripData.data=this.Model.getDataForToolstrip(selectedScenarioID,isTimeInfoNeeded);
                    toolstripData.data.WaveletSectionData.InitialIMFsSelectedString=newScenarioParams.InitialIMFsSelectedString;
                    toolstripData.data.WaveletSectionData.InitialLMSelectedString=newScenarioParams.InitialLMSelectedString;
                    toolstripData.data.WaveletSectionData.VMDUserSpecificCentralFrequenciesSelectedString=newScenarioParams.VMDUserSpecificCentralFrequenciesSelectedString;
                end
                toolstripData.data.WaveletSectionData.VMDUserSpecificCentralFrequenciesValidFlag=newScenarioParams.VMDUserSpecificCentralFrequenciesValidFlag;
                toolstripData.data.WaveletSectionData.VMDInitialIMFsValidFlag=newScenarioParams.VMDInitialIMFsValidFlag;
                toolstripData.data.WaveletSectionData.VMDInitialLMValidFlag=newScenarioParams.VMDInitialLMValidFlag;
                toolstripData.data.WaveletSectionData.VMDInitialIMFsDisableFlag=newScenarioParams.VMDInitialIMFsDisableFlag;
                toolstripData.data.WaveletSectionData.VMDUserSpecificCentralFrequenciesDisableFlag=newScenarioParams.VMDUserSpecificCentralFrequenciesDisableFlag;
                this.notify("DecomposeComplete",sigwebappsutils.internal.EventData(toolstripData));
            end

            if isDecompositionRequired

                tableData=this.Model.getDataForLevelSelectionTable(selectedScenarioID);
                levelSelectionTableData.messageID="levelSelectionTableData";
                levelSelectionTableData.data=tableData;
                this.notify("DecomposeComplete",sigwebappsutils.internal.EventData(levelSelectionTableData));


                if numberOfsignals
                    decompositionAxesData.data.signalIDs=signalIDsTobeAddedOrRemoved;
                    if numberOfsignals>0
                        decompositionAxesData.data.lastSignalIDs=lastDecompositionSignalID;
                        decompositionAxesData.data.create=true;
                        decompositionAxesData.messageID="updateDecompositionLevels";
                        decompositionAxesData.data.yLabels=tableData(end-numberOfsignals:end-1,2);
                    else
                        decompositionAxesData.data.destroy=true;
                        decompositionAxesData.messageID="removeDecompositionLevels";
                    end
                else


                    decompositionAxesData.messageID="updateFitToViewFlag";
                    decompositionAxesData.data=true;
                end

                this.notify("DecomposeComplete",sigwebappsutils.internal.EventData(decompositionAxesData));


                signalData=this.Model.getSignalData(selectedScenarioID);
                this.notify("PlotSignals",sigwebappsutils.internal.EventData(signalData));
            else

                busyOverLayData.messageID="hideBusyOverlay";
                this.notify("DecomposeComplete",sigwebappsutils.internal.EventData(busyOverLayData));
            end
        end

        function cb_GetWaveletNumber(this,args)

            waveletNumbers=this.Model.getWaveletNumber(args.data.waveletName);
            data.messageID="setWaveletNumbers";
            data.data.WaveletSectionData.WaveletNumbers=waveletNumbers;
            this.notify("GetWaveletNumberComplete",sigwebappsutils.internal.EventData(data));


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("GetWaveletNumberComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_AddNewScenario(this,args)
            selectedScenarioID=args.data.selectedScenarioID;
            if args.data.isDecompositionRequired
                if args.data.isDuplicate
                    newScenarioID=this.Model.duplicateScenario(selectedScenarioID);
                    resetIncludedAndShowStatus=false;
                else
                    newScenarioID=this.Model.addNewScenario(args.data.decompositionType);
                    resetIncludedAndShowStatus=true;
                end


                decompositionSignalIDsToBeRemoved=this.Model.getShownDecompositionSignalIDsForScenario(selectedScenarioID);

                decompositionSignalIDsToBeAdded=this.Model.createSignalIDs(newScenarioID,resetIncludedAndShowStatus);


                toolstripData.messageID="setValuesInToolstrip";
                isTimeInfoNeeded=false;
                toolstripData.data=this.Model.getDataForToolstrip(newScenarioID,isTimeInfoNeeded);
                this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(toolstripData));


                decompositionSignalsTableData.messageID="decompositionTableData";
                decompositionSignalsTableData.data=this.Model.getDataForDecompositionSignalsTable(newScenarioID);
                this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(decompositionSignalsTableData));


                tableData=this.Model.getDataForLevelSelectionTable(newScenarioID);
                levelSelectionTableData.messageID="levelSelectionTableData";
                levelSelectionTableData.data=tableData;
                this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(levelSelectionTableData));


                decompositionAxesData.messageID="replaceDecompositionLevels";
                decompositionAxesData.data=struct;
                decompositionAxesData.data.signalIDs=decompositionSignalIDsToBeAdded;
                decompositionAxesData.data.signalIDsToBeRemoved=decompositionSignalIDsToBeRemoved;
                decompositionAxesData.data.yLabels=tableData(:,2);
                decompositionAxesData.data.xLabel=this.Model.getXLabelForAxes();
                decompositionAxesData.data.destroy=false;
                decompositionAxesData.data.create=true;
                this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(decompositionAxesData));


                signalData=this.Model.getSignalData(newScenarioID);
                this.notify("PlotSignals",sigwebappsutils.internal.EventData(signalData));


                reconstructionAxesData.messageID="updateReconstructionLineWidth";
                reconstructionAxesData.data.previousReconstructionSignalID=this.Model.getReconstructionSignalIDInScenario(selectedScenarioID);
                this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(reconstructionAxesData));
            else

                busyOverLayData.messageID="hideBusyOverlay";
                this.notify("AddNewScenarioComplete",sigwebappsutils.internal.EventData(busyOverLayData));
            end
        end

        function cb_UpdateTimeInfo(this,args)

            selectedScenarioID=args.data.selectedScenarioID;

            this.Model.updateTimeInfo(args.data.timeInfo);


            this.Model.updateFrequencyRangesForScenario(selectedScenarioID);


            xLabel=this.Model.getXLabelForAxes();
            decompositionAxesData.messageID="updateXLabelInDecompositionAxes";
            decompositionAxesData.data.xLabel=xLabel;
            this.notify("UpdateTimeInfoComplete",sigwebappsutils.internal.EventData(decompositionAxesData));


            reconstructionAxesData.messageID="updateXLabelInReconstructionAxes";
            reconstructionAxesData.data.xLabel=xLabel;
            this.notify("UpdateTimeInfoComplete",sigwebappsutils.internal.EventData(reconstructionAxesData));



            xRulerMultiplierData.messageID="updateXRulerMultiplier";
            xRulerMultiplierData.data.multiplier=this.Model.getMultiplierForTimeInfo();
            this.notify("UpdateTimeInfoComplete",sigwebappsutils.internal.EventData(xRulerMultiplierData));


            levelSelectionTableFrequencyColumnHeaderData.messageID="updateFrequencyColumnHeader";
            levelSelectionTableFrequencyColumnHeaderData.data=this.Model.getFrequencyColumnLabel();
            this.notify("UpdateTimeInfoComplete",sigwebappsutils.internal.EventData(levelSelectionTableFrequencyColumnHeaderData));


            tableData=this.Model.getDataForLevelSelectionTable(selectedScenarioID);
            levelSelectionTableData.messageID="levelSelectionTableData";
            levelSelectionTableData.data=tableData;
            this.notify("UpdateTimeInfoComplete",sigwebappsutils.internal.EventData(levelSelectionTableData));


            signalData=this.Model.getSignalData(selectedScenarioID);
            this.notify("PlotSignals",sigwebappsutils.internal.EventData(signalData));
        end
    end
end
