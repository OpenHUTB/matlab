

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


    methods
        function this=SessionController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"newsession",'callback',@this.cb_NewSession);
            ];
        end
    end


    methods(Hidden)
        function cb_NewSession(this,args)

            isNewSessionBeforeImport=args.data.newSessionBeforeImport;
            if isNewSessionBeforeImport
                [validFileNameFlag,errorMsg]=this.Model.setFileInfo(args.data.fileName,true);
            else
                validFileNameFlag=true;
            end

            if validFileNameFlag
                isAppHasSignals=this.Model.isAppHasSignals();

                if isAppHasSignals
                    signalIDs=this.Model.resetModel();

                    this.Model.removeSignalIDs(signalIDs);
                end


                toolstripData.messageID="resetToolstrip";
                this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(toolstripData));


                if isAppHasSignals
                    signalsTableData.messageID="signalsTable";
                    this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(signalsTableData));
                end


                headerPropertiesTableData.messageID="headerPropertiesTable";
                this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(headerPropertiesTableData));


                signalPropertiesTableData.messageID="signalPropertiesTable";
                this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(signalPropertiesTableData));


                annotationsTableData.messageID="annotationsTable";
                this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(annotationsTableData));


                if isAppHasSignals
                    axesData.messageID="removeAxes";
                    this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(axesData));
                end

                if args.data.newSessionBeforeImport


                    newSessionCompleteData.messageID="importAfterNewSession";
                    this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(newSessionCompleteData));
                else

                    busyOverLayData.messageID="hideBusyOverlay";
                    this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(busyOverLayData));
                end
            else

                importFileWidgetData.messageID="setNameTextFieldInErrorState";
                importFileWidgetData.data.errorMsg=errorMsg;
                this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(importFileWidgetData));


                busyOverLayData.messageID="hideBusyOverlay";
                this.notify("NewSessionComplete",sigwebappsutils.internal.EventData(busyOverLayData));
            end
        end
    end
end