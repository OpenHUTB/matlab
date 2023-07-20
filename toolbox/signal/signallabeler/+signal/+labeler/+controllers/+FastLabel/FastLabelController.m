

classdef FastLabelController<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='FastLabelController';
    end

    events
CreateLabelComplete
UpdateLabelComplete
DeleteLabelComplete
DirtyStateChanged
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FastLabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.FastLabel.FastLabelController(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=FastLabelController(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.FastLabel.FastLabelController;

            this.Dispatcher.subscribe(...
            [FastLabelController.ControllerID,'/','createlabel'],...
            @(arg)cb_CreateLabel(this,arg));

            this.Dispatcher.subscribe(...
            [FastLabelController.ControllerID,'/','updatelabel'],...
            @(arg)cb_UpdateLabel(this,arg));

            this.Dispatcher.subscribe(...
            [FastLabelController.ControllerID,'/','deletelabel'],...
            @(arg)cb_DeleteLabel(this,arg));
        end
    end

    methods(Hidden)




        function cb_CreateLabel(this,args)

            data=args.data;
            signalIDs=data.signalIDs;



            [successFlag,exceptionKeyword,info]=this.Model.addLabelInstance(signalIDs,data.labelData);%#ok<ASGLU>
            if successFlag&&info.NumInstances>0

                axesOutData=this.Model.getLabelDataForAxesOnCreate(data.labelData,info);
                for idx=1:numel(axesOutData)

                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=axesOutData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesOutData(idx);
                    this.notify('CreateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData','data',dataPacket)));
                end



                labelData=this.getLabelDataFromAxesData(axesOutData);
                this.Model.addFastLabelCreatedLabelData(labelData,data.labelData,info);


                this.onDirtyStateChange(args.clientID);
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
                isChecked=true;
                if string(data.labelData.LabelType)~="attribute"
                    isChecked=data.labelData.isChecked;
                end




                outData=this.Model.getLabelDataForAxes(data.labelData,isChecked,true);
                for idx=1:numel(outData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=outData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=outData(idx);
                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData','data',dataPacket)));
                end



                labelData=this.getLabelDataFromAxesData(outData);
                this.Model.addLabelerUpdatedLabelData(labelData);


                this.onDirtyStateChange(args.clientID);
            end
        end

        function updateAttributeLabel(this,args)


            data=args.data;
            signalIDs=data.signalIDs;


            info=this.Model.updateAttributeLabelInstances(data.labelData,signalIDs);
            labelData=info.labelData;
            if info.successFlag

                outData=this.Model.getLabelDataForAxesOnAttributeUpdate(labelData,true);
                for idx=1:numel(outData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=outData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=outData(idx);
                    this.notify('UpdateLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData','data',dataPacket)));
                end



                labelData=this.getLabelDataFromAxesData(outData);
                this.Model.addLabelerUpdatedLabelData(labelData);


                this.onDirtyStateChange(args.clientID);
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

                axesLabelData=this.Model.getLabelDataForAxesOnDelete(info);
                for idx=1:numel(axesLabelData)
                    dataPacket.clientID=args.clientID;
                    dataPacket.signalID=axesLabelData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesLabelData(idx);
                    this.notify('DeleteLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','axesLabelData','data',dataPacket)));
                end






                labelData=this.getLabelDataFromAxesData(axesLabelData);
                this.Model.updateDeletedLabelData(labelData);


                this.onDirtyStateChange(args.clientID);
            end
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

        function labelData=getLabelDataFromAxesData(~,axesData)
            for idx=1:numel(axesData)
                labelData(idx).LabelInstanceID=axesData(idx).LabelInstanceIDs;%#ok<*AGROW>
                labelData(idx).ParentLabelInstanceID=axesData(idx).ParentLabelInstanceIDs;
                if isfield(axesData(idx),"LabelInstanceParentRowIDs")

                    labelData(idx).LabelInstanceParentRowID=axesData(idx).LabelInstanceParentRowIDs;
                end
                if isempty(labelData(idx).ParentLabelInstanceID)
                    labelData(idx).ParentLabelInstanceID="";
                end
                labelData(idx).LabelType=axesData(idx).LabelType;
                labelData(idx).isSublabel=axesData(idx).isSublabel;
                labelData(idx).LabelDefinitionID=axesData(idx).LabelDefinitionID;
                labelData(idx).MemberID=axesData(idx).MemberID;
            end
        end
    end
end
