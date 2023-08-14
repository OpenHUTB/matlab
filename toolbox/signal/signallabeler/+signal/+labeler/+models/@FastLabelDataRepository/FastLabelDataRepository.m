classdef FastLabelDataRepository<handle




    properties(GetAccess='public',SetAccess='private')
LabelerModel
FastLabelCreatedLabelData
LabelerUpdatedLabelData
LabelerDeletedLabelData
SelectedSignalIndices
        CheckedSignalIDsCallback;
    end

    methods(Static)
        function ret=getModel()

            persistent modelObj;
            mlock;
            if isempty(modelObj)||~isvalid(modelObj)
                labelerModelObj=signal.labeler.models.LabelDataRepository.getModel();
                modelObj=signal.labeler.models.FastLabelDataRepository(labelerModelObj);
            end


            ret=modelObj;
        end
    end



    methods(Access=protected)
        function this=FastLabelDataRepository(labelerModelObj)

            this.LabelerModel=labelerModelObj;
            this.resetModel();
            import signal.labeler.models.FastLabelDataRepository;
        end
    end

    methods
        function resetModel(this)
            this.FastLabelCreatedLabelData=[];
            this.LabelerUpdatedLabelData=[];
            this.LabelerDeletedLabelData=[];
            this.SelectedSignalIndices=1;
            this.getLabelerModel().resetCheckedSignalIDsCallback();
        end



        function labelerModel=getLabelerModel(this)
            labelerModel=this.LabelerModel;
        end

        function setAppName(this,AppName)
            this.getLabelerModel.setAppName(AppName);
        end

        function outData=getAllLabelDefinitionsDataForTree(this,excludeLabelDefinitionIDs)
            outData=this.getLabelerModel().getAllLabelDefinitionsDataForTree(excludeLabelDefinitionIDs);
        end

        function y=getAllCheckableSignalIDs(this)
            y=this.getLabelerModel().getAllCheckableSignalIDs();
        end

        function outData=getLabelDataForAxesOnCreate(this,labelData,info)

            outData=this.getLabelerModel().getLabelDataForAxesOnCreate(labelData,info);
        end

        function[successFlag,exceptionKeyword,info]=addLabelInstance(this,signalIDs,labelData)

            [successFlag,exceptionKeyword,info]=this.getLabelerModel().addLabelInstance(signalIDs,labelData);
        end

        function labelOutData=getLabelDataForAxes(this,labelData,isVisibleFlag,isHighlighted,isCallBackNeeded)
            labelerModel=this.getLabelerModel();
            if nargin<5
                labelOutData=labelerModel.getLabelDataForAxes(labelData,isVisibleFlag,isHighlighted);
            elseif isCallBackNeeded
                callback=@labelerModel.getFirstCheckedSignalIDInMember;
                labelOutData=labelerModel.getLabelDataForAxes(labelData,isVisibleFlag,isHighlighted,callback);
            end
        end

        function info=updateLabelInstance(this,labelData)
            info=this.getLabelerModel().updateLabelInstance(labelData);
        end

        function info=updateAttributeLabelInstances(this,labelData,signalIDs)
            info=this.getLabelerModel().updateAttributeLabelInstances(labelData,signalIDs);
        end

        function outData=getLabelDataForAxesOnAttributeUpdate(this,labelData,isVisibleFlag)
            outData=this.getLabelerModel().getLabelDataForAxesOnAttributeUpdate(labelData,isVisibleFlag);
        end

        function info=deleteROIandPointLabelInstancesUnlabelAttributeInstances(this,labelData)
            info=this.getLabelerModel().deleteROIandPointLabelInstancesUnlabelAttributeInstances(labelData);
        end

        function outAxesData=getLabelDataForAxesOnDelete(this,info,isCallBackNeeded)
            labelerModel=this.getLabelerModel();
            if nargin<3
                outAxesData=this.getLabelerModel().getLabelDataForAxesOnDelete(info);
            elseif isCallBackNeeded
                callback=@labelerModel.getFirstCheckedSignalIDInMember;
                outAxesData=this.getLabelerModel().getLabelDataForAxesOnDelete(info,callback);
            end
        end

        function y=isDirty(this)
            y=this.getLabelerModel().Dirty;
        end

        function dirtyStateChanged=setDirty(this,dirtyStatus)
            dirtyStateChanged=this.getLabelerModel().setDirty(dirtyStatus);
        end

        function[memberName,sigName,lssName,fullMemberName]=convertToValidMemberName(this,name,tmMode)
            [memberName,sigName,lssName,fullMemberName]=this.getLabelerModel().convertToValidMemberName(name,tmMode);
        end

        function tmMode=getSignalTmMode(this,signalID)
            tmMode=this.getLabelerModel().getSignalTmMode(signalID);
        end

        function signalIDs=getLeafSignalIDsForMemberID(this,memberID)
            signalIDs=this.getLabelerModel().getLeafSignalIDsForMemberID(memberID);
            if isempty(signalIDs)
                signalIDs=double(memberID);
            end
        end

        function setCheckedSignalIDsCallback(this)
            callback=@this.getFirstSignalIDInMember;
            this.getLabelerModel().setCheckedSignalIDsCallback(callback);
        end





        function data=getFastLabelCreatedLabelData(this)
            data=this.FastLabelCreatedLabelData;
        end

        function data=getLabelerUpdatedLabelData(this)
            data=this.LabelerUpdatedLabelData;
        end

        function data=getLabelerDeletedLabelData(this)
            data=this.LabelerDeletedLabelData;
        end

        function addFastLabelCreatedLabelData(this,labelInstanceData,labelData,info)
            for idx=1:numel(labelInstanceData)
                data.LabelInstanceID=labelInstanceData(idx).LabelInstanceID;
                data.ParentLabelInstanceID=labelInstanceData(idx).ParentLabelInstanceID;
                data.LabelType=labelInstanceData(idx).LabelType;
                data.isSublabel=labelInstanceData(idx).isSublabel;
                data.labelData=labelData;
                data.info=info;
                this.FastLabelCreatedLabelData=[this.FastLabelCreatedLabelData;data];
            end
        end

        function removeFastLabelCreatedLabelData(this,labelInstanceIDs)


            for idx=1:numel(labelInstanceIDs)
                index=[this.FastLabelCreatedLabelData.LabelInstanceID]==labelInstanceIDs(idx);
                this.FastLabelCreatedLabelData(index)=[];
            end
        end

        function flag=isFastLabelCreatedLabelData(this,labelInstanceID)
            flag=false;
            if~isempty(this.FastLabelCreatedLabelData)
                flag=any(ismember([this.FastLabelCreatedLabelData.LabelInstanceID],labelInstanceID));
            end
        end

        function flag=isLabelerUpdatedLabelData(this,labelInstanceID)
            flag=false;
            if~isempty(this.LabelerUpdatedLabelData)
                flag=any(ismember([this.LabelerUpdatedLabelData.LabelInstanceID],labelInstanceID));
            end
        end

        function addLabelerUpdatedLabelData(this,labelData)
            for idx=1:numel(labelData)


                if~this.isLabelerUpdatedLabelData(labelData(idx).LabelInstanceID)&&...
                    (this.isAttributeSublabel(labelData)||...
                    ~(this.isFastLabelCreatedLabelData(labelData(idx).LabelInstanceID)))
                    this.LabelerUpdatedLabelData=[this.LabelerUpdatedLabelData;labelData(idx)];
                end
            end
        end

        function removeLabelerUpdatedLabelData(this,labelInstanceIDs)
            if~isempty(this.LabelerUpdatedLabelData)


                for idx=1:numel(labelInstanceIDs)
                    index=[this.LabelerUpdatedLabelData.LabelInstanceID]==labelInstanceIDs(idx);
                    this.LabelerUpdatedLabelData(index)=[];
                end
            end
        end

        function updateDeletedLabelData(this,labelData)
            for idx=1:numel(labelData)
                labelInstanceID=labelData(idx).LabelInstanceID;
                if~this.isFastLabelCreatedLabelData(labelInstanceID)
                    this.LabelerDeletedLabelData=[this.LabelerDeletedLabelData;labelData(idx)];
                    this.removeLabelerUpdatedLabelData(labelInstanceID);
                else
                    this.removeFastLabelCreatedLabelData(labelInstanceID);
                end
            end
        end

        function setSelectedSignalIndices(this,indices)
            this.SelectedSignalIndices=indices(:);
        end

        function indices=getSelectedSignalIndices(this)
            indices=this.SelectedSignalIndices;
        end

        function[minNumOfSignals,maxNumOfSignals]=getMinAndMaxNumberOfSignalsInMembers(this)
            memberIDToLeafSignalIDsMap=this.getLabelerModel().getMemberIDToLeafSignalIDsMap();
            numOfsignalIDs=structfun(@(x)numel(x(:)),memberIDToLeafSignalIDsMap);
            minNumOfSignals=min(numOfsignalIDs);
            if minNumOfSignals==0

                minNumOfSignals=1;
            end
            maxNumOfSignals=max(numOfsignalIDs);
            if maxNumOfSignals==0

                maxNumOfSignals=1;
            end
        end

        function signalID=getFirstSignalIDInMember(this,memberID)
            signalIDs=this.getLeafSignalIDsForMemberID(memberID);
            selectedSignalIndices=this.getSelectedSignalIndices();
            if isempty(selectedSignalIndices)
                signalID=signalIDs(1);
            else
                signalID=signalIDs(selectedSignalIndices(1));
            end
        end

        function flag=isAttributeSublabel(~,labelData)
            flag=labelData.LabelType=="attribute"&&labelData.isSublabel;
        end





        function outData=getImportedSignalsDataForTreeTable(this)

            memberIDs=this.getLabelerModel().getMemberIDs();
            sigData=this.getTreeTableDataStruct();

            outData=repmat(sigData,length(memberIDs),1);
            for idx=1:numel(memberIDs)

                signalObj=Simulink.sdi.getSignal(memberIDs(idx));
                outData(idx).id=num2str(signalObj.ID);
                tmMode=getSignalTmMode(this,signalObj.ID);
                [~,~,~,outData(idx).name]=this.convertToValidMemberName(signalObj.Name,tmMode);
                temp=this.getLabelerModel().getColorInHex(memberIDs(idx));
                outData(idx).color=['#',temp(1,:),temp(2,:),temp(3,:)];
            end
        end

        function treeTableDataStruct=getTreeTableDataStruct(~)






            treeTableDataStruct=struct(...
            'id','',...
            'name','',...
            'color','');
        end

        function tableData=getTableDataForSignalSelectionWidget(this)


            minNumOfSignalsInMembers=this.getMinAndMaxNumberOfSignalsInMembers();

            for idx=1:minNumOfSignalsInMembers
                id=string(idx);
                tableData(idx).id=id;%#ok<AGROW>
                tableData(idx).isChecked=idx==1;%#ok<AGROW>
                tableData(idx).name=id;%#ok<AGROW>
            end
        end





        function outData=getSignalsDataForSignals(this,signalIDs,operation)
            outData=this.getLabelerModel().getSignalsData(signalIDs,operation);
        end





        function outAxesData=getLabelDataForAxesForPlot(this,memberID)
            signalIDs=this.getLeafSignalIDsForMemberID(memberID);
            outAxesData=this.getLabelerModel().getLabelDataForAxesBySignalIDOnSignalCheck(signalIDs);
        end

        function axesOutData=getFastLabelCreatedLabelDataForAxes(this,memberID,isVisibleFlag,isHighlightedFlag)
            labelInstanceIDs=[];
            parentLabelInstanceIDs=[];
            fastLabelCreatedLabelData=this.getFastLabelCreatedLabelData();
            for idx=1:numel(fastLabelCreatedLabelData)
                instanceID=fastLabelCreatedLabelData(idx).LabelInstanceID;
                instance=this.getLabelerModel().getLabelInstanceFromLabelInstanceID(instanceID);
                instanceMemberID=instance.memberID;
                if instanceMemberID==string(memberID)
                    labelInstanceIDs=[labelInstanceIDs;instanceID];%#ok<AGROW>
                    parentLabelInstanceIDs=[parentLabelInstanceIDs;fastLabelCreatedLabelData(idx).ParentLabelInstanceID];%#ok<AGROW>
                end
            end
            labelData.LabelInstanceID=labelInstanceIDs;
            labelData.ParentLabelInstanceID=parentLabelInstanceIDs;
            axesOutData=this.getLabelDataForAxes(labelData,isVisibleFlag,isHighlightedFlag);
        end
    end
end