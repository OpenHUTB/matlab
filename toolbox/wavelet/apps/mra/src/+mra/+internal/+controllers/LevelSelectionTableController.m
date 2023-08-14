

classdef LevelSelectionTableController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
UpdateIncludeInReconstructionComplete
UpdateShowInDecompositionComplete
PlotSignalOnInclude
    end

    properties(Constant)
        ControllerID="LevelSelectionTableController";
    end


    methods(Hidden)
        function this=LevelSelectionTableController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"updateincludeinreconstruction",'callback',@this.cb_UpdateIncludeInReconstruction);
            struct('messageID',"updateshowindecomposition",'callback',@this.cb_UpdateShowInDecomposition);
            ];
        end


        function cb_UpdateIncludeInReconstruction(this,args)

            selectedSignalID=args.data.selectedSignalID;
            scenarioID=args.data.selectedScenarioID;


            this.Model.updateIsIncludedInScenarios(scenarioID,selectedSignalID);


            lineData.messageID="updateAlphaOnInclude";
            lineData.data.signalID=selectedSignalID;
            lineData.data.isIncluded=logical(this.Model.getIncludeStatus(scenarioID,selectedSignalID));
            this.notify("UpdateIncludeInReconstructionComplete",sigwebappsutils.internal.EventData(lineData));


            includeData=this.Model.getSignalDataOnInclude(scenarioID);
            this.notify("PlotSignalOnInclude",sigwebappsutils.internal.EventData(includeData));
        end

        function cb_UpdateShowInDecomposition(this,args)

            selectedSignalID=args.data.selectedSignalID;
            decompositionSignalIDsAfterSelectedRow=this.Model.updateIsShownInScenarios(args.data.selectedScenarioID,selectedSignalID);

            decompositionAxesData.data.signalIDs=selectedSignalID;

            if args.data.isChecked

                decompositionAxesData.data.lastSignalIDs=decompositionSignalIDsAfterSelectedRow;
                decompositionAxesData.data.create=false;
                decompositionAxesData.messageID="updateDecompositionLevels";
            else

                decompositionAxesData.data.destroy=false;
                decompositionAxesData.messageID="removeDecompositionLevels";
            end
            this.notify("UpdateShowInDecompositionComplete",sigwebappsutils.internal.EventData(decompositionAxesData));


            xLabel=this.Model.getXLabelForAxes();
            decompositionAxesXLabelData.messageID="setXLabelInLastVisibleAxes";
            decompositionAxesXLabelData.data.xLabel=xLabel;
            this.notify("UpdateShowInDecompositionComplete",sigwebappsutils.internal.EventData(decompositionAxesXLabelData));


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("UpdateShowInDecompositionComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end
    end
end