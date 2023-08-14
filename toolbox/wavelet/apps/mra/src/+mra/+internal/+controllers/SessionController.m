

classdef SessionController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
NewSessionComplete
    end

    properties(Constant)
        ControllerID="SessionController";
    end


    methods(Hidden)
        function this=SessionController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"newsession",'callback',@this.cb_NewSession);
            ];
        end



        function cb_NewSession(this,args)


            signalIDForImportedSignalID=this.Model.getSignalIDForImportedSignal();
            [decompositionSignalIDsRemoved,allSignalIDsToBeRemoved]=this.Model.resetModel();


            this.Model.removeSignalIDs(allSignalIDsToBeRemoved);


            decompositionAxesData.messageID="removeDecompositionLevels";
            decompositionAxesData.data.signalIDs=decompositionSignalIDsRemoved;
            decompositionAxesData.data.destroy=true;
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(decompositionAxesData));


            reconstructionAxesData.messageID="removeReconstruction";
            reconstructionAxesData.data.signalID=signalIDForImportedSignalID;
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(reconstructionAxesData));


            tableData.messageID="decompositionTableData";
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(tableData));


            levelSelectionTableFrequencyColumnHeaderData.messageID="resetFrequencyColumnHeader";
            levelSelectionTableFrequencyColumnHeaderData.data="";
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(levelSelectionTableFrequencyColumnHeaderData));


            tableData.messageID="levelSelectionTableData";
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(tableData));


            toolstripData.messageID="resetToolstrip";
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(toolstripData));

            if args.data.newSessionBeforeImport


                newSessionCompleteData.messageID="importAfterNewSession";
                this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(newSessionCompleteData));
            else

                busyOverLayData.messageID="hideBusyOverlay";
                this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(busyOverLayData));
            end
        end
    end
end