

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
            [coefficientSignalIDsToBeRemoved,allSignalIDsToBeRemoved]=this.Model.resetDataModel();


            this.Model.removeSignalIDs(allSignalIDsToBeRemoved);


            coefficientAxesData.messageID="removeCoefficientsLevels";
            coefficientAxesData.data.signalIDs=coefficientSignalIDsToBeRemoved;
            coefficientAxesData.data.destroy=true;
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(coefficientAxesData));


            denoisingAxesData.messageID="removeDenoisingAxes";
            denoisingAxesData.data.signalID=signalIDForImportedSignalID;
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(denoisingAxesData));


            tableData.messageID="denoisingTableData";
            this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(tableData));


            tableData.messageID="currentWaveletParametersTableData";
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