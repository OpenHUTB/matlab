classdef AutoLabeler<handle






    properties(Hidden)
        Model;
        Engine;
    end

    properties(Access=protected)
        CurrentClientID;
        Dispatcher;
        ExceptionKeywordArray;
        CurrentAutoLabelingObj;
        RequestedSignalInfos;
        RequestedMemberIDs;
    end

    properties(Constant)
        ControllerID='AutoLabeler';
    end

    events
AutoLabelComplete
UndoAutoLabelComplete
UpdateLabelComplete
DeleteLabelComplete
AutoLabelSettingsWidgetData
DirtyStateChanged
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.AutoLabeling.AutoLabeler(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=AutoLabeler(dispatcherObj,modelObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.AutoLabeling.AutoLabeler;

            this.Dispatcher.subscribe(...
            [AutoLabeler.ControllerID,'/','autolabelsignalsok'],...
            @(arg)cb_AutoLabelSignalsOk(this,arg));

            this.Dispatcher.subscribe(...
            [AutoLabeler.ControllerID,'/','autolabelsignalsundo'],...
            @(arg)cb_AutoLabelSignalsUndo(this,arg));

            this.Dispatcher.subscribe(...
            [AutoLabeler.ControllerID,'/','autolabelsignalspreshow'],...
            @(arg)cb_AutoLabelSignalsWidgetPreShow(this,arg));

            this.Dispatcher.subscribe(...
            [AutoLabeler.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end
    end

    methods(Hidden)

        function cleanupForAutoLabeling(this)

            if this.CurrentAutoLabelingObj.NeedCleanUp
                this.notify('AutoLabelComplete',signal.internal.SAEventData(struct('clientID',this.CurrentClientID,...
                'messageID','autoLabelFailed',...
                'errorID','CleanUp')));
            end
        end




        function cb_HelpButton(~,args)

            labelerName=args.data.lablerInfo.functionID;
            switch(labelerName)
            case 'PeakLabeler'
                signal.labeler.controllers.SignalLabelerHelp('peakLabelerHelp');
            otherwise
                signal.labeler.controllers.SignalLabelerHelp('customLabelerHelp');
            end
        end

        function cb_AutoLabelSignalsOk(this,args)

            data=args.data;
            this.CurrentClientID=args.clientID;



            if any(strcmp(data.lablerInfo.functionType,{'sptSingleLabelDef','sptCustomSingleLabelDef'}))

                switch data.lablerInfo.functionID
                case 'PeakLabeler'
                    this.CurrentAutoLabelingObj=signal.labeler.controllers.AutoLabeling.PeakLabeler(this.Model,data);
                case 'SpeechDetector'
                    this.CurrentAutoLabelingObj=audio.labeler.internal.autolabeling.DetectSpeechLabeler(this.Model,data);
                case 'SpeechToText'
                    this.CurrentAutoLabelingObj=audio.labeler.internal.autolabeling.SpeechToTextLabeler(this.Model,data);
                otherwise
                    this.CurrentAutoLabelingObj=signal.labeler.controllers.AutoLabeling.CustomLabeler(this.Model,data);
                end
                this.setupRequestedMemberIDsAndSignalInfos(data);

                [successFlag,exceptionKeyword,info]=this.CurrentAutoLabelingObj.addAutomatedLabelInstance(this.RequestedMemberIDs,this.RequestedSignalInfos,@this.cleanupForAutoLabeling);

                if successFlag
                    this.Model.setAutoLabelSettingsWidgetData(data.lablerInfo.functionID,data.lablerInfo.settings);
                    data.numberOfAddedLabelInstance=0;
                    data.isTimeSpecified=this.Model.getIsTimeSpecified();
                    if string(data.labelDefintionsData.LabelType)~="attribute"
                        if info.NumInstances>0
                            axesOutData=this.Model.getLabelDataOnCreateForAutoLabel(data.labelDefintionsData,info);
                            this.notify('AutoLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                            'messageID','treeTableLabelData',...
                            'data',struct)));


                            for idx=1:numel(axesOutData)

                                dataPacket.clientID=args.clientID;
                                dataPacket.signalID=axesOutData(idx).SignalID;
                                dataPacket.totalChuncks=1;
                                dataPacket.labelData=axesOutData(idx);
                                this.notify('AutoLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                                'messageID','axesLabelData',...
                                'data',dataPacket)));
                            end





                            data.memberIDs=this.RequestedMemberIDs;
                            data.numberOfAddedLabelInstance=numel(info.newInstanceIDs);
                            updateWidgetsOnAutoLabelCompleteData=struct;
                            updateWidgetsOnAutoLabelCompleteData.bEnableUndo=true;
                            updateWidgetsOnAutoLabelCompleteData.bEnableRun=false;
                            this.notify('AutoLabelComplete',signal.internal.SAEventData(struct('clientID',this.CurrentClientID,...
                            'messageID','updateWidgetsOnAutoLabelComplete',...
                            'data',updateWidgetsOnAutoLabelCompleteData)));
                        end
                    else
                        if numel(info.updatedAttrLabelInstanceIDs)>0
                            axesOutData=this.Model.getLabelDataOnAttributeUpdateForAutoLabel(info);

                            this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                            'messageID','treeTableLabelData',...
                            'data',struct)));


                            for idx=1:numel(axesOutData)

                                dataPacket.clientID=args.clientID;
                                dataPacket.signalID=axesOutData(idx).SignalID;
                                dataPacket.totalChuncks=1;
                                dataPacket.labelData=axesOutData(idx);
                                this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                                'messageID','axesLabelData',...
                                'data',dataPacket)));
                            end
                            data.memberIDs=this.RequestedMemberIDs;
                            data.numberOfAddedLabelInstance=numel(info.updatedAttrLabelInstanceIDs);
                            updateWidgetsOnAutoLabelCompleteData=struct;
                            updateWidgetsOnAutoLabelCompleteData.bEnableUndo=true;
                            updateWidgetsOnAutoLabelCompleteData.bEnableRun=false;
                            this.notify('AutoLabelComplete',signal.internal.SAEventData(struct('clientID',this.CurrentClientID,...
                            'messageID','updateWidgetsOnAutoLabelComplete',...
                            'data',updateWidgetsOnAutoLabelCompleteData)));
                        end
                    end

                    dirtyStateChanged=this.Model.setDirty(true);
                    if dirtyStateChanged
                        this.changeAppTitle(this.Model.isDirty());
                        this.notify('DirtyStateChanged',...
                        signal.internal.SAEventData(struct('clientID',str2double(args.clientID))));
                    end
                else

                    this.notify('AutoLabelComplete',signal.internal.SAEventData(struct('clientID',this.CurrentClientID,...
                    'messageID','autoLabelFailed',...
                    'errorID',exceptionKeyword)));
                end
                this.notify('AutoLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','hideSpinner',...
                'data',data)));
            end
        end

        function cb_AutoLabelSignalsUndo(this,args)
            info=this.Model.undoAutomatedLabelInstance();
            evtName='DeleteLabelComplete';
            treeTableData=struct('rowIDs',info.removedLabelInstanceIDs,...
            'parentRowIDs',info.removedLabelInstanceParentRowIDs);
            if isempty(info.removedLabelInstanceIDs)
                evtName='UpdateLabelComplete';
            end

            axesLabelOutData=this.Model.getLabelDataOnUndoForAutoLabel(info);
            this.notify(evtName,signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','treeTableLabelData',...
            'data',treeTableData)));
            for idx=1:numel(axesLabelOutData)
                axesLabelData=axesLabelOutData(idx);
                dataPacket.clientID=args.clientID;
                dataPacket.signalID=axesLabelData.SignalID;
                dataPacket.totalChuncks=1;
                dataPacket.labelData=axesLabelData;
                this.notify(evtName,signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','axesLabelData',...
                'data',dataPacket)));
            end
            this.notify('UndoAutoLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','hideSpinner',...
            'data',struct)));
        end

        function cb_AutoLabelSignalsWidgetPreShow(this,args)
            data=args.data;
            data.settings=this.Model.getAutoLabelSettingsWidgetData(data.lablerInfo.functionID);
            data.isTimeSpecified=this.Model.getIsTimeSpecified();
            this.notify('AutoLabelSettingsWidgetData',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',data)));
        end
    end

    methods(Access=protected)
        function setupRequestedMemberIDsAndSignalInfos(this,data)
            if~strcmp(this.Model.getAppName(),'autoLabelMode')
                this.RequestedSignalInfos=data.signalInfo;
                this.RequestedMemberIDs=string(data.memberIDs);
            else
                [this.RequestedMemberIDs,this.RequestedSignalInfos]=this.Model.getMemberIDsAndSignalInfoForAutoLabelMode();
            end
        end
    end

    methods
        function changeAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end
    end
end
