classdef FeatureExtractionDataRepository<handle




    properties(GetAccess='public',SetAccess='private')
LabelerModel
checkedMemberIDs
SelectedSignalIndices
        CheckedSignalIDsCallback;
        ModeCreatedFeatureDefinitionIDs;
        IsFullSignalMode;
        ModeSampleRate;
    end

    methods(Static)
        function ret=getModel()

            persistent modelObj;
            mlock;
            if isempty(modelObj)||~isvalid(modelObj)
                labelerModelObj=signal.labeler.models.LabelDataRepository.getModel();
                modelObj=signal.labeler.models.FeatureExtractionDataRepository(labelerModelObj);
            end

            ret=modelObj;
        end
    end



    methods(Access=protected)
        function this=FeatureExtractionDataRepository(labelerModelObj)

            this.LabelerModel=labelerModelObj;
            this.resetModel();
            import signal.labeler.models.FastLabelDataRepository;
        end
    end

    methods





        function resetModel(this)
            this.checkedMemberIDs=[];
            this.ModeCreatedFeatureDefinitionIDs=[];
            this.SelectedSignalIndices=1;
            this.resetCheckedSignalIDsCallback();
            this.IsFullSignalMode=true;
            this.ModeSampleRate=[];
        end

        function setModeSampleRate(this,value)
            this.ModeSampleRate=value;
        end

        function sampleRate=getModeSampleRate(this)
            sampleRate=this.ModeSampleRate;
        end

        function setSelectedSignalIndices(this,indices)
            this.SelectedSignalIndices=indices(:);
        end

        function indices=getSelectedSignalIndices(this)
            indices=this.SelectedSignalIndices;
        end

        function setIsFullSignalMode(this,flag)
            this.IsFullSignalMode=flag;
        end

        function flag=isFullSignalMode(this)
            flag=this.IsFullSignalMode;
        end

        function signalIDs=getSelectedSignalIDs(this,memberID)
            leafSignalIDs=this.getLeafSignalIDsForMemberID(memberID);
            selectedSignalIndices=this.getSelectedSignalIndices();
            if isempty(selectedSignalIndices)
                signalIDs=leafSignalIDs;
            else
                signalIDs=leafSignalIDs(selectedSignalIndices);
            end
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

        function[flag,type,sampleRate]=verifySignalsSampleRateAndComplexity(this)
            signalIDs=this.getLabelerModel().getAllCheckableSignalIDs();
            [flag,type,sampleRate]=signal.sigappsshared.SignalUtilities.verifySignalsSampleRateAndComplexity(this.getLabelerModel().Engine,int32(signalIDs));
        end


        function updatedCheckedMemberIDs(this,memberID,checkFlag)
            if strcmp(checkFlag,'check')
                this.checkedMemberIDs=unique([this.checkedMemberIDs;memberID],'stable');

            elseif strcmp(checkFlag,'uncheck')

                this.checkedMemberIDs=setdiff(this.checkedMemberIDs,memberID);
            end

            allMemberIDs=this.getLabelerModel().getMemberIDs();
            this.checkedMemberIDs=allMemberIDs(ismember(allMemberIDs,this.checkedMemberIDs));
        end

        function flag=isMemberPlotted(this,memberID)
            flag=any(this.checkedMemberIDs==double(memberID));
        end

        function supportedLblDefIDs=getSupportedLabelDefinitionIDs(this,isIncludeFeatureDefs)
            supportedLblDefIDs=[];
            lblDefIDs=this.getLabelerModel().getAllLabelDefinitionIDs();
            for idx=1:numel(lblDefIDs)
                lblDef=this.getLabelerModel().getLabelDefFromLabelDefID(lblDefIDs(idx));
                if lblDef.labelType=="attribute"&&...
                    lblDef.labelDataType=="categorical"
                    supportedLblDefIDs=[supportedLblDefIDs;lblDefIDs(idx)];
                end
                if isIncludeFeatureDefs...
                    &&~isempty(this.ModeCreatedFeatureDefinitionIDs)...
                    &&any(this.ModeCreatedFeatureDefinitionIDs.contains(lblDefIDs(idx)))
                    supportedLblDefIDs=[supportedLblDefIDs;lblDefIDs(idx)];
                end
            end
        end

        function signalData=getSelectedSignalData(this,memberID)
            signalIDs=this.getSelectedSignalIDs(memberID);
            numOfSignalIDs=numel(signalIDs);
            signalData=[];
            for idx=1:numOfSignalIDs
                data=this.getLabelerModel().getSignalValue(signalIDs(idx));
                sigData=data.Data;
                signalData=[signalData,sigData(:)];
            end
        end

        function labelDefIDs=getModeCreatedFeatureDefinitionIDs(this,type)
            labelDefIDs=[];
            if nargin==1
                labelDefIDs=this.ModeCreatedFeatureDefinitionIDs;
            else
                for idx=1:numel(this.ModeCreatedFeatureDefinitionIDs)
                    labelDef=this.getLabelerModel().getLabelDefFromLabelDefID(this.ModeCreatedFeatureDefinitionIDs(idx));
                    if string(labelDef.labelType)==type
                        labelDefIDs=[labelDefIDs;this.ModeCreatedFeatureDefinitionIDs(idx)];
                    end
                end
            end
        end





        function flag=isHaveFeaturesForFeatureExtractor(this,featureExtractorType)
            flag=false;
            if isempty(this.ModeCreatedFeatureDefinitionIDs)


                return;
            end
            labelDefIDs=string(signallabelereng.datamodel.getLabelDefIDsForFeatureExtractorType(this.getLabelerModel().Mf0DataModel,featureExtractorType));
            if numel(labelDefIDs)==1&&labelDefIDs==""


                return;
            end
            flag=any(this.ModeCreatedFeatureDefinitionIDs.contains(labelDefIDs));
        end

        function[featDefID,treeFeatureDefData,axesFeatureDefData,frameIdx]=createFeatureDefinition(this,featureName,featuresClientData,selectedSignalIdx,currentExtractorObj,frameIdx)
            if frameIdx==-1&&~this.isFullSignalMode()
                frameIdx=this.computeFrameIndex();
            end
            featureDefinitionName=this.getFeatureDefinitionName(featureName,selectedSignalIdx,frameIdx);
            featureDescription=this.getFeatureDescription(featureName,currentExtractorObj);
            labelType="roi";
            if this.isFullSignalMode()
                labelType="attribute";
            end
            data=struct("ParentLabelDefinitionID","",...
            "isFeature",true,...
            "featureExtractorType",featuresClientData.featureExtractorType,...
            "LabelName",featureDefinitionName,...
            "LabelType",labelType,...
            "LabelDataType","numeric",...
            "LabelDataCategories","",...
            "LabelDataDefaultValue","",...
            "LabelDescription",featureDescription,...
            "tag","");
            if labelType=="roi"


                sampleRate=abs(this.getModeSampleRate());


                data.frameSize=floor(featuresClientData.framePolicyData.frameSize*sampleRate);
                if isfield(featuresClientData.framePolicyData,'frameRate')
                    data.framePolicyType="framerate";
                    data.frameRateOrOverlapLength=floor(featuresClientData.framePolicyData.frameRate*sampleRate);
                else
                    data.framePolicyType="frameOverlapLength";
                    data.frameRateOrOverlapLength=floor(featuresClientData.framePolicyData.frameOverlapLength*sampleRate);
                end
            end
            [~,~,info]=this.getLabelerModel().addLabelDefinitions(data);
            featDefID=info.newLabelDefIDs;
            this.ModeCreatedFeatureDefinitionIDs=[this.ModeCreatedFeatureDefinitionIDs;featDefID];
            treeFeatureDefData=this.getLabelDefinitionsDataForTree(featDefID);
            axesFeatureDefData=this.getLabelDefinitionsDataForAxes(featDefID,info);
        end

        function frameIdx=computeFrameIndex(this)
            frameIdx=1;
            frameRegExp="FP"+frameIdx+"_.*";
            featDefIDs=string(signallabelereng.datamodel.getLabelDefIDsWithNameMatchingRegExpText(this.getLabelerModel().Mf0DataModel,frameRegExp));
            while~(numel(featDefIDs)==1&&featDefIDs=="")
                frameIdx=frameIdx+1;
                frameRegExp="FP"+frameIdx+"_.*";
                featDefIDs=string(signallabelereng.datamodel.getLabelDefIDsWithNameMatchingRegExpText(this.getLabelerModel().Mf0DataModel,frameRegExp));
            end
        end

        function featureDefinitionName=getFeatureDefinitionName(this,featureName,selectedSignalIdx,frameIdx)
            sharedName="channel"+selectedSignalIdx+featureName;
            featureDefinitionName=sharedName;
            if~this.isFullSignalMode()
                featureDefinitionName="FP"+frameIdx+"_"+sharedName;
            end

            featDefID=signallabelereng.datamodel.getLabelDefIDForLabelDefNameAndParentLabelDefID(this.getLabelerModel().Mf0DataModel,featureDefinitionName,"");
            idx=0;
            while~isemptyString(this.getLabelerModel(),featDefID)
                idx=idx+1;
                featureDefinitionName=sharedName+idx;
                featDefID=signallabelereng.datamodel.getLabelDefIDForLabelDefNameAndParentLabelDefID(this.getLabelerModel().Mf0DataModel,featureDefinitionName,"");
            end
        end

        function featureDescription=getFeatureDescription(this,featureName,currentExtractorObj)
            if this.isFullSignalMode()
                featureDescription=getString(message('SDI:dialogsLabeler:FullSignalFeatueDefinitionDescription',"'"+featureName+"' ",currentExtractorObj.getFeatureExtractorNameForDefinitionDescription()));
            else
                featureDescription=getString(message('SDI:dialogsLabeler:FrameBasedSignalFeatueDefinitionDescription',"'"+featureName+"' ",currentExtractorObj.getFeatureExtractorNameForDefinitionDescription()));
            end
        end

        function labelData=getLabelDataStruct(this)
            if this.isFullSignalMode()
                labelData=struct(...
                "LabelInstanceID","",...
                "LabelInstanceValue","");
            else
                labelData=struct(...
                "ParentLabelInstanceID","",...
                "LabelDefinitionID","",...
                "LabelValue","",...
                "tMin","",...
                "tMax","");
            end
        end

        function addFeatureLabelInstance(this,memberID,featureDefinitionIDs,features,featureMatrix,featureInfo,timeLimits,labelDataStruct)


            numLblInstance=size(timeLimits,1);
            mf0LabelDataStruct=getMf0LabelDataStruct(this.getLabelerModel());
            numFeatureDefs=numel(featureDefinitionIDs);
            for idx=1:numFeatureDefs
                labelDefinitionID=featureDefinitionIDs(idx);


                lblDef=this.getLabelerModel().getLabelDefFromLabelDefID(labelDefinitionID);
                feature=features(idx);
                for ldx=1:numLblInstance


                    featureValue=featureMatrix(ldx,featureInfo.(feature));
                    if isnan(featureValue)
                        featureValue="NaN";
                    end
                    if this.isFullSignalMode()
                        labelDataStruct.LabelInstanceID=this.getLabelerModel().getLabelInstaceIDsForLabelDefIDAndMemberID(labelDefinitionID,memberID);
                        labelDataStruct.LabelInstanceValue=this.getLabelerModel().formatValueForClient(featureValue,"numeric");
                        this.getLabelerModel().updateLabelInstance(labelDataStruct,false,false);
                    else
                        labelDataStruct.LabelValue=featureValue;
                        labelDataStruct.LabelDefinitionID=labelDefinitionID;
                        labelDataStruct.tMin=timeLimits(ldx,1);
                        labelDataStruct.tMax=timeLimits(ldx,2);
                        this.getLabelerModel().addLabelInstance(memberID,labelDataStruct,true,false,lblDef,mf0LabelDataStruct);
                    end
                end
            end
        end




        function labelerModel=getLabelerModel(this)
            labelerModel=this.LabelerModel;
        end

        function setAppName(this,AppName)
            this.getLabelerModel.setAppName(AppName);
        end

        function outData=getLabelDataForAxesOnCreate(this,labelData,info)

            outData=this.getLabelerModel().getLabelDataForAxesOnCreate(labelData,info);
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

        function info=updateAttributeLabelInstances(this,labelData,signalIDs)
            info=this.getLabelerModel().updateAttributeLabelInstances(labelData,signalIDs);
        end

        function outData=getLabelDataForAxesOnAttributeUpdate(this,labelData,isVisibleFlag)
            outData=this.getLabelerModel().getLabelDataForAxesOnAttributeUpdate(labelData,isVisibleFlag);
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

        function resetCheckedSignalIDsCallback(this)
            this.getLabelerModel().resetCheckedSignalIDsCallback();
        end

        function outData=getLabelDefinitionsData(this,data)
            outData=this.getLabelerModel().getLabelDefinitionsData(data);
            featureDefIDs=this.getModeCreatedFeatureDefinitionIDs();
            if~isempty(featureDefIDs)&&any(featureDefIDs.contains(outData.LabelDefinitionID))
                outData.IsFeature=true;
            end
        end

        function info=deleteAllFeatureDefinitions(this)
            lblDefIDs=this.ModeCreatedFeatureDefinitionIDs;
            info.removedLabelDefinitionIDs=lblDefIDs;
            for idx=1:numel(lblDefIDs)
                this.deleteLabelDefinitions(lblDefIDs(idx));
            end
        end

        function[labelDefID,info]=deleteLabelDefinitions(this,data)
            [labelDefID,info]=this.getLabelerModel().deleteLabelDefinitions(data);
            this.ModeCreatedFeatureDefinitionIDs=this.ModeCreatedFeatureDefinitionIDs(this.ModeCreatedFeatureDefinitionIDs~=labelDefID);
        end

        function[successFlag,exceptionKeyword,labelDefID,islabelNameChanged]=updateLabelDefinitions(this,data)
            [successFlag,exceptionKeyword,labelDefID,islabelNameChanged]=this.getLabelerModel().updateLabelDefinitions(data);
        end





        function outData=getExportFeatureTableDataForLabelDefIDs(this,lblDefIDs)
            numLblDefIDs=numel(lblDefIDs);
            outData=repmat(struct('id','',...
            'col1','',...
            'labelType','',...
            'isFeature','',...
            'framePolicyType','',...
            'frameSize','',...
            'frameRateOrOverlapLength',''),numLblDefIDs,1);
            for idx=1:numLblDefIDs
                lblDef=this.getLabelerModel().getLabelDefFromLabelDefID(lblDefIDs(idx));
                outData(idx).id=lblDefIDs(idx);
                outData(idx).col1=lblDef.labelDefinitionName;
                outData(idx).labelType=lblDef.labelType;
                outData(idx).isFeature=lblDef.isFeature;
                outData(idx).framePolicyType=lblDef.framePolicyType;
                outData(idx).frameSize=lblDef.frameSize;
                outData(idx).frameRateOrOverlapLength=lblDef.frameRateOrOverlapLength;
            end
        end





        function outData=getLabelDefinitionsDataForTree(this,labelDefID)
            outData=this.getLabelerModel().getLabelDefinitionsDataForTree(labelDefID);
        end

        function treeOutData=getLabelDefinitionsDataForTreeOnDelete(this,info)
            treeOutData=this.getLabelerModel().getLabelDefinitionsDataForTreeOnDelete(info);
        end




        function treeTableDataStruct=getTreeTableDataStruct(~)







            treeTableDataStruct=struct(...
            'id','',...
            'name','',...
            'isChecked',false,...
            'color','');
        end

        function outData=getImportedSignalsDataForTreeTable(this)
            memberIDs=this.getLabelerModel().getMemberIDs();
            sigData=this.getTreeTableDataStruct();
            outData=repmat(sigData,length(memberIDs),1);
            for idx=1:numel(memberIDs)

                signalObj=Simulink.sdi.getSignal(memberIDs(idx));
                outData(idx).id=num2str(signalObj.ID);
                if idx==1
                    outData(idx).isChecked=true;
                end
                tmMode=getSignalTmMode(this,signalObj.ID);
                [~,~,~,outData(idx).name]=this.getLabelerModel().convertToValidMemberName(signalObj.Name,tmMode);
                temp=this.getLabelerModel().getColorInHex(memberIDs(idx));
                outData(idx).color=['#',temp(1,:),temp(2,:),temp(3,:)];
            end
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





        function outData=getSignalsDataForAxes(this,signalIDs,operation)
            outData=this.getLabelerModel().getSignalsData(signalIDs,operation);
        end





        function outAxesData=getLabelDataForAxesForPlot(this,memberID,featDefIDs)
            if nargin==2
                featDefIDs=this.getSupportedLabelDefinitionIDs(true);
            end
            outAxesData=this.getLabelerModel().getLabelDataForAxesBySignalIDOnSignalCheck(memberID,featDefIDs,false,true);
        end

        function outAxesData=getLabelDataForAxesForPlottedMembersInMainApp(this,featDefIDs)
            memberIDs=string(this.getLabelerModel().getMemberIDs());
            outAxesData=[];
            checkedMemberIDsInMainApp=[];

            for idx=1:numel(memberIDs)
                memberID=memberIDs(idx);
                if this.getLabelerModel().isAnySignalInMemberChecked(memberID)
                    checkedMemberIDsInMainApp=[checkedMemberIDsInMainApp;memberID];
                end
            end
            if~isempty(checkedMemberIDsInMainApp)
                outAxesData=[outAxesData;this.getLabelerModel().getLabelDataForAxesBySignalIDOnSignalCheck(checkedMemberIDsInMainApp,featDefIDs,false,true)];
            end
        end

        function axesData=getLabelDefinitionsDataForAxes(this,labelDefID,info)
            axesData=this.getLabelerModel().getLabelDefinitionsDataForAxes(labelDefID,info,this.checkedMemberIDs);
        end

        function axesOutData=getLabelDefinitionsDataForAxesOnDelete(this,labelDefID,info)
            axesOutData=this.getLabelerModel().getLabelDefinitionsDataForAxesOnDelete(labelDefID,info,this.checkedMemberIDs);
        end

    end
end