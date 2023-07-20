

classdef ExportFastLabelMode<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='ExportFastLabelMode';
    end

    events
CloseComplete
CreateLabelComplete
UpdateLabelComplete
DeleteLabelComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FastLabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.ExportFastLabelMode(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=ExportFastLabelMode(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.ExportFastLabelMode;


            this.Dispatcher.subscribe(...
            [ExportFastLabelMode.ControllerID,'/','closefastlabel'],...
            @(arg)cb_CloseFastLabel(this,arg));
        end

    end

    methods(Hidden)




        function cb_CloseFastLabel(this,args)

            this.exportLabelDataToLabeler(args);


            allCheckableSignalIDs=this.Model.getAllCheckableSignalIDs();
            this.notify('CloseComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','resetDisplay','data',allCheckableSignalIDs)));


            this.notify('CloseComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','clearFastLabelMode','data',struct)));


            this.Model.resetModel();


            this.Model.setAppName('labeler');


            this.notify('CloseComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','closeFastLabelMode','data',struct('hideSpinner',true,'standAloneFlag',true))));

        end

        function exportLabelDataToLabeler(this,args)
            signalLabelerClientID=num2str(args.data.signalLabelerClientID);

            fastLabelCreatedLabelData=this.Model.getFastLabelCreatedLabelData();
            labelerUpdatedLabelData=this.Model.getLabelerUpdatedLabelData();
            labelerDeletedLabelData=this.Model.getLabelerDeletedLabelData();
            isHighlightedFlag=false;

            if~isempty(fastLabelCreatedLabelData)
                labelData.LabelInstanceID=[fastLabelCreatedLabelData.LabelInstanceID];
                labelData.ParentLabelInstanceID=[fastLabelCreatedLabelData.ParentLabelInstanceID];
                this.notify('CreateLabelComplete',signal.internal.SAEventData(struct('clientID',signalLabelerClientID,...
                'messageID','treeTableLabelData','data',struct)));


                isVisibleFlag=false;
                axesOutData=this.Model.getLabelDataForAxes(labelData,isVisibleFlag,isHighlightedFlag,true);
                for idx=1:numel(axesOutData)

                    dataPacket.clientID=signalLabelerClientID;
                    dataPacket.signalID=axesOutData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesOutData(idx);
                    this.notify('CreateLabelComplete',signal.internal.SAEventData(struct('clientID',signalLabelerClientID,...
                    'messageID','axesLabelData','data',dataPacket)));
                end
            end

            if~isempty(labelerUpdatedLabelData)
                labelData.LabelInstanceID=[labelerUpdatedLabelData.LabelInstanceID];
                labelData.ParentLabelInstanceID=[labelerUpdatedLabelData.ParentLabelInstanceID];
                this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',signalLabelerClientID,...
                'messageID','treeTableLabelData','data',struct)));


                isVisibleFlag="keepCurrentState";
                axesOutData=this.Model.getLabelDataForAxes(labelData,isVisibleFlag,isHighlightedFlag,true);
                for idx=1:numel(axesOutData)

                    dataPacket.clientID=signalLabelerClientID;
                    dataPacket.signalID=axesOutData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesOutData(idx);
                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',signalLabelerClientID,...
                    'messageID','axesLabelData','data',dataPacket)));
                end
            end

            if~isempty(labelerDeletedLabelData)

                allLabelInstanceIDs=[];
                allLabelInstanceParentRowIDs=[];
                allMemberIDs=[];
                allLabelInstanceLabelDefIDs=[];



                for idx=1:numel(labelerDeletedLabelData)
                    labelInstances=labelerDeletedLabelData(idx).LabelInstanceID(:);
                    allLabelInstanceIDs=[allLabelInstanceIDs;labelInstances];%#ok<*AGROW>
                    labelInstanceParentRowIDs=labelerDeletedLabelData(idx).LabelInstanceParentRowID(:);
                    allLabelInstanceParentRowIDs=[allLabelInstanceParentRowIDs;labelInstanceParentRowIDs];
                    allMemberIDs=[allMemberIDs;repmat(labelerDeletedLabelData(idx).MemberID,numel(labelInstances),1)];
                    allLabelInstanceLabelDefIDs=[allLabelInstanceLabelDefIDs;repmat(labelerDeletedLabelData(idx).LabelDefinitionID,numel(labelInstances),1)];
                end
                memberIDs=unique(allMemberIDs,'stable');
                for memIdx=1:numel(memberIDs)
                    info.removedLabelInstanceMemberID=memberIDs(memIdx);
                    currentMemberDataIdx=(allMemberIDs==info.removedLabelInstanceMemberID);
                    info.removedLabelInstanceIDs=allLabelInstanceIDs(currentMemberDataIdx);
                    info.removedLabelInstanceLabelDefIDs=allLabelInstanceLabelDefIDs(currentMemberDataIdx);
                    info.removedLabelInstanceParentRowIDs=allLabelInstanceParentRowIDs(currentMemberDataIdx);
                    axesOutData=this.Model.getLabelDataForAxesOnDelete(info,true);
                    for idx=1:numel(axesOutData)

                        dataPacket.clientID=signalLabelerClientID;
                        dataPacket.signalID=axesOutData(idx).SignalID;
                        dataPacket.totalChuncks=1;
                        dataPacket.labelData=axesOutData(idx);
                        this.notify('DeleteLabelComplete',signal.internal.SAEventData(struct('clientID',signalLabelerClientID,...
                        'messageID','axesLabelData','data',dataPacket)));
                    end
                end


                tableOutData=struct('rowIDs',allLabelInstanceIDs,...
                'parentRowIDs',allLabelInstanceParentRowIDs);
                this.notify('DeleteLabelComplete',signal.internal.SAEventData(struct('clientID',signalLabelerClientID,...
                'messageID','treeTableLabelData','data',tableOutData)));
            end
        end
    end
end
