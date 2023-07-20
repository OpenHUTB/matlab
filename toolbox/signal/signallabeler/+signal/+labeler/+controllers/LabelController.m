

classdef LabelController<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='LabelController';
    end

    events
CreateLabelComplete
UpdateLabelComplete
DeleteLabelComplete
AnimateLabelComplete
SelectLabelComplete
WidgetPreshowComplete
WidgetGetTableDataComplete
DirtyStateChanged
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.LabelController(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=LabelController(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.LabelController;

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','createlabel'],...
            @(arg)cb_CreateLabel(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','updatelabel'],...
            @(arg)cb_UpdateLabel(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','cancelupdatelabel'],...
            @(arg)cb_CancelUpdateLabel(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','deletelabel'],...
            @(arg)cb_DeleteLabel(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','animatelabel'],...
            @(arg)cb_AnimateLabel(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','selectlabel'],...
            @(arg)cb_SelectLabel(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','editlabelwidgetpreshow'],...
            @(arg)cb_EditLabelWidgetPreshow(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','labelsignalswidgetpreshow'],...
            @(arg)cb_LabelSignalsWidgetPreshow(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','labelsignalswidgetgettabledata'],...
            @(arg)cb_LabelSignalsWidgetGetTableData(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));

            this.Dispatcher.subscribe(...
            [LabelController.ControllerID,'/','deleteallinlabelheader'],...
            @(arg)cb_DeleteAllInLabelHeader(this,arg));
        end
    end

    methods(Hidden)

        function handleRemoveSelectionOnCheckUncheck(this,clientID)
            args.clientID=clientID;
            args.data.labelData.LabelInstanceID="";
            this.cb_SelectLabel(args);
        end



        function cb_HelpButton(~,args)
            data=args.data;
            if strcmp(data.mode,'labelselectedsignals')
                signal.labeler.controllers.SignalLabelerHelp('labelSelectedSignalsHelp');
            elseif strcmp(data.mode,'updateLabelInstance')
                signal.labeler.controllers.SignalLabelerHelp('updateLabelInstanceHelp');
            end
        end

        function cb_CreateLabel(this,args)

            data=args.data;
            signalIDs=data.signalIDs;
            if isempty(signalIDs)

                signalIDs=this.Model.getMemberIDs();
            end



            [successFlag,exceptionKeyword,info]=this.Model.addLabelInstance(signalIDs,data.labelData);%#ok<ASGLU>
            if successFlag
                if info.NumInstances>0
                    if isfield(data,'src')
                        this.notify('CreateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                        'messageID','closeDialog',...
                        'data',data.src)));
                    end


                    this.notify('CreateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','treeTableLabelData',...
                    'data',info.NumInstances)));


                    axesOutData=this.Model.getLabelDataForAxesOnCreate(data.labelData,info);
                    for idx=1:numel(axesOutData)

                        dataPacket.clientID=args.clientID;
                        dataPacket.signalID=axesOutData(idx).SignalID;
                        dataPacket.totalChuncks=1;
                        dataPacket.labelData=axesOutData(idx);
                        this.notify('CreateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                        'messageID','axesLabelData',...
                        'data',dataPacket)));
                    end
                end

                this.onDirtyStateChange(args.clientID);
            else

            end
        end

        function cb_UpdateLabel(this,args,updateModelFlag)

            if nargin<3
                updateModelFlag=true;
            end

            data=args.data;

            if updateModelFlag





                if string(data.labelData.LabelType)=="attribute"&&...
                    ~isfield(data.labelData,'LabelInstanceID')
                    updateAttributeLabel(this,args);
                    return;
                end


                info=this.Model.updateLabelInstance(data.labelData);
            else
                info.successFlag=true;
            end

            if info.successFlag
                if isfield(data,'src')&&strcmp(data.src,'labelSignalsWidgetDialog')
                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','closeDialog',...
                    'data',data.src)));
                end
                isChecked=true;
                if string(data.labelData.LabelType)~="attribute"
                    isChecked=data.labelData.isChecked;
                end

                this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','treeTableLabelData',...
                'data',struct)));




                outData=this.Model.getLabelDataForAxes(data.labelData,isChecked,updateModelFlag);
                for idx=1:numel(outData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=outData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=outData(idx);
                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData',...
                    'data',dataPacket)));
                end

                this.onDirtyStateChange(args.clientID);
            else

            end
        end

        function updateAttributeLabel(this,args)


            data=args.data;
            signalIDs=data.signalIDs;

            if isempty(signalIDs)

                signalIDs=this.Model.getMemberIDs();
            end


            info=this.Model.updateAttributeLabelInstances(data.labelData,signalIDs);
            labelData=info.labelData;
            if info.successFlag
                if isfield(data,'src')&&strcmp(data.src,'labelSignalsWidgetDialog')
                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','closeDialog',...
                    'data',data.src)));
                end


                this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','treeTableLabelData',...
                'data',info.successFlag)));


                outData=this.Model.getLabelDataForAxesOnAttributeUpdate(labelData,true);
                for idx=1:numel(outData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=outData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=outData(idx);
                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData',...
                    'data',dataPacket)));
                end

                this.onDirtyStateChange(args.clientID);
            else

            end
        end

        function cb_DeleteLabel(this,args)





            data=args.data;
            data.labelData.LabelInstanceID=string(data.labelData.LabelInstanceID);
            data.labelData.ParentLabelInstanceID=string(data.labelData.ParentLabelInstanceID);
            info=this.Model.deleteROIandPointLabelInstancesUnlabelAttributeInstances(data.labelData);
            if~isempty(info.editedLabelInstanceIDs)
                editedData=struct;
                editedData.data.labelData.LabelInstanceID=info.editedLabelInstanceIDs;
                editedData.data.labelData.ParentLabelInstanceID=info.parentLabelInstanceIDsForEditedLabelInstanceIDs;
                editedData.data.labelData.LabelType='attribute';
                editedData.clientID=args.clientID;
                updateModelFlag=false;
                this.cb_UpdateLabel(editedData,updateModelFlag);
            end
            if~isempty(info.removedLabelInstanceIDs)

                treeTableData=struct('rowIDs',info.removedLabelInstanceIDs,...
                'parentRowIDs',info.removedLabelInstanceParentRowIDs);

                axesLabelData=this.Model.getLabelDataForAxesOnDelete(info);
                for idx=1:numel(axesLabelData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=axesLabelData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesLabelData(idx);
                    this.notify('DeleteLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData','data',dataPacket)));
                end

                this.onDirtyStateChange(args.clientID);


                this.notify('DeleteLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','treeTableLabelData','data',treeTableData)));
            end
        end

        function cb_CancelUpdateLabel(this,args)

            data=args.data;
            instanceID=string(data.labelData.LabelInstanceID);
            if~isempty(instanceID)


                isVisibleFlag=true;
                if isfield(data.labelData,'isVisible')
                    isVisibleFlag=data.labelData.isVisible;
                end
                if isfield(data.labelData,'isChecked')
                    isVisibleFlag=data.labelData.isChecked;
                end
                isHighlighted=true;
                outData=this.Model.getLabelDataForAxes(data.labelData,isVisibleFlag,isHighlighted);

                for idx=1:numel(outData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=outData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=outData(idx);
                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData',...
                    'data',dataPacket)));
                end
            end
        end

        function cb_AnimateLabel(this,args)

            data=args.data;
            instanceID=string(data.labelData.LabelInstanceID);

            if~isempty(instanceID)

                isVisibleFlag=false;
                outData=this.Model.getLabelDataForAxes(data.labelData,isVisibleFlag);
                outData(:).isChecked=data.labelData.isChecked;
                for idx=1:numel(outData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=outData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=outData(idx);
                    this.notify('AnimateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData',...
                    'data',dataPacket)));
                end
            end
        end

        function cb_SelectLabel(this,args)

            data=args.data;
            instanceID=string(data.labelData.LabelInstanceID);
            if~isempty(instanceID)&&~strcmp(instanceID,"")


                isVisible=true;
                if~data.labelData.isChecked
                    isVisible=data.labelData.isChecked;
                end
                outData=this.Model.getLabelDataForAxes(data.labelData,isVisible,true);

                for idx=1:numel(outData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=outData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=outData(idx);
                    this.notify('SelectLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelDataOnSelect',...
                    'data',dataPacket)));
                end
            else
                dataPacket.clientID=args.clientID;
                dataPacket.totalChuncks=1;
                this.notify('SelectLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','axesLabelDataOnDeSelect',...
                'data',dataPacket)));
            end
        end

        function cb_EditLabelWidgetPreshow(this,args)
            data=args.data.labelData;
            memberID=args.data.MemberID;

            labelInstanceOutData=this.Model.getLabelDataForLabelSignalWidget(data,memberID,data.isChecked);
            dataPacket.clientID=args.clientID;
            dataPacket.messageID='updateLabelInstance';
            dataPacket.labelData=labelInstanceOutData;
            dataPacket.MemberID=memberID;
            dataPacket.isTimeSpecified=this.Model.getIsTimeSpecified();
            this.notify('WidgetPreshowComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',dataPacket)));
        end

        function cb_LabelSignalsWidgetPreshow(this,args)
            args.data.isTimeSpecified=this.Model.getIsTimeSpecified();
            this.notify('WidgetPreshowComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',args.data)));
        end

        function cb_LabelSignalsWidgetGetTableData(this,args)
            memberIDs=this.Model.getMemberIDs();
            tableData=[];
            if~isempty(memberIDs)
                tableData=this.Model.getImportedSignalsDataForTreeTable(memberIDs);
            end
            this.notify('WidgetGetTableDataComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',tableData)));
        end

        function cb_DeleteAllInLabelHeader(this,args)



            [memberID,labelDefID]=this.Model.parseTreeTableRowID(args.data.rowID);
            labelData.LabelInstanceID=this.Model.getLabelInstanceIDsForLabelDefIDAndParentInstanceID(labelDefID,string(memberID),args.data.parentLabelInstanceID);
            info=this.Model.deleteROIandPointLabelInstancesUnlabelAttributeInstances(labelData);
            treeTableData=[];
            if~isempty(info.removedLabelInstanceIDs)

                treeTableData=struct('rowIDs',info.removedLabelInstanceIDs,...
                'parentRowIDs',info.removedLabelInstanceParentRowIDs);

                axesLabelData=this.Model.getLabelDataForAxesOnDelete(info);
                for idx=1:numel(axesLabelData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=axesLabelData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesLabelData(idx);
                    this.notify('DeleteLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData','data',dataPacket)));
                end

                this.onDirtyStateChange(args.clientID);
            end

            this.notify('DeleteLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','treeTableLabelData','data',treeTableData)));
        end
    end


    methods
        function onDirtyStateChange(this,clientID)
            dirtyStateChanged=this.Model.setDirty(true);
            if dirtyStateChanged
                this.changeAppTitle(this.Model.isDirty());
                this.notify('DirtyStateChanged',...
                signal.internal.SAEventData(struct('clientID',str2double(clientID))));
            end
        end

        function changeAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end
    end
end
