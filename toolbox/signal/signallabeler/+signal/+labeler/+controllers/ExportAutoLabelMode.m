

classdef ExportAutoLabelMode<handle




    properties(Hidden)
        Model;
        Engine;
    end

    properties(Access=protected)
        Dispatcher;

    end

    properties(Constant)
        ControllerID='ExportAutoLabelMode';
    end

    events
AutoLabelAccept
UpdateLabelComplete
CloseComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.ExportAutoLabelMode(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=ExportAutoLabelMode(dispatcherObj,modelObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.ExportAutoLabelMode;

            this.Dispatcher.subscribe(...
            [ExportAutoLabelMode.ControllerID,'/','cancel'],...
            @(arg)cb_Cancel(this,arg));

            this.Dispatcher.subscribe(...
            [ExportAutoLabelMode.ControllerID,'/','accept'],...
            @(arg)cb_Accept(this,arg));
        end
    end

    methods(Hidden)




        function cb_Cancel(this,args)

            this.Model.undoAutomatedLabelInstance();
            this.Model.setAppName('labeler');
            outData.clientID=args.clientID;
            outData.messageID='clearandswitchview';
            outData.data=struct('hideSpinner',true);
            this.notify('CloseComplete',signal.internal.SAEventData(outData));
        end

        function cb_Accept(this,args)
            this.Model.setAppName('labeler');
            data=args.data;
            clientID=data.signalLabelerClientID;

            info=this.Model.getAutoAddedInstancesNewValueInfo();
            data.numberOfAddedLabelInstance=0;
            if string(data.labelDefintionsData.LabelType)~="attribute"
                if info.NumInstances>0
                    axesOutData=this.Model.getLabelDataOnCreateForAutoLabel(data.labelDefintionsData,info);
                    this.notify('AutoLabelAccept',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','treeTableLabelData',...
                    'data',struct)));


                    for idx=1:numel(axesOutData)

                        dataPacket.clientID=data.signalLabelerClientID;
                        dataPacket.signalID=axesOutData(idx).SignalID;
                        dataPacket.totalChuncks=1;
                        dataPacket.labelData=axesOutData(idx);
                        this.notify('AutoLabelAccept',signal.internal.SAEventData(struct('clientID',clientID,...
                        'messageID','axesLabelData',...
                        'data',dataPacket)));
                    end




                    [data.memberIDs,~]=this.Model.getMemberIDsAndSignalInfoForAutoLabelMode();
                    data.numberOfAddedLabelInstance=numel(info.newInstanceIDs);
                    updateWidgetsOnAutoLabelCompleteData=struct;
                    updateWidgetsOnAutoLabelCompleteData.bEnableUndo=false;
                    updateWidgetsOnAutoLabelCompleteData.bEnableRun=false;
                    this.notify('AutoLabelAccept',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','updateWidgetsOnAutoLabelAccept',...
                    'data',updateWidgetsOnAutoLabelCompleteData)));
                end
            else
                if numel(info.updatedAttrLabelInstanceIDs)>0
                    axesOutData=this.Model.getLabelDataOnAttributeUpdateForAutoLabel(info);

                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','treeTableLabelData',...
                    'data',struct)));


                    for idx=1:numel(axesOutData)

                        dataPacket.clientID=clientID;
                        dataPacket.signalID=axesOutData(idx).SignalID;
                        dataPacket.totalChuncks=1;
                        dataPacket.labelData=axesOutData(idx);
                        this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                        'messageID','axesLabelData',...
                        'data',dataPacket)));
                    end
                    [data.memberIDs,~]=this.Model.getMemberIDsAndSignalInfoForAutoLabelMode();
                    data.numberOfAddedLabelInstance=numel(info.updatedAttrLabelInstanceIDs);
                    updateWidgetsOnAutoLabelCompleteData=struct;
                    updateWidgetsOnAutoLabelCompleteData.bEnableUndo=false;
                    updateWidgetsOnAutoLabelCompleteData.bEnableRun=false;
                    this.notify('AutoLabelAccept',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','updateWidgetsOnAutoLabelAccept',...
                    'data',updateWidgetsOnAutoLabelCompleteData)));
                end
            end
            outData.clientID=args.clientID;
            outData.messageID='clearandswitchview';
            outData.data=struct('hideSpinner',true);
            this.notify('CloseComplete',signal.internal.SAEventData(outData));
        end
    end
end
