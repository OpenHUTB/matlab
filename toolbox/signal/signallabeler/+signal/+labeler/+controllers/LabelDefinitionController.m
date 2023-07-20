

classdef LabelDefinitionController<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='LabelDefinitionCtrl';
    end

    events
CreateLabelDefsComplete
UpdateLabelDefsComplete
DeleteLabelDefsComplete
GetlabelDataForToolstripComplete
ClearAllLabelDefsComplete
DirtyStateChanged
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.LabelDefinitionController(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=LabelDefinitionController(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.LabelDefinitionController;

            this.Dispatcher.subscribe(...
            [LabelDefinitionController.ControllerID,'/','createlabeldef'],...
            @(arg)cb_CreateLabelDef(this,arg));

            this.Dispatcher.subscribe(...
            [LabelDefinitionController.ControllerID,'/','updatelabeldef'],...
            @(arg)cb_UpdateLabelDef(this,arg));

            this.Dispatcher.subscribe(...
            [LabelDefinitionController.ControllerID,'/','deletelabeldef'],...
            @(arg)cb_DeleteLabeldef(this,arg));

            this.Dispatcher.subscribe(...
            [LabelDefinitionController.ControllerID,'/','getlabeldatafortoolstrip'],...
            @(arg)cb_GetlabelDataForToolstrip(this,arg));

            this.Dispatcher.subscribe(...
            [LabelDefinitionController.ControllerID,'/','clearalllabeldefs'],...
            @(arg)cb_ClearAllLabelDefs(this,arg));


            this.Dispatcher.subscribe(...
            [LabelDefinitionController.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end
    end

    methods(Hidden)



        function addLabelDefinitions(this,clientID,lblDefs)



            for idx=1:numel(lblDefs)
                lblDef=lblDefs(idx);

                lblDefArgs.clientID=clientID;
                lblDefArgs.data.src='addLabelDialog';
                lblDefArgs.data.clientID=str2double(clientID);

                lblDefArgs.data.labelData.ParentLabelDefinitionID='';
                lblDefArgs.data.labelData.LabelName=lblDef.Name;
                labelType=lblDef.LabelType;
                lblDefArgs.data.labelData.featureExtractorType='';
                framePolicy=lblDef.getFramePolicy();
                if labelType=="attributeFeature"
                    lblDefArgs.data.labelData.isFeature=true;
                elseif labelType=="roiFeature"
                    lblDefArgs.data.labelData.isFeature=true;
                    if isfield(framePolicy,'FrameOverlapLength')
                        lblDefArgs.data.labelData.framePolicyType='frameOverlapLength';
                        lblDefArgs.data.labelData.frameRateOrOverlapLength=framePolicy.FrameOverlapLength;
                    else
                        lblDefArgs.data.labelData.framePolicyType='framerate';
                        lblDefArgs.data.labelData.frameRateOrOverlapLength=framePolicy.FrameRate;
                    end
                    lblDefArgs.data.labelData.frameSize=framePolicy.FrameSize;
                end

                lblDefArgs.data.labelData.LabelType=lblDef.getSimpleLabelType();
                lblDefArgs.data.labelData.LabelDescription=lblDef.Description;
                lblDefArgs.data.labelData.LabelDataType=lblDef.LabelDataType;
                lblDefArgs.data.labelData.LabelDataCategories='';
                if lblDef.LabelDataType=="categorical"
                    lblDefArgs.data.labelData.LabelDataCategories=lblDef.Categories;
                end
                if lblDef.LabelDataType=="numeric"||isempty(lblDef.DefaultValue)

                    lblDefArgs.data.labelData.LabelDataDefaultValue=sprintf("%.20g",lblDef.DefaultValue);
                else
                    lblDefArgs.data.labelData.LabelDataDefaultValue=string(lblDef.DefaultValue);
                end
                info=this.cb_CreateLabelDef(lblDefArgs);

                newLblDefID=info.newLabelDefIDs;
                for kk=1:numel(lblDef.Sublabels)
                    subLblDef=lblDef.Sublabels(kk);

                    lblDefArgs.data.labelData.ParentLabelDefinitionID=newLblDefID;
                    lblDefArgs.data.labelData.LabelName=subLblDef.Name;
                    lblDefArgs.data.labelData.LabelType=subLblDef.LabelType;
                    lblDefArgs.data.labelData.LabelDescription=subLblDef.Description;
                    lblDefArgs.data.labelData.LabelDataType=subLblDef.LabelDataType;
                    lblDefArgs.data.labelData.LabelDataCategories='';
                    if subLblDef.LabelDataType=="categorical"
                        lblDefArgs.data.labelData.LabelDataCategories=subLblDef.Categories;
                    end
                    if subLblDef.LabelDataType=="numeric"||isempty(subLblDef.DefaultValue)

                        lblDefArgs.data.labelData.LabelDataDefaultValue=sprintf("%.20g",subLblDef.DefaultValue);
                    else
                        lblDefArgs.data.labelData.LabelDataDefaultValue=string(subLblDef.DefaultValue);
                    end
                    this.cb_CreateLabelDef(lblDefArgs);
                end
            end
        end




        function cb_HelpButton(~,args)
            data=args.data;

            if strcmp(data.src,'addLabelDialog')
                if strcmp(data.messageID,'add')
                    signal.labeler.controllers.SignalLabelerHelp('addLabelDefinitionHelp');
                elseif strcmp(data.messageID,'edit')
                    signal.labeler.controllers.SignalLabelerHelp('editLabelDefinitionHelp');
                end
            elseif strcmp(data.src,'addSubLabelDialog')
                if strcmp(data.messageID,'add')
                    signal.labeler.controllers.SignalLabelerHelp('addSublabelDefinitionHelp');
                elseif strcmp(data.messageID,'edit')
                    signal.labeler.controllers.SignalLabelerHelp('editSublabelDefinitionHelp');
                end
            end
        end

        function info=cb_CreateLabelDef(this,args)




            data=args.data.labelData;
            [successFlag,exceptionKeyword,info]=this.Model.addLabelDefinitions(data);

            if successFlag
                labelDefId=info.newLabelDefIDs;


                treeOutData=this.Model.getLabelDefinitionsDataForTree(labelDefId);
                if~isempty(treeOutData)

                    this.notify('CreateLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','treeLabelDefData',...
                    'data',treeOutData)));
                end


                if~isempty(labelDefId)

                    this.notify('CreateLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','treeTableLabelDefData',...
                    'data',struct)));
                end


                axesOutData=this.Model.getLabelDefinitionsDataForAxes(labelDefId,info);

                for idx=1:length(axesOutData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=axesOutData(idx).SignalID;
                    dataPacket.memberID=axesOutData(idx).MemberID;
                    dataPacket.labelData=axesOutData(idx);
                    dataPacket.totalChunks=1;

                    this.notify('CreateLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelDefData',...
                    'data',dataPacket)));
                end


                this.onDirtyStateChange(args.clientID,true);
            else

                if strcmp(args.data.src,'addSubLabelDialog')
                    this.Dispatcher.publishToClient(args.clientID,...
                    'addSubLabelDialog','showInvalidLabelWarning',...
                    struct('errorID',exceptionKeyword));
                else
                    this.Dispatcher.publishToClient(args.clientID,...
                    'addLabelDialog','showInvalidLabelWarning',...
                    struct('errorID',exceptionKeyword));
                end

            end
        end

        function cb_UpdateLabelDef(this,args)




            data=args.data.labelData;
            [successFlag,exceptionKeyword,labelDefId,islabelNameChanged]=this.Model.updateLabelDefinitions(data);

            if successFlag

                this.notify('UpdateLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','closeDialog',...
                'data',struct('parent',data.ParentLabelDefinitionID))));
            end

            if successFlag
                if~islabelNameChanged


                    evtData.clientID=args.clientID;
                    evtData.data.id=data.LabelDefinitionID;
                    cb_GetlabelDataForToolstrip(this,evtData);
                else

                    treeOutData=this.Model.getLabelDefinitionsDataForTree(labelDefId);
                    if~isempty(treeOutData)

                        this.notify('UpdateLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                        'messageID','treeLabelDefData',...
                        'data',treeOutData)));
                    end


                    this.notify('UpdateLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','treeTableLabelDefData',...
                    'data',struct)));


                    axesOutData=this.Model.getLabelDefinitionsDataForAxes(labelDefId);
                    for idx=1:length(axesOutData)
                        dataPacket.clientID=args.clientID;
                        dataPacket.signalID=axesOutData(idx).SignalID;
                        dataPacket.memberID=axesOutData(idx).MemberID;
                        dataPacket.labelData=axesOutData(idx);
                        dataPacket.totalChunks=1;

                        this.notify('UpdateLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                        'messageID','axesLabelDefData',...
                        'data',dataPacket)));
                    end
                end

                this.onDirtyStateChange(args.clientID,true);
            else

                if strcmp(args.data.src,'addSubLabelDialog')
                    this.Dispatcher.publishToClient(args.clientID,...
                    'addSubLabelDialog','showInvalidLabelWarning',...
                    struct('errorID',exceptionKeyword));
                else
                    this.Dispatcher.publishToClient(args.clientID,...
                    'addLabelDialog','showInvalidLabelWarning',...
                    struct('errorID',exceptionKeyword));
                end
            end
        end

        function cb_DeleteLabeldef(this,args)




            data=args.data.labelData;
            [labelDefId,info]=this.Model.deleteLabelDefinitions(data);


            treeOutData=this.Model.getLabelDefinitionsDataForTreeOnDelete(info);
            if~isempty(treeOutData)

                this.notify('DeleteLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','treeLabelDefData',...
                'data',treeOutData)));
            end


            if~isempty(info.removedTreeTableRowIDs)

                this.notify('DeleteLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','treeTableLabelDefData',...
                'data',struct('rowIDs',info.removedTreeTableRowIDs,...
                'parentRowIDs',info.removedTreeTableRowParentIDs))));
            end


            axesOutData=this.Model.getLabelDefinitionsDataForAxesOnDelete(labelDefId,info);
            for idx=1:length(axesOutData)
                dataPacket.clientID=args.clientID;
                dataPacket.signalID=axesOutData(idx).SignalID;
                dataPacket.memberID=axesOutData(idx).MemberID;
                dataPacket.labelData=axesOutData(idx);

                this.notify('DeleteLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','axesLabelDefData',...
                'data',dataPacket)));
            end




            if this.Model.isAppHasMemberOrLabelsDef()
                this.onDirtyStateChange(args.clientID,true);
            else
                this.onDirtyStateChange(args.clientID,false);
            end
        end

        function cb_ClearAllLabelDefs(this,args)




            info=this.Model.deleteAllLabelDefinitions();


            this.notify('ClearAllLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','treeLabelDefData')));



            this.notify('ClearAllLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','treeTableLabelDefData','data',struct('rowIDs',info.removedTreeTableRowIDs,'parentRowIDs',info.removedTreeTableRowParentIDs))));


            this.notify('ClearAllLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','axesLabelDefData')));




            if this.Model.isAppHasMembers()
                this.onDirtyStateChange(args.clientID,true);
            else
                this.onDirtyStateChange(args.clientID,false);
            end
        end

        function cb_GetlabelDataForToolstrip(this,args)
            data=args.data;
            outData=this.Model.getLabelDefinitionsData(data);


            this.notify('GetlabelDataForToolstripComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',outData)));
        end
    end


    methods
        function onDirtyStateChange(this,clientID,dirtyState)
            dirtyStateChanged=this.Model.setDirty(dirtyState);
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
