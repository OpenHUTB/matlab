

classdef SignalTableControllerFeatureExtractionMode<handle
    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='SignalTableControllerFeatureExtractionMode';
    end

    events
CheckUnCheckSignalComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FeatureExtractionDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.FeatureExtraction.SignalTableControllerFeatureExtractionMode(dispatcherObj,modelObj);
            end

            ret=ctrlObj;
        end
    end



    methods(Access=protected)
        function this=SignalTableControllerFeatureExtractionMode(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.FeatureExtraction.SignalTableControllerFeatureExtractionMode;

            this.Dispatcher.subscribe(...
            [SignalTableControllerFeatureExtractionMode.ControllerID,'/','checked'],...
            @(arg)cb_Checked(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableControllerFeatureExtractionMode.ControllerID,'/','unchecked'],...
            @(arg)cb_UnChecked(this,arg));
        end
    end

    methods(Hidden)




        function cb_Checked(this,args)
            clientID=args.clientID;
            memberIDs=args.data.memberIDs;
            if isfield(args.data,"selectedSignals")

                this.cb_UnChecked(args);


                if isnumeric(args.data.selectedSignals)


                    this.Model.setSelectedSignalIndices(args.data.selectedSignals);
                else

                    this.Model.setSelectedSignalIndices(1);
                end
            end
            for idx=1:numel(memberIDs)
                memberID=memberIDs(idx);
                this.Model.updatedCheckedMemberIDs(memberID,'check');

                plottedSignalIDs=this.Model.getSelectedSignalIDs(memberID);
                signalsOutData=this.Model.getSignalsDataForAxes(plottedSignalIDs,'check');
                this.notify('CheckUnCheckSignalComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                'messageID','plotMultipleSignalsInDisplay',...
                'data',signalsOutData)));

                axesLabelData=this.Model.getLabelDataForAxesForPlot(memberID);
                if~isempty(axesLabelData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=axesLabelData.SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesLabelData;
                    this.notify('CheckUnCheckSignalComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                    'messageID','axesLabelData',...
                    'data',dataPacket)));
                end
            end
        end

        function cb_UnChecked(this,args)
            clientID=args.clientID;
            memberIDs=args.data.memberIDs;
            unplottedSignalIDs=[];
            for idx=1:numel(memberIDs)
                memberID=memberIDs(idx);
                this.Model.updatedCheckedMemberIDs(memberID,'uncheck');

                unplottedSignalIDs=[unplottedSignalIDs;this.Model.getSelectedSignalIDs(memberID)];
            end
            this.notify('CheckUnCheckSignalComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','clearMultipleSignalsInDisplay','data',unplottedSignalIDs)));
        end
    end
end
