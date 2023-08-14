

classdef AxesController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
PlotSignalOnInclude
UpdateIncludeInReconstructionComplete
    end

    properties(Constant)
        ControllerID="AxesController";
    end


    methods(Hidden)
        function this=AxesController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"updateincludeinreconstruction",'callback',@this.cb_UpdateIncludeInReconstruction);
            ];
        end



        function cb_UpdateIncludeInReconstruction(this,args)

            selectedSignalID=args.data.selectedSignalID;
            selectedScenarioID=args.data.selectedScenarioID;


            this.Model.updateIsIncludedInScenarios(selectedScenarioID,selectedSignalID);


            lineData.messageID="updateAlphaOnInclude";
            lineData.data.signalID=selectedSignalID;
            lineData.data.isIncluded=logical(this.Model.getIncludeStatus(selectedScenarioID,selectedSignalID));
            this.notify("UpdateIncludeInReconstructionComplete",sigwebappsutils.internal.EventData(lineData));



            levelSelectionTableData.messageID="toggleIncludeCheckBoxState";
            levelSelectionTableData.data.rowID=selectedSignalID;
            levelSelectionTableData.data.isIncluded=logical(this.Model.getIncludeStatus(selectedScenarioID,selectedSignalID));
            this.notify("UpdateIncludeInReconstructionComplete",sigwebappsutils.internal.EventData(levelSelectionTableData));

            includeData=this.Model.getSignalDataOnInclude(selectedScenarioID);
            this.notify("PlotSignalOnInclude",sigwebappsutils.internal.EventData(includeData));
        end
    end
end