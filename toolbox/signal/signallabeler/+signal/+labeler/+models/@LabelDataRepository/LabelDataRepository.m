classdef LabelDataRepository<handle






%#ok<*AGROW>
    properties(GetAccess='public',SetAccess='private')
        Mf0DataModel;
        DmrFile;
        Mf0LabelDataRepository;
        AppName;
        Engine;
        MemberIDs;
        AllCheckableSignalIDs;
        CheckedSignalIDs;
        AutoAddedInstancesInfo;
        MemberIDToLeafSignalIDsMap;
        MemberIDToLeafSignalIDsMapInAutoLabelMode;
        MemberIDsInAutoLabelMode;
        EditableLabelDefintionsIDsInAutoLabelMode;
        IsTimeSpecified;
        AutoLabelSettingsWidgetDataMap;
        Dirty=false;
        DatastoreConstructor;
        FileModeSettings;
        DataStoreForApp;
        AppDataMode;
        PlotSignalAfterLazyLoadComplete;
        CheckedSignalIDsCallback;
        SignalIDColorIndex;
        MemberIDColorIndex;
        MemberIDcolorRuleMap;
    end

    methods(Static)
        function ret=getModel()

            persistent modelObj;
            mlock;
            if isempty(modelObj)||~isvalid(modelObj)
                eng=Simulink.sdi.Instance.engine;
                mf0DataModel=mf.zero.Model;
                dmrFile=signal.labeler.models.LabelDataRepository.generateDmrFileName();
                modelObj=signal.labeler.models.LabelDataRepository("",mf0DataModel,dmrFile,eng);
            end


            ret=modelObj;
        end
    end



    methods(Access=protected)
        function this=LabelDataRepository(~,mf0DataModel,dmrFile,eng)
            this.DmrFile=dmrFile;
            this.Mf0DataModel=mf0DataModel;


            mfdatasource.attachDMRDataSource(this.DmrFile,this.Mf0DataModel,...
            mfdatasource.ToModelSync.None,mfdatasource.ToDataSourceSync.AllElements);
            this.Mf0LabelDataRepository=signallabelereng.datamodel.LabelDataRepository(this.Mf0DataModel);
            this.Engine=eng;
            resetModel(this,false);
            import signal.labeler.models.LabelDataRepository;
        end
    end

    methods




        function resetModel(this,resetLSAndRepoFlag)
            if nargin==1
                resetLSAndRepoFlag=true;
            end
            this.MemberIDs=[];
            this.AllCheckableSignalIDs=[];
            this.CheckedSignalIDs=[];
            resetAutoAddedInstancesInfo(this);
            this.MemberIDToLeafSignalIDsMap=struct;
            this.MemberIDToLeafSignalIDsMapInAutoLabelMode=struct;
            this.MemberIDsInAutoLabelMode=[];
            this.EditableLabelDefintionsIDsInAutoLabelMode=[];
            this.AppName='labeler';
            this.IsTimeSpecified=[];
            this.AutoLabelSettingsWidgetDataMap=struct;
            this.Dirty=false;
            this.resetSettingOnNoMemberSignals();
            this.resetCheckedSignalIDsCallback();
            this.SignalIDColorIndex=1;
            this.MemberIDColorIndex=1;
            this.MemberIDcolorRuleMap=containers.Map('KeyType','double','ValueType','char');
            if resetLSAndRepoFlag
                this.Mf0LabelDataRepository.destroy();
                this.Mf0LabelDataRepository=signallabelereng.datamodel.LabelDataRepository(this.Mf0DataModel);
            end
        end

        function setAutoLabelSettingsWidgetData(this,functionID,settingsWidgetData)
            this.AutoLabelSettingsWidgetDataMap.("x"+functionID)=settingsWidgetData;
        end

        function y=getAutoLabelSettingsWidgetData(this,functionID)
            if isfield(this.AutoLabelSettingsWidgetDataMap,"x"+functionID)
                y=this.AutoLabelSettingsWidgetDataMap.("x"+functionID);
            else
                y=struct('isDefault',true);
            end
        end

        function setIsTimeSpecified(this,IsTimeSpecified)
            this.IsTimeSpecified=IsTimeSpecified;
        end

        function y=getIsTimeSpecified(this)
            y=this.IsTimeSpecified;
        end

        function setAppName(this,AppName)
            this.AppName=AppName;
        end

        function y=getAppName(this)
            y=this.AppName;
        end

        function y=isAppHasMemberOrLabelsDef(this)
            y=this.isAppHasMembers()||this.isAppHasLabelsDef();
        end

        function y=isAppHasMembers(this)
            if this.getAppName()=="autoLabelMode"
                y=~isempty(this.MemberIDsInAutoLabelMode);
            else
                y=~isempty(this.getMemberIDs());
            end
        end

        function y=isAppHasLabelsDef(this)
            y=~isempty(this.getAllLabelDefinitionIDs());
        end

        function flag=isFeatureExtractionMode(this)
            flag=this.getAppName()=="featureExtractionMode";
        end

        function flag=isFastLabelMode(this)
            flag=this.getAppName()=="fastLabelMode";
        end

        function[memberIDs,signalInfo]=getMemberIDsAndSignalInfoForAutoLabelMode(this)
            memberIDs=unique(this.MemberIDsInAutoLabelMode,"stable");
            signalInfo=this.MemberIDToLeafSignalIDsMapInAutoLabelMode;
        end

        function setLeafSignalIDsForMemberID(this,memberID,LeafSignalIDs)
            this.MemberIDToLeafSignalIDsMap.("x"+memberID)=LeafSignalIDs;
        end

        function y=getLeafSignalIDsForMemberID(this,memberID)
            y=this.MemberIDToLeafSignalIDsMap.("x"+memberID);
        end

        function y=getMemberIDToLeafSignalIDsMap(this)
            y=this.MemberIDToLeafSignalIDsMap;
        end

        function removeMemberFromMemberIDToLeafSignalIDsMap(this,memberID)
            this.MemberIDToLeafSignalIDsMap=rmfield(this.MemberIDToLeafSignalIDsMap,("x"+memberID));
        end

        function clearMemberIDToLeafSignalIDsMap(this)
            this.MemberIDToLeafSignalIDsMap=struct;
        end

        function addLeafSignalIDsForMemberIDInAutoLabelMode(this,memberIDs,LeafSignalIDs)
            for idx=1:numel(memberIDs)
                this.MemberIDsInAutoLabelMode=[this.MemberIDsInAutoLabelMode;string(memberIDs(idx))];
                if~isfield(this.MemberIDToLeafSignalIDsMapInAutoLabelMode,"x"+memberIDs(idx))
                    this.MemberIDToLeafSignalIDsMapInAutoLabelMode.("x"+memberIDs(idx))=LeafSignalIDs(idx);
                else
                    this.MemberIDToLeafSignalIDsMapInAutoLabelMode.("x"+memberIDs(idx))=[this.MemberIDToLeafSignalIDsMapInAutoLabelMode.("x"+memberIDs(idx));LeafSignalIDs(idx)];
                end
            end
        end

        function resetLeafSignalIDsForMemberIDAndMemberIDsInAutoLabelMode(this)
            this.MemberIDsInAutoLabelMode=[];
            this.MemberIDToLeafSignalIDsMapInAutoLabelMode=struct;
        end

        function y=getLeafSignalIDsForMemberIDInAutoLabelMode(this,memberID)
            y=this.MemberIDToLeafSignalIDsMapInAutoLabelMode.("x"+memberID);
        end

        function y=getMemberIDs(this)
            y=this.MemberIDs;
        end

        function y=getMemberIDsForExport(this)
            memberIDs=this.MemberIDs;
            for idx=1:numel(memberIDs)
                [isComplex,~]=this.isSignalHasComplexData(memberIDs(idx));
                if~isComplex
                    continue;
                end
                leafSignalIDs=this.getAllSignalLeafChildrenIDs(memberIDs(idx));
                if isempty(leafSignalIDs)


                    memberIDs(idx)=getSignalParent(this.Engine,memberIDs(idx));
                end
            end
            y=memberIDs;
        end

        function flag=isMemberIDs(this,IDs)

            flag=false;
            if(ismember(IDs,this.getMemberIDs()))
                flag=true;
            end
        end

        function y=getCheckedSignalIDs(this)
            y=this.CheckedSignalIDs;
        end

        function setCheckedSignalIDsCallback(this,callback)
            this.CheckedSignalIDsCallback=callback;
        end

        function callback=getCheckedSignalIDsCallback(this)
            callback=this.CheckedSignalIDsCallback;
        end

        function resetCheckedSignalIDsCallback(this)
            this.CheckedSignalIDsCallback=@this.getFirstSignalIDInMember;
        end

        function signalIDs=getCheckedSignalIDsInMember(this,memberID)
            signalIDs=this.getMemberSignals(string(memberID));
            idx=ismember(signalIDs,this.getCheckedSignalIDs());
            signalIDs=signalIDs(idx);
        end

        function uncheckedSignalIDsInMember=getUncheckedSignalIDsInMember(this,memberID)
            allSignalIDsInMembers=this.getLeafSignalIDsForMemberID(memberID);
            if isempty(allSignalIDsInMembers)
                allSignalIDsInMembers=memberID;
            end
            checkedSignalIDsInMember=this.getCheckedSignalIDsInMember(string(memberID));
            uncheckedSignalIDsInMember=allSignalIDsInMembers(~ismember(allSignalIDsInMembers,checkedSignalIDsInMember));
        end

        function y=getAutoAddedInstancesInfo(this)
            y=this.AutoAddedInstancesInfo;
        end

        function resetAutoAddedInstancesInfo(this)
            this.AutoAddedInstancesInfo=[];
        end

        function setMemberIDs(this,memberIDs)
            this.MemberIDs=memberIDs;
        end

        function addMemberIDs(this,memberIDs)
            this.MemberIDs=[this.MemberIDs(:);memberIDs];
        end

        function removeMemberIDs(this,memberIDs)
            allMemberIDs=this.MemberIDs(:);
            this.MemberIDs=allMemberIDs(~ismember(allMemberIDs,memberIDs));
        end

        function clearMemberIDs(this)
            this.MemberIDs=[];
        end

        function checkedSignalIDsInMember=deleteMemberSignalFromModel(this,memberID)

            deleteTreeTableRowInMf0Model(this,string(memberID));
            signalIDs=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(this.Engine,memberID);
            if(isempty(signalIDs))
                signalIDs=memberID;
            end

            checkedSignalIDsInMember=this.getCheckedSignalIDsInMember(string(memberID));
            this.updatedCheckedSignalIDs(checkedSignalIDsInMember,'uncheck');
            this.removeFromAllCheckableSignalIDs(signalIDs);
            this.removeMemberIDs(memberID);
            this.removeMemberFromMemberIDToLeafSignalIDsMap(memberID);

            if strcmp(this.getAppDataMode(),'signalFile')||strcmp(this.getAppDataMode(),'audioFile')

                this.removeImportedFilesFromDataStore(memberID);
            end



            if~this.isAppHasMembers()
                this.setIsTimeSpecified([]);
            end


            dbIDs=int32(unique([memberID;signalIDs]));
            signal.sigappsshared.SignalUtilities.deleteSignalsAndResampledSignalsInEngine(dbIDs);


            labelDefinitionIDs=getAllLabelDefinitionIDs(this);
            for i=1:numel(labelDefinitionIDs)
                labelDefID=labelDefinitionIDs(i);
                labelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,labelDefID,string(memberID));

                labelData=struct('LabelInstanceID',labelInstanceIDs);
                deleteLabelInstancesFromModelOnMemberDelete(this,labelData);
            end

        end

        function y=getAllCheckableSignalIDs(this)
            y=this.AllCheckableSignalIDs;
        end

        function setAllCheckableSignalIDs(this,signalIDs)
            this.AllCheckableSignalIDs=signalIDs;
        end

        function addAllCheckableSignalIDs(this,signalIDs)
            this.AllCheckableSignalIDs=[this.AllCheckableSignalIDs(:);signalIDs];
        end

        function removeFromAllCheckableSignalIDs(this,signalIDs)
            allCheckableSignalIDs=this.AllCheckableSignalIDs(:);
            this.AllCheckableSignalIDs=allCheckableSignalIDs(~ismember(allCheckableSignalIDs,signalIDs));
        end

        function clearAllCheckableSignalIDs(this)
            this.AllCheckableSignalIDs=[];
        end

        function deleteAllMembersFromModel(this)

            this.clearCheckedSignalIDs();
            this.clearAllCheckableSignalIDs();
            this.clearMemberIDs();
            this.clearMemberIDToLeafSignalIDsMap();
            this.setIsTimeSpecified([]);

            this.Mf0LabelDataRepository.treeTableRows.destroyAllContents();

            signal.labeler.SignalUtilities.deleteAllSLRuns();
        end

        function updatedCheckedSignalIDs(this,signalIDs,checkFlag)


            if strcmp(checkFlag,'check')
                this.CheckedSignalIDs=unique([this.CheckedSignalIDs;signalIDs],'stable');

            elseif strcmp(checkFlag,'uncheck')

                this.CheckedSignalIDs=setdiff(this.CheckedSignalIDs,signalIDs);
            end

            this.CheckedSignalIDs=this.AllCheckableSignalIDs(ismember(this.AllCheckableSignalIDs,this.CheckedSignalIDs));
        end

        function clearCheckedSignalIDs(this)
            this.CheckedSignalIDs=[];
        end

        function y=isDirty(this)
            y=this.Dirty;
        end

        function dirtyStateChanged=setDirty(this,dirtyStatus)
            dirtyStateChanged=false;
            if this.Dirty~=dirtyStatus
                this.Dirty=dirtyStatus;
                dirtyStateChanged=true;
            end
        end

        function flag=isAnySignalFromSameMemberChecked(this,signalID)


            memberID=getMemberIDForSignalID(this,signalID);
            flag=isAnySignalInMemberChecked(this,memberID);
        end

        function info=validateLabelDefintionName(this,labelDefinitionName,parentLabelDefinitionID)
            info=struct;
            info.successFlag=false;
            info.exceptionKeyword="";
            if(~ischar(labelDefinitionName)&&(~(isstring(labelDefinitionName)...
                &&isscalar(labelDefinitionName))))||~isvarname(labelDefinitionName)...
                ||isempty(labelDefinitionName)
                info.exceptionKeyword="InvalidName";
                return;
            end
            if isHaveLabelDefWithLabelDefName(this,labelDefinitionName,parentLabelDefinitionID)
                info.exceptionKeyword="UniqueLabels";
                return;
            end
            info.successFlag=true;
        end

        function[successFlag,exceptionKeyword,info]=addLabelDefinitions(this,data)


            exceptionKeyword="";
            info=struct;
            info.newLabelDefIDs=[];
            info.newAttrLabelInstanceIDs=[];
            info.newAttrLabelInstanceValues=[];
            info.newAttrParentLabelInstanceIDs=[];
            info.newAttrLabelInstanceMemberIDs=[];

            [~,defaultInfo]=formatValueForLSS(this,data.LabelDataDefaultValue,data.LabelDataType);
            if~defaultInfo.successFlag
                successFlag=false;
                exceptionKeyword=defaultInfo.exception;
                return;
            end
            if string(data.LabelDataType)=="categorical"

                data.LabelDataCategories(data.LabelDataCategories=="")=[];
            end

            validationInfo=validateLabelDefintionName(this,data.LabelName,data.ParentLabelDefinitionID);
            if~validationInfo.successFlag
                successFlag=false;
                exceptionKeyword=validationInfo.exceptionKeyword;
                return;
            end

            tx=this.Mf0DataModel.beginTransaction;
            labelDefinitionID=generateUUID(this);

            mf0LabelDefStruct=struct('labelDefinitionID',labelDefinitionID,...
            "parentLabelDefinitionID",data.ParentLabelDefinitionID,...
            "isFeature",false,...
            "labelDefinitionName",data.LabelName,...
            "labelType",data.LabelType,...
            "labelDataType",data.LabelDataType,...
            "categories",string(data.LabelDataCategories),...
            "defaultValue",data.LabelDataDefaultValue,...
            "description",data.LabelDescription,...
            "tag","");
            if isfield(data,'isFeature')
                mf0LabelDefStruct.isFeature=data.isFeature;
                mf0LabelDefStruct.featureExtractorType=data.featureExtractorType;
                if data.LabelType=="roi"
                    mf0LabelDefStruct.framePolicyType=data.framePolicyType;
                    mf0LabelDefStruct.frameSize=data.frameSize;
                    mf0LabelDefStruct.frameRateOrOverlapLength=data.frameRateOrOverlapLength;
                end
            end
            this.Mf0LabelDataRepository.createIntoLabelDefinitions(mf0LabelDefStruct);
            info.newLabelDefIDs=labelDefinitionID;
            memberIDs=string(this.getMemberIDs());
            numMemberIDs=numel(memberIDs);
            mf0LabelDataStruct=getMf0LabelDataStruct(this);
            if isemptyString(this,data.ParentLabelDefinitionID)


                this.Mf0LabelDataRepository.parentLabelDefinitionIDs.add(labelDefinitionID);
                if data.LabelType=="attribute"


                    labelInstanceValue=string(data.LabelDataDefaultValue);
                    mf0LabelDataStruct.labelDefinitionID=labelDefinitionID;
                    mf0LabelDataStruct.labelInstanceValue=labelInstanceValue;
                    info.newAttrLabelInstanceIDs=repmat("",numMemberIDs,1);
                    info.newAttrLabelInstanceValues=repmat("",numMemberIDs,1);
                    info.newAttrParentLabelInstanceIDs=repmat("",numMemberIDs,1);
                    info.newAttrLabelInstanceMemberIDs=repmat("",numMemberIDs,1);
                    for memIdx=1:numMemberIDs
                        mf0LabelDataStruct.memberID=memberIDs(memIdx);
                        labelInstanceID=this.createInstanceInMf0Model(mf0LabelDataStruct);
                        info.newAttrLabelInstanceIDs(memIdx)=labelInstanceID;
                        info.newAttrLabelInstanceValues(memIdx)=labelInstanceValue;
                        info.newAttrLabelInstanceMemberIDs(memIdx)=memberIDs(memIdx);
                    end
                end
            else


                parentLblDef=getLabelDefFromLabelDefID(this,data.ParentLabelDefinitionID);
                parentLblDef.childerenLabelDefinitionIDs.add(labelDefinitionID);
                if data.LabelType=="attribute"


                    labelInstanceValue=string(data.LabelDataDefaultValue);
                    mf0LabelDataStruct.labelDefinitionID=labelDefinitionID;
                    mf0LabelDataStruct.labelInstanceValue=labelInstanceValue;
                    for memIdx=1:numMemberIDs
                        mf0LabelDataStruct.memberID=memberIDs(memIdx);

                        parentLabelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,data.ParentLabelDefinitionID,memberIDs(memIdx));
                        numParentInstanceIDs=numel(parentLabelInstanceIDs);
                        currentInfo.newAttrLabelInstanceIDs=repmat("",numParentInstanceIDs,1);
                        currentInfo.newAttrLabelInstanceValues=repmat("",numParentInstanceIDs,1);
                        currentInfo.newAttrParentLabelInstanceIDs=repmat("",numParentInstanceIDs,1);
                        currentInfo.newAttrLabelInstanceMemberIDs=repmat(memberIDs(memIdx),numParentInstanceIDs,1);
                        for parentLblIdx=1:numParentInstanceIDs
                            mf0LabelDataStruct.parentLabelInstanceID=parentLabelInstanceIDs(parentLblIdx);
                            labelInstanceID=this.createInstanceInMf0Model(mf0LabelDataStruct);
                            currentInfo.newAttrLabelInstanceIDs(parentLblIdx)=labelInstanceID;
                            currentInfo.newAttrLabelInstanceValues(parentLblIdx)=labelInstanceValue;
                            currentInfo.newAttrParentLabelInstanceIDs(parentLblIdx)=parentLabelInstanceIDs(parentLblIdx);
                        end
                        info.newAttrLabelInstanceIDs=[info.newAttrLabelInstanceIDs;currentInfo.newAttrLabelInstanceIDs];
                        info.newAttrLabelInstanceValues=[info.newAttrLabelInstanceValues;currentInfo.newAttrLabelInstanceValues];
                        info.newAttrParentLabelInstanceIDs=[info.newAttrParentLabelInstanceIDs;currentInfo.newAttrParentLabelInstanceIDs];
                        info.newAttrLabelInstanceMemberIDs=[info.newAttrLabelInstanceMemberIDs;currentInfo.newAttrLabelInstanceMemberIDs];
                    end
                end
            end
            tx.commit;
            successFlag=true;
        end

        function[successFlag,exceptionKeyword,labelDefID,islabelNameChanged]=updateLabelDefinitions(this,data)

            labelDefID=string(data.LabelDefinitionID);
            cachedLblDef=getLabelDefFromLabelDefID(this,labelDefID);
            islabelNameChanged=false;
            successFlag=true;
            exceptionKeyword='';




            newLabelDefName=string(data.LabelName);
            if cachedLblDef.labelDefinitionName~=newLabelDefName

                validationInfo=validateLabelDefintionName(this,newLabelDefName,cachedLblDef.parentLabelDefinitionID);
                successFlag=validationInfo.successFlag;
                exceptionKeyword=validationInfo.exceptionKeyword;
                islabelNameChanged=successFlag;
            end
            newDescription=string(data.LabelDescription);
            isDescriptionChanged=cachedLblDef.description~=newDescription;


            newLabelDataCategories=string(data.LabelDataCategories);
            addedLabelDataCategories=setdiff(newLabelDataCategories,string(cachedLblDef.categories));
            isLabelDataCategoriesChanged=successFlag&&cachedLblDef.labelDataType=="categorical"&&...
            ~isempty(addedLabelDataCategories);

            newDefaultValue=string(data.LabelDataDefaultValue);
            isDefaultValueChanged=false;
            if successFlag&&~isequal(cachedLblDef.defaultValue,newDefaultValue)
                [~,info]=formatValueForLSS(this,newDefaultValue,cachedLblDef.labelDataType);
                successFlag=info.successFlag;
                exceptionKeyword=info.exception;
                isDefaultValueChanged=successFlag;
            end

            if successFlag
                tx=this.Mf0DataModel.beginTransaction;
                if islabelNameChanged
                    cachedLblDef.labelDefinitionName=newLabelDefName;
                end
                if isDescriptionChanged
                    cachedLblDef.description=newDescription;
                end
                if isLabelDataCategoriesChanged
                    cachedLblDef.categories=[cachedLblDef.categories,addedLabelDataCategories];
                end
                if isDefaultValueChanged
                    cachedLblDef.defaultValue=newDefaultValue;
                end
                tx.commit;
            end
        end

        function info=deleteLabelInstancesForLabelDefintionID(this,labelDefID)
            tx=this.Mf0DataModel.beginTransaction;
            info=struct;
            info.removedLabelInstanceIDs=[];
            info.removedLabelInstanceMemberIDs=[];
            info.parentLabelInstanceIDs=[];
            memberIDs=string(getMemberIDs(this));
            for idx=1:numel(memberIDs)
                removedLabelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,labelDefID,memberIDs(idx));
                parentLabelInstanceIDs=[];
                for jdx=1:numel(removedLabelInstanceIDs)
                    lblInstace=getLabelInstanceFromLabelInstanceID(this,removedLabelInstanceIDs(jdx));
                    parentLabelInstanceIDs=[parentLabelInstanceIDs;string(lblInstace.parentLabelInstanceID)];
                    lblInstace.destroy();
                    info.removedLabelInstanceMemberIDs=[info.removedLabelInstanceMemberIDs;memberIDs(idx)];
                end
                info.removedLabelInstanceIDs=[info.removedLabelInstanceIDs;removedLabelInstanceIDs];
                info.parentLabelInstanceIDs=[info.parentLabelInstanceIDs;parentLabelInstanceIDs];
            end
            tx.commit;
        end

        function[labelDefID,info]=deleteLabelDefinitions(this,data)



            tx=this.Mf0DataModel.beginTransaction;
            info=struct;
            info.removedLabelInstanceIDs=[];
            info.removedLabelInstanceMemberIDs=[];
            info.parentLabelInstanceIDs=[];
            info.removedLabelDefinitionIDs=[];
            info.removedLabelDefinitionNames=[];
            info.removedLabelDefinitionParentIDs=[];
            info.removedLabelDefinitionParentNames=[];
            info.removedLabelDefinitionTypes=[];
            info.removedTreeTableRowIDs=[];
            info.removedTreeTableRowParentIDs=[];
            labelDefID=string(data.LabelDefinitionID);


            lblDef=getLabelDefFromLabelDefID(this,labelDefID);
            [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
            if isSublabel


                parentLblDef.childerenLabelDefinitionIDs.remove(labelDefID);
                info=deleteLabelInstancesForLabelDefintionID(this,labelDefID);
                numelOfLabelDefInfoToAdd=numel(info.removedLabelInstanceIDs);
                if numelOfLabelDefInfoToAdd==0
                    info.removedLabelInstanceIDs="";
                    info.removedLabelInstanceMemberIDs="";
                    info.parentLabelInstanceIDs="";
                    numelOfLabelDefInfoToAdd=1;
                end
                info.removedLabelDefinitionIDs=repmat(labelDefID,numelOfLabelDefInfoToAdd,1);
                info.removedLabelDefinitionNames=repmat(string(lblDef.labelDefinitionName),numelOfLabelDefInfoToAdd,1);
                info.removedLabelDefinitionParentIDs=repmat(string(parentLblDef.labelDefinitionID),numelOfLabelDefInfoToAdd,1);
                info.removedLabelDefinitionParentNames=repmat(string(parentLblDef.labelDefinitionName),numelOfLabelDefInfoToAdd,1);
                info.removedLabelDefinitionTypes=repmat(string(lblDef.labelType),numelOfLabelDefInfoToAdd,1);
                info.removedTreeTableRowIDs=[];
                info.removedTreeTableRowParentIDs=[];
                if getAppName(this)=="labeler"
                    if lblDef.labelType=="attribute"



                        for rIdx=1:numel(info.removedLabelInstanceIDs)
                            treeTableRowIDToDelete=info.removedLabelInstanceIDs(rIdx);
                            parentTreeTableRowID=deleteTreeTableRowInMf0Model(this,treeTableRowIDToDelete);
                            info.removedTreeTableRowIDs=[info.removedTreeTableRowIDs;treeTableRowIDToDelete];
                            info.removedTreeTableRowParentIDs=[info.removedTreeTableRowParentIDs;parentTreeTableRowID];
                        end
                    else
                        memberIDs=string(getMemberIDs(this));
                        for mIdx=1:numel(memberIDs)

                            parentInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,parentLblDef.labelDefinitionID,memberIDs(mIdx));
                            for pIdx=1:numel(parentInstanceIDs)
                                treeTableRowIDToDelete=getHeaderID(this,labelDefID,memberIDs(mIdx),parentInstanceIDs(pIdx));
                                parentTreeTableRowID=deleteTreeTableRowInMf0Model(this,treeTableRowIDToDelete);
                                info.removedTreeTableRowIDs=[info.removedTreeTableRowIDs;treeTableRowIDToDelete];
                                info.removedTreeTableRowParentIDs=[info.removedTreeTableRowParentIDs;parentTreeTableRowID];
                            end
                        end
                    end
                end
            else

                childrenLabelDefIDs=getChildrenLabelDefIDs(this,lblDef);
                numOfChildrenLabelDefIDs=numel(childrenLabelDefIDs);
                for idx=1:numOfChildrenLabelDefIDs
                    removedLabelDefID=childrenLabelDefIDs(idx);
                    childLblDef=getLabelDefFromLabelDefID(this,removedLabelDefID);
                    currentDefInfo=deleteLabelInstancesForLabelDefintionID(this,removedLabelDefID);
                    numelOfLabelDefInfoToAdd=numel(currentDefInfo.removedLabelInstanceIDs);
                    if numelOfLabelDefInfoToAdd==0
                        currentDefInfo.removedLabelInstanceIDs="";
                        currentDefInfo.removedLabelInstanceMemberIDs="";
                        currentDefInfo.parentLabelInstanceIDs="";
                        numelOfLabelDefInfoToAdd=1;
                    end
                    info.removedLabelInstanceIDs=[info.removedLabelInstanceIDs;currentDefInfo.removedLabelInstanceIDs];
                    info.removedLabelInstanceMemberIDs=[info.removedLabelInstanceMemberIDs;currentDefInfo.removedLabelInstanceMemberIDs];
                    info.parentLabelInstanceIDs=[info.parentLabelInstanceIDs;currentDefInfo.parentLabelInstanceIDs];
                    info.removedLabelDefinitionIDs=[info.removedLabelDefinitionIDs;repmat(removedLabelDefID,numelOfLabelDefInfoToAdd,1)];
                    info.removedLabelDefinitionNames=[info.removedLabelDefinitionNames;repmat(string(childLblDef.labelDefinitionName),numelOfLabelDefInfoToAdd,1)];
                    info.removedLabelDefinitionParentIDs=[info.removedLabelDefinitionParentIDs;repmat(string(lblDef.labelDefinitionID),numelOfLabelDefInfoToAdd,1)];
                    info.removedLabelDefinitionParentNames=[info.removedLabelDefinitionParentNames;repmat(string(lblDef.labelDefinitionName),numelOfLabelDefInfoToAdd,1)];
                    info.removedLabelDefinitionTypes=[info.removedLabelDefinitionTypes;repmat(string(childLblDef.labelType),numelOfLabelDefInfoToAdd,1)];
                    childLblDef.destroy();
                end
                this.Mf0LabelDataRepository.parentLabelDefinitionIDs.remove(labelDefID);
                currentDefInfo=deleteLabelInstancesForLabelDefintionID(this,labelDefID);
                numelOfLabelDefInfoToAdd=numel(currentDefInfo.removedLabelInstanceIDs);
                if numelOfLabelDefInfoToAdd==0
                    currentDefInfo.removedLabelInstanceIDs="";
                    currentDefInfo.removedLabelInstanceMemberIDs="";
                    currentDefInfo.parentLabelInstanceIDs="";
                    numelOfLabelDefInfoToAdd=1;
                end
                info.removedLabelInstanceIDs=[currentDefInfo.removedLabelInstanceIDs;info.removedLabelInstanceIDs];
                info.removedLabelInstanceMemberIDs=[currentDefInfo.removedLabelInstanceMemberIDs;info.removedLabelInstanceMemberIDs];
                info.parentLabelInstanceIDs=[currentDefInfo.parentLabelInstanceIDs;info.parentLabelInstanceIDs];
                info.removedLabelDefinitionIDs=[repmat(labelDefID,numelOfLabelDefInfoToAdd,1);info.removedLabelDefinitionIDs];
                info.removedLabelDefinitionNames=[repmat(string(lblDef.labelDefinitionName),numelOfLabelDefInfoToAdd,1);info.removedLabelDefinitionNames];
                info.removedLabelDefinitionParentIDs=[repmat(string(parentLblDef.labelDefinitionID),numelOfLabelDefInfoToAdd,1);info.removedLabelDefinitionParentIDs];
                info.removedLabelDefinitionParentNames=[repmat(string(parentLblDef.labelDefinitionName),numelOfLabelDefInfoToAdd,1);info.removedLabelDefinitionParentNames];
                info.removedLabelDefinitionTypes=[repmat(string(lblDef.labelType),numelOfLabelDefInfoToAdd,1);info.removedLabelDefinitionTypes];
                if getAppName(this)=="labeler"


                    if lblDef.labelType=="attribute"
                        for rIdx=1:numel(currentDefInfo.removedLabelInstanceIDs)
                            treeTableRowIDToDelete=currentDefInfo.removedLabelInstanceIDs(rIdx);
                            parentTreeTableRowID=deleteTreeTableRowInMf0Model(this,treeTableRowIDToDelete);
                            info.removedTreeTableRowIDs=[info.removedTreeTableRowIDs;treeTableRowIDToDelete];
                            info.removedTreeTableRowParentIDs=[info.removedTreeTableRowParentIDs;parentTreeTableRowID];
                        end
                    else
                        memberIDs=string(getMemberIDs(this));
                        for mIdx=1:numel(memberIDs)
                            treeTableRowIDToDelete=getHeaderID(this,labelDefID,memberIDs(mIdx),"");
                            parentTreeTableRowID=deleteTreeTableRowInMf0Model(this,treeTableRowIDToDelete);
                            info.removedTreeTableRowIDs=[info.removedTreeTableRowIDs;treeTableRowIDToDelete];
                            info.removedTreeTableRowParentIDs=[info.removedTreeTableRowParentIDs;parentTreeTableRowID];
                        end
                    end
                end
            end

            lblDef.destroy();
            tx.commit;
        end

        function info=deleteAllLabelDefinitions(this)
            tx=this.Mf0DataModel.beginTransaction;
            labelDefinitionIDs=this.getAllParentLabelDefinitionIDs();
            info.removedTreeTableRowIDs=[];
            info.removedTreeTableRowParentIDs=[];
            for idx=1:length(labelDefinitionIDs)
                data.LabelDefinitionID=labelDefinitionIDs(idx);
                [~,currentInfo]=this.deleteLabelDefinitions(data);
                info.removedTreeTableRowIDs=[info.removedTreeTableRowIDs;currentInfo.removedTreeTableRowIDs];
                info.removedTreeTableRowParentIDs=[info.removedTreeTableRowParentIDs;currentInfo.removedTreeTableRowParentIDs];
            end
            tx.commit;
        end

        function[successFlag,exceptionKeyword,info]=addLabelInstance(this,signalIDs,labelData,isMemberID,isNeedValidation,lblDef,mf0LabelDataStruct)

            labelDefID=string(labelData.LabelDefinitionID);
            if nargin==3
                isMemberID=false;
                isNeedValidation=true;
                lblDef=getLabelDefFromLabelDefID(this,labelDefID);
                mf0LabelDataStruct=getMf0LabelDataStruct(this);
            end
            successFlag=true;
            exceptionKeyword='';
            info=struct;
            info.newAttrLabelInstanceIDs=[];
            info.newAttrLabelInstanceMemberIDs=[];
            info.newAttrLabelInstanceValues=[];
            info.newParentLabelInstanceIDsForAttrLabels=[];
            info.newInstanceIDs=[];
            info.newInstanceMemberIDs=[];
            if isNeedValidation
                [value,valueInfo]=formatValueForLSS(this,labelData.LabelValue,lblDef.labelDataType);
                if~valueInfo.successFlag
                    successFlag=false;
                    exceptionKeyword=valueInfo.exception;
                    return;
                end
                if isempty(value)
                    if isempty(lblDef.defaultValue)&&lblDef.labelType~="attribute"
                        successFlag=false;
                        exceptionKeyword="mustSpecifyValue";
                        return;
                    end
                end
            end

            if isMemberID
                memberIDs=signalIDs;
            else
                memberIDs=unique(getMemberIDForSignalID(this,signalIDs),'stable');
            end
            signalIDs=[];
            parentLabelInstanceID=string(labelData.ParentLabelInstanceID);
            isSubLabel=~isemptyString(this,parentLabelInstanceID);
            labelInstanceTimeMin=[];
            labelInstanceTimeMax=[];
            isAttLblDef=true;
            labelValue=string(labelData.LabelValue);
            if lblDef.labelType=="point"
                labelInstanceTimeMin=labelData.tMin;
                isAttLblDef=false;
            elseif lblDef.labelType=="roi"
                labelInstanceTimeMin=labelData.tMin;
                labelInstanceTimeMax=labelData.tMax;
                isAttLblDef=false;
            end
            mf0ChildLabelDataStruct=mf0LabelDataStruct;
            isAppInFeatureExtractionMode=isFeatureExtractionMode(this);
            for idx=1:numel(memberIDs)
                signalIDs=[signalIDs;getFirstMemberSignal(this,memberIDs(idx))];
                mf0LabelDataStruct.memberID=memberIDs(idx);
                mf0LabelDataStruct.labelDefinitionID=labelDefID;
                mf0LabelDataStruct.parentLabelInstanceID=parentLabelInstanceID;
                mf0LabelDataStruct.labelInstanceValue=labelValue;
                if isAttLblDef
                    labelInstanceID=this.createInstanceInMf0Model(mf0LabelDataStruct);
                    info.newAttrLabelInstanceIDs=[info.newAttrLabelInstanceIDs;labelInstanceID];
                    info.newAttrLabelInstanceValues=[info.newAttrLabelInstanceValues;labelValue];
                    info.newParentLabelInstanceIDsForAttrLabels=[info.newParentLabelInstanceIDsForAttrLabels;parentLabelInstanceID];
                    info.newAttrLabelInstanceMemberIDs=[info.newAttrLabelInstanceMemberIDs;memberIDs(idx)];
                else
                    mf0LabelDataStruct.labelInstanceTimeMin=labelInstanceTimeMin;
                    mf0LabelDataStruct.labelInstanceTimeMax=labelInstanceTimeMax;



                    mf0LabelDataStruct.isPlottedInTimeAxes=~isAppInFeatureExtractionMode&&~isFastLabelMode(this)&&isAnySignalInMemberChecked(this,mf0LabelDataStruct.memberID);
                    labelInstanceID=createInstanceInMf0Model(this,mf0LabelDataStruct);
                    info.newInstanceIDs=[info.newInstanceIDs;labelInstanceID];
                    info.newInstanceMemberIDs=[info.newInstanceMemberIDs;memberIDs(idx)];
                end


                if~isSubLabel&&~isAppInFeatureExtractionMode

                    mf0ChildLabelDataStruct.memberID=memberIDs(idx);
                    attributeChildrenLabelDefIDs=getAttributeChildrenLabelDefIDs(this,lblDef);
                    for jdx=1:numel(attributeChildrenLabelDefIDs)
                        attLblDef=getLabelDefFromLabelDefID(this,attributeChildrenLabelDefIDs(jdx));
                        mf0ChildLabelDataStruct.labelDefinitionID=attLblDef.labelDefinitionID;
                        mf0ChildLabelDataStruct.parentLabelInstanceID=labelInstanceID;
                        mf0ChildLabelDataStruct.labelInstanceValue=string(attLblDef.defaultValue);
                        attLabelInstanceID=this.createInstanceInMf0Model(mf0ChildLabelDataStruct);
                        info.newAttrLabelInstanceMemberIDs=[info.newAttrLabelInstanceMemberIDs;memberIDs(idx)];
                        info.newAttrLabelInstanceIDs=[info.newAttrLabelInstanceIDs;attLabelInstanceID];
                        info.newAttrLabelInstanceValues=[info.newAttrLabelInstanceValues;mf0ChildLabelDataStruct.labelInstanceValue];
                        info.newParentLabelInstanceIDsForAttrLabels=[info.newParentLabelInstanceIDsForAttrLabels;labelInstanceID];
                    end
                end
            end



            info.SignalIDs=signalIDs;
            info.MemberIDs=memberIDs;
            info.NumInstances=numel(info.newAttrLabelInstanceIDs)+numel(info.newInstanceIDs);
        end

        function info=updateLabelInstance(this,labelData,isUpdateWhileAutoLabeling,isNeedValidation)
            if nargin<3
                isUpdateWhileAutoLabeling=false;
            end
            if nargin<4
                isNeedValidation=true;
            end

            labelInstanceID=string(labelData.LabelInstanceID);
            lblInstance=getLabelInstanceFromLabelInstanceID(this,labelData.LabelInstanceID);
            labelDefID=lblInstance.labelDefinitionID;
            lblDef=getLabelDefFromLabelDefID(this,labelDefID);
            [value,info]=formatValueForLSS(this,labelData.LabelInstanceValue,lblDef.labelDataType);
            if isNeedValidation&&~info.successFlag
                return;
            end
            inputArgs={};
            tx=this.Mf0DataModel.beginTransaction;
            if lblDef.labelType=="point"
                inputArgs={labelData.LabelInstanceTimeMinValue};
                lblInstance.labelInstanceTimeMin=labelData.LabelInstanceTimeMinValue;
            elseif lblDef.labelType=="roi"
                inputArgs={[labelData.LabelInstanceTimeMinValue,labelData.LabelInstanceTimeMaxValue]};
                lblInstance.labelInstanceTimeMin=labelData.LabelInstanceTimeMinValue;
                lblInstance.labelInstanceTimeMax=labelData.LabelInstanceTimeMaxValue;
            end
            inputArgs=[inputArgs,{value}];
            lblInstance.labelInstanceValue=labelData.LabelInstanceValue;
            if string(lblDef.labelDataType)=="numeric"
                if isnumeric(labelData.LabelInstanceValue)
                    lblInstance.labelInstanceNumericValue=labelData.LabelInstanceValue;
                else
                    lblInstance.labelInstanceNumericValue=str2double(labelData.LabelInstanceValue);
                end
            end
            tx.commit;
            info.successFlag=true;
            if~isUpdateWhileAutoLabeling&&info.successFlag&&strcmp(this.getAppName(),'autoLabelMode')
                this.updateAutoAddedInstancesInfo(labelInstanceID,inputArgs);
            end
        end

        function updateAutoAddedInstancesInfo(this,labelInstanceID,updatedTimeAndValue)
            autoAddedInstancesNewValueInfo=this.getAutoAddedInstancesNewValueInfo();
            if isempty(autoAddedInstancesNewValueInfo)
                return;
            end
            if nargin>2
                if isempty(autoAddedInstancesNewValueInfo.newInstanceIDs)
                    instanceIdx=autoAddedInstancesNewValueInfo.updatedAttrLabelInstanceIDs==labelInstanceID;
                    autoAddedInstancesNewValueInfo.updatedAttrLabelInstanceValues(instanceIdx)=updatedTimeAndValue{1};
                else
                    instanceIdx=autoAddedInstancesNewValueInfo.newInstanceIDs==labelInstanceID;
                    autoAddedInstancesNewValueInfo.newInstanceValues(instanceIdx)=updatedTimeAndValue{2};
                    autoAddedInstancesNewValueInfo.newInstanceLocations(instanceIdx,:)=updatedTimeAndValue{1};
                end
            else

                if~isempty(autoAddedInstancesNewValueInfo.newInstanceIDs)
                    instanceIdx=autoAddedInstancesNewValueInfo.newInstanceIDs~=labelInstanceID;
                    autoAddedInstancesNewValueInfo.newInstanceIDs=autoAddedInstancesNewValueInfo.newInstanceIDs(instanceIdx);
                    this.AutoAddedInstancesInfo.InstanceIDs=autoAddedInstancesNewValueInfo.newInstanceIDs;
                    if~isempty(autoAddedInstancesNewValueInfo.newInstanceParentLabelInstanceIDs)
                        autoAddedInstancesNewValueInfo.newInstanceParentLabelInstanceIDs=autoAddedInstancesNewValueInfo.newInstanceParentLabelInstanceIDs(instanceIdx);
                        this.AutoAddedInstancesInfo.ParentInstanceIDs=autoAddedInstancesNewValueInfo.newInstanceParentLabelInstanceIDs;
                    end
                    autoAddedInstancesNewValueInfo.newInstanceValues=autoAddedInstancesNewValueInfo.newInstanceValues(instanceIdx);
                    autoAddedInstancesNewValueInfo.newInstanceLocations=autoAddedInstancesNewValueInfo.newInstanceLocations(instanceIdx,:);
                end
            end
            this.setAutoAddedInstancesNewValueInfo(autoAddedInstancesNewValueInfo);
        end

        function info=updateAttributeLabelInstances(this,labelData,signalIDs)


            memberIDs=unique(getMemberIDForSignalID(this,signalIDs),'stable');
            labelDefinitionID=string(labelData.LabelDefinitionID);
            numMember=numel(memberIDs);
            labelInstanceIDs=repmat("",numMember,1);
            parentLabelInstanceIDs=repmat("",numMember,1);
            for idx=1:numel(memberIDs)
                memberID=string(memberIDs(idx));

                labelInstanceID=getLabelInstaceIDsForLabelDefIDAndMemberID(this,labelDefinitionID,memberID);
                newLabelData.LabelInstanceID=labelInstanceID;
                newLabelData.LabelInstanceValue=labelData.LabelInstanceValue;
                updateLabelInstance(this,newLabelData,false);
                lblInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceID);
                labelInstanceIDs(idx)=labelInstanceID;
                parentLabelInstanceIDs(idx)=lblInstance.parentLabelInstanceID;
            end
            info.successFlag=true;
            info.labelData=struct('LabelInstanceIDs',labelInstanceIDs,...
            'ParentLabelInstanceIDs',parentLabelInstanceIDs);
        end

        function info=deleteROIandPointLabelInstancesUnlabelAttributeInstances(this,labelData)



            tx=this.Mf0DataModel.beginTransaction;
            removedLabelInstanceIDs=[];
            removedLabelInstanceParentRowIDs=[];
            removedLabelInstanceLabelDefIDs=[];
            removedLabelInstanceMemberID=[];
            editedLabelInstanceIDs=[];
            parentLabelInstanceIDsForEditedLabelInstanceIDs=[];
            labelInstanceIDs=string(labelData.LabelInstanceID);
            for idx=1:numel(labelInstanceIDs)

                lblInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceIDs(idx));
                removedLabelInstanceMemberID=string(lblInstance.memberID);
                lblDef=getLabelDefFromLabelDefID(this,lblInstance.labelDefinitionID);
                if lblDef.labelType=="attribute"
                    lblInstance.labelInstanceValue="";
                    editedLabelInstanceIDs=[editedLabelInstanceIDs;labelInstanceIDs(idx)];
                    parentLabelInstanceIDsForEditedLabelInstanceIDs=[parentLabelInstanceIDsForEditedLabelInstanceIDs;...
                    ""];


                    childrenLblDefIDs=getChildrenLabelDefIDs(this,lblDef);
                    for cLblDefIdx=1:numel(childrenLblDefIDs)
                        childrenlblDef=getLabelDefFromLabelDefID(this,childrenLblDefIDs(cLblDefIdx));
                        if childrenlblDef.labelType=="attribute"
                            childrenLblInstanceID=getLabelInstaceIDsForLabelDefIDAndMemberID(this,childrenLblDefIDs(cLblDefIdx),lblInstance.memberID);
                            childrenLblInstance=getLabelInstanceFromLabelInstanceID(this,childrenLblInstanceID);
                            editedLabelInstanceIDs=[editedLabelInstanceIDs;string(childrenLblInstanceID)];
                            parentLabelInstanceIDsForEditedLabelInstanceIDs=[parentLabelInstanceIDsForEditedLabelInstanceIDs;...
                            string(childrenLblInstance.parentLabelInstanceID)];

                            childrenLblInstance.labelInstanceValue="";
                        else
                            childrenLblInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,childrenLblDefIDs(cLblDefIdx),lblInstance.memberID);
                            for cdx=1:numel(childrenLblInstanceIDs)
                                childrenLblInstance=getLabelInstanceFromLabelInstanceID(this,childrenLblInstanceIDs(cdx));
                                removedLabelInstanceIDs=[removedLabelInstanceIDs;childrenLblInstanceIDs(cdx)];
                                removedLabelInstanceLabelDefIDs=[removedLabelInstanceLabelDefIDs;childrenLblDefIDs(cLblDefIdx)];

                                childrenLblInstance.destroy();
                                removedLabelInstanceParentRowID=deleteTreeTableRowInMf0Model(this,childrenLblInstanceIDs(cdx));
                                removedLabelInstanceParentRowIDs=[removedLabelInstanceParentRowIDs;removedLabelInstanceParentRowID];
                            end
                        end
                    end
                else
                    [removedLoopLabelInstanceIDs,removedLoopLabelInstanceParentRowIDs,removedLoopLabelInstanceLabelDefIDs]=removeInstanceLabelDestroyChildren(this,lblInstance,labelInstanceIDs(idx));
                    removedLabelInstanceIDs=[removedLabelInstanceIDs;removedLoopLabelInstanceIDs];
                    removedLabelInstanceParentRowIDs=[removedLabelInstanceParentRowIDs;removedLoopLabelInstanceParentRowIDs];
                    removedLabelInstanceLabelDefIDs=[removedLabelInstanceLabelDefIDs;removedLoopLabelInstanceLabelDefIDs];
                end
            end
            if strcmp(this.getAppName(),'autoLabelMode')
                this.updateAutoAddedInstancesInfo(labelInstanceIDs);
            end
            info.removedLabelInstanceIDs=removedLabelInstanceIDs;
            info.removedLabelInstanceParentRowIDs=removedLabelInstanceParentRowIDs;
            info.removedLabelInstanceLabelDefIDs=removedLabelInstanceLabelDefIDs;
            info.removedLabelInstanceMemberID=removedLabelInstanceMemberID;
            info.editedLabelInstanceIDs=editedLabelInstanceIDs;
            info.parentLabelInstanceIDsForEditedLabelInstanceIDs=parentLabelInstanceIDsForEditedLabelInstanceIDs;
            tx.commit;
        end

        function info=deleteLabelInstancesFromModelOnMemberDelete(this,labelData)


            tx=this.Mf0DataModel.beginTransaction;
            removedLabelInstanceIDs=[];
            removedLabelInstanceParentRowIDs=[];
            removedLabelInstanceLabelDefIDs=[];
            removedLabelInstanceMemberID=[];
            editedLabelInstanceIDs=[];
            parentLabelInstanceIDsForEditedLabelInstanceIDs=[];
            labelInstanceIDs=string(labelData.LabelInstanceID);
            for idx=1:numel(labelInstanceIDs)
                lblInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceIDs(idx));
                removedLabelInstanceMemberID=string(lblInstance.memberID);
                [removedLoopLabelInstanceIDs,removedLoopLabelInstanceParentRowIDs,removedLoopLabelInstanceLabelDefIDs]=removeInstanceLabelDestroyChildren(this,lblInstance,labelInstanceIDs(idx));
                removedLabelInstanceIDs=[removedLabelInstanceIDs;removedLoopLabelInstanceIDs];
                removedLabelInstanceParentRowIDs=[removedLabelInstanceParentRowIDs;removedLoopLabelInstanceParentRowIDs];
                removedLabelInstanceLabelDefIDs=[removedLabelInstanceLabelDefIDs;removedLoopLabelInstanceLabelDefIDs];

            end
            if strcmp(this.getAppName(),'autoLabelMode')
                this.updateAutoAddedInstancesInfo(labelInstanceIDs);
            end
            info.removedLabelInstanceIDs=removedLabelInstanceIDs;
            info.removedLabelInstanceParentRowIDs=removedLabelInstanceParentRowIDs;
            info.removedLabelInstanceLabelDefIDs=removedLabelInstanceLabelDefIDs;
            info.removedLabelInstanceMemberID=removedLabelInstanceMemberID;
            info.editedLabelInstanceIDs=editedLabelInstanceIDs;
            info.parentLabelInstanceIDsForEditedLabelInstanceIDs=parentLabelInstanceIDsForEditedLabelInstanceIDs;
            tx.commit;
        end

        function[removedLabelInstanceAndChildrenIDs,removedLabelInstanceParentRowIDs,removedLabelInstanceLabelDefIDs]=removeInstanceLabelDestroyChildren(this,lblInstance,labelInstanceIDs)


            removedLabelInstanceAndChildrenIDs=labelInstanceIDs;
            removedLabelInstanceLabelDefIDs=string(lblInstance.labelDefinitionID);

            childrenLblInstanceIDs=getLabelInstanceIDsForParentLabelInstanceID(this,labelInstanceIDs);
            removedChildLabelInstanceParentRowIDs=[];
            for cdx=1:numel(childrenLblInstanceIDs)
                childrenLblInstance=getLabelInstanceFromLabelInstanceID(this,childrenLblInstanceIDs(cdx));
                removedLabelInstanceAndChildrenIDs=[removedLabelInstanceAndChildrenIDs;childrenLblInstanceIDs(cdx)];



                removedChildLabelInstanceParentRowIDs=[removedChildLabelInstanceParentRowIDs;""];
                removedLabelInstanceLabelDefIDs=[removedLabelInstanceLabelDefIDs;string(childrenLblInstance.labelDefinitionID)];


                childrenLblInstance.destroy();
            end


            removedLabelInstanceParentRowID=deleteTreeTableRowInMf0Model(this,labelInstanceIDs);



            removedLabelInstanceParentRowIDs=[removedLabelInstanceParentRowID;removedChildLabelInstanceParentRowIDs];
            lblInstance.destroy();
        end




        function outData=getLabelDefinitionsDataForTree(this,labelDefID)










            lblDef=getLabelDefFromLabelDefID(this,labelDefID);
            outData=struct(...
            'id',labelDefID,...
            'parent',lblDef.parentLabelDefinitionID,...
            'IsFeature',lblDef.isFeature,...
            'LabelName',lblDef.labelDefinitionName,...
            'LabelType',lblDef.labelType);
        end

        function outData=getAllLabelDefinitionsDataForTree(this,excludeLabelDefinitionIDs)









            outData=[];
            lblDefIDs=getAllLabelDefinitionIDs(this);
            if~isempty(excludeLabelDefinitionIDs)
                lblDefIDs=setdiff(lblDefIDs,excludeLabelDefinitionIDs);
            end
            for idx=1:length(lblDefIDs)
                outData=[outData;getLabelDefinitionsDataForTree(this,lblDefIDs(idx))];
            end
        end

        function treeOutData=getLabelDefinitionsDataForTreeOnDelete(~,info)


            removedLabelDefinitionIDs=unique(string(info.removedLabelDefinitionIDs),'stable');
            numLblDefs=numel(removedLabelDefinitionIDs);

            treeOutData=repmat(struct('id','','parent',''),numLblDefs,1);
            for idx=1:numLblDefs
                treeOutData(idx).id=removedLabelDefinitionIDs(idx);
            end
        end




        function rowHierarchyInfo=getRowHierarchyForLabelInstanceID(this,labelInstanceID)

            lblInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceID);
            memberID=lblInstance.memberID;
            lblDefID=lblInstance.labelDefinitionID;
            lblDef=getLabelDefFromLabelDefID(this,lblDefID);
            rowHierarchyInfo.isLabelDefAttribute=lblDef.labelType=="attribute";
            parentLblInstID=lblInstance.parentLabelInstanceID;
            rowHierarchyInfo.memberID=memberID;
            rowHierarchyInfo.isSublabel=~isemptyString(this,parentLblInstID);
            rowHierarchyInfo.parentLabelInstanceID=parentLblInstID;
            rowHierarchyInfo.memberChildrenIDs=[];
            rowHierarchyInfo.lblDefChildrenIDs=[];
            childrenSignalIDs=getSignalChildrenIDs(this,str2double(memberID));
            allParentLblDefIDs=getAllParentLabelDefinitionIDs(this);

            rowHierarchyInfo.memberChildrenIDs=[rowHierarchyInfo.memberChildrenIDs;string(childrenSignalIDs)];
            for ldx=1:numel(allParentLblDefIDs)
                currentLblDef=getLabelDefFromLabelDefID(this,allParentLblDefIDs(ldx));
                if currentLblDef.labelType=="attribute"
                    labelDefHeaderID=getLabelInstaceIDsForLabelDefIDAndMemberID(this,allParentLblDefIDs(ldx),memberID);
                else
                    labelDefHeaderID=getHeaderID(this,allParentLblDefIDs(ldx),memberID);
                end
                if allParentLblDefIDs(ldx)==lblDefID


                    rowHierarchyInfo.labelDefHeaderID=labelDefHeaderID;
                    rowHierarchyInfo.labelDefHeaderIDsIndex=numel(rowHierarchyInfo.memberChildrenIDs)+ldx;
                end
                rowHierarchyInfo.memberChildrenIDs=[rowHierarchyInfo.memberChildrenIDs;labelDefHeaderID];
            end
            if rowHierarchyInfo.isSublabel


                parentLblDef=getParentLabelDefOfLabelDef(this,lblDef);
                rowHierarchyInfo.isParentLabelDefAttribute=parentLblDef.labelType=="attribute";
                childrenLblDefIDs=getChildrenLabelDefIDs(this,parentLblDef);
                childrenLblDefHeaderIDs=[];
                for cIdx=1:numel(childrenLblDefIDs)
                    childrenLblDefID=childrenLblDefIDs(cIdx);
                    childrenlblDef=getLabelDefFromLabelDefID(this,childrenLblDefID);
                    if childrenlblDef.labelType=="attribute"
                        childrenLblDefHeaderID=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,childrenLblDefID,memberID,parentLblInstID);
                    else
                        childrenLblDefHeaderID=getHeaderID(this,childrenLblDefID,memberID,parentLblInstID);
                    end
                    if childrenLblDefID==lblDefID


                        rowHierarchyInfo.labelDefHeaderID=childrenLblDefHeaderID;
                    end
                    childrenLblDefHeaderIDs=[childrenLblDefHeaderIDs;childrenLblDefHeaderID];
                end
                if rowHierarchyInfo.isParentLabelDefAttribute


                    rowHierarchyInfo.parentLabelDefHeaderID=parentLblInstID;
                    rowHierarchyInfo.parentLblDefHeaderChildrenIDs=childrenLblDefHeaderIDs;
                else



                    rowHierarchyInfo.parentLabelDefHeaderID=getHeaderID(this,parentLblDef.labelDefinitionID,memberID);
                    rowHierarchyInfo.parentLblDefHeaderChildrenIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,parentLblDef.labelDefinitionID,memberID);
                    rowHierarchyInfo.parentLblInstChildrenIDs=childrenLblDefHeaderIDs;
                end
            end
            if~rowHierarchyInfo.isLabelDefAttribute


                if rowHierarchyInfo.isSublabel
                    rowHierarchyInfo.labelDefHeaderChildrenIDs=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,childrenLblDefID,memberID,parentLblInstID);
                else
                    rowHierarchyInfo.labelDefHeaderChildrenIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,lblDefID,memberID);
                end
            end
        end


        function[treeTableRow,treeTableParentRow]=getMf0TreeTableRowByIndex(this,rowIdx,parentID)

            rowIdx=rowIdx+1;
            treeTableParentRow=[];
            if parentID=="_INVISIBLE_ROOT_"||parentID==""
                treeTableRow=this.Mf0LabelDataRepository.treeTableRows.at(rowIdx);
            else
                treeTableParentRow=getMf0TreeTableRowByID(this,parentID);
                treeTableRow=treeTableParentRow.childrenRows.at(rowIdx);
            end
        end

        function treeTableRow=getMf0TreeTableRowByID(this,rowID)
            treeTableRow=signallabelereng.datamodel.getTreeTableRowByID(this.Mf0DataModel,rowID);
        end

        function addTreeTableRowForSignalID(this,rowID,parentRow,childRowIdx)
            isMemberSignal=false;
            if nargin==2
                isMemberSignal=true;
                rowID=str2double(rowID);
            end
            rowDataStructForMF0=getTreeTableRowDataStruct(this);
            rowDataStructForMF0.rowID=string(rowID);
            rowDataStructForMF0.rowDataType='signal';
            if isMemberSignal
                createTreeTableRowInMf0Model(this,rowDataStructForMF0);
            else
                rowDataStructForMF0.parentID=parentRow.rowID;
                rowDataStructForMF0.isChecked=parentRow.isChecked;
                rowDataStructForMF0.isExpandAll=parentRow.isExpandAll;
                createTreeTableRowInMf0Model(this,rowDataStructForMF0,parentRow,childRowIdx);
            end
        end

        function addTreeTableRowForLabelDefinitionID(this,labelDefID,memberID,parentInstanceID,parentRow,rowIdx)
            rowDataStructForMF0=getTreeTableRowDataStruct(this);
            labelDef=getLabelDefFromLabelDefID(this,labelDefID);
            rowDataStructForMF0.parentID=parentRow.rowID;
            rowDataStructForMF0.isChecked=parentRow.isChecked;
            rowDataStructForMF0.isExpandAll=parentRow.isExpandAll;
            if labelDef.labelType=="attribute"

                rowDataStructForMF0.rowID=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,labelDefID,memberID,parentInstanceID);
                rowDataStructForMF0.rowDataType='attributeLabelInstance';
            else
                rowDataStructForMF0.rowID=getHeaderID(this,labelDefID,memberID,parentInstanceID);
                rowDataStructForMF0.rowDataType='labelHeader';
            end
            createTreeTableRowInMf0Model(this,rowDataStructForMF0,parentRow,rowIdx);
        end

        function addTreeTableRowForLabelInstances(this,labelInstanceID,parentRow,rowIdx)
            rowDataStructForMF0=getTreeTableRowDataStruct(this);
            rowDataStructForMF0.rowID=labelInstanceID;
            labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceID);
            rowDataStructForMF0.parentID=parentRow.rowID;


            rowDataStructForMF0.isChecked=labelInstance.isPlottedInTimeAxes;
            rowDataStructForMF0.isExpandAll=parentRow.isExpandAll;
            rowDataStructForMF0.rowDataType='labelInstance';
            createTreeTableRowInMf0Model(this,rowDataStructForMF0,parentRow,rowIdx);
        end

        function dataStruct=getTreeTableRowDataStruct(~)


            dataStruct=struct('rowID','',...
            'parentID','',...
            'rowDataType','',...
            'isChecked',false,...
            'isExpanded',false,...
            'isExpandAll',false);
        end

        function createTreeTableRowInMf0Model(this,rowDataStructForMF0,parentRow,childRowIdx)
            if nargin==4
                parentRow.childrenRows.insertAt(...
                signallabelereng.datamodel.TreeTableRow(this.Mf0DataModel,...
                rowDataStructForMF0),childRowIdx);
            else
                this.Mf0LabelDataRepository.createIntoTreeTableRows(rowDataStructForMF0);
            end
        end

        function removedLabelInstanceParentID=deleteTreeTableRowInMf0Model(this,rowID)
            mf0TreeTableRow=getMf0TreeTableRowByID(this,rowID);
            removedLabelInstanceParentID="";

            if~isempty(mf0TreeTableRow)
                removedLabelInstanceParentID=string(mf0TreeTableRow.parentID);
                mf0TreeTableRow.destroy();
            end
        end

        function updateAllTreeTableRowsExpandAllFlag(this,flag)
            tx=this.Mf0DataModel.beginTransaction;
            for idx=1:this.Mf0LabelDataRepository.treeTableRows.Size
                this.Mf0LabelDataRepository.treeTableRows(idx).isExpandAll=flag;
                this.updateTreeTableRowsExpandAllFlagForAllChildrenRows(this.Mf0LabelDataRepository.treeTableRows(idx),flag);
            end

            tx.commit;
        end

        function updateTreeTableRowsExpandAllFlagForAllChildrenRows(this,treeTableRow,flag)
            treeRowChildrenRows=treeTableRow.childrenRows;
            for idx=1:treeRowChildrenRows.Size
                treeRowChildrenRows(idx).isExpandAll=flag;
                if~flag
                    treeRowChildrenRows(idx).isExpanded=flag;
                end
                if treeRowChildrenRows(idx).childrenRows.Size~=0
                    updateTreeTableRowsExpandAllFlagForAllChildrenRows(this,treeRowChildrenRows(idx),flag);
                else
                end
            end
        end

        function treeTableData=getTreeTableDataByRowIdx(this,rowIdx,parentID,lastTableAction,lastActionRowID)





















            [mf0TreeTableRowData,mf0TreeTableParentRow]=getMf0TreeTableRowByIndex(this,rowIdx,parentID);
            treeTableData=getTreeTableDataStruct(this);

            treeTableData.rowID=mf0TreeTableRowData.rowID;
            treeTableData.parentID=mf0TreeTableRowData.parentID;
            treeTableData.rowDataType=mf0TreeTableRowData.rowDataType;
            treeTableData.isChecked=mf0TreeTableRowData.isChecked;
            isUpdateChildrenRowsOfCurrentNodeNeeded=true;
            if lastTableAction=="expandAll"
                mf0TreeTableRowData.isExpandAll=true;
            elseif treeTableData.parentID~=""&&...
                (string(lastActionRowID)==mf0TreeTableParentRow.rowID&&lastTableAction=="expand")


                mf0TreeTableRowData.isExpandAll=false;


                isUpdateChildrenRowsOfCurrentNodeNeeded=mf0TreeTableRowData.isExpanded;
            end
            totalNewChildrenAdded=0;
            totalChildrenRows=0;

            switch mf0TreeTableRowData.rowDataType
            case "signal"

                signalID=str2double(mf0TreeTableRowData.rowID);
                memberID=getMemberIDForSignalID(this,signalID);
                signalObj=getSignalObj(this,signalID);
                tmMode=getSignalTmMode(this,signalObj.ID);


                numChildrenSignal=numel(getSignalChildrenIDs(this,signalID));
                numLabelDef=numel(getAllParentLabelDefinitionIDs(this));
                hasChildrenSignal=numChildrenSignal~=0;
                treeTableData.timeCol="";
                if treeTableData.parentID==""
                    [treeTableData.nameCol,~,~,treeTableData.nameColTooltip]=convertToValidMemberName(this,signalObj.Name,tmMode);
                    treeTableData.hasChildren=hasChildrenSignal||numLabelDef~=0;

                    totalChildrenRows=numChildrenSignal+numLabelDef;


                    totalNewChildrenAdded=updateTreeTableDataForExpandedRows(this,mf0TreeTableRowData,totalChildrenRows);
                    if getAppDataMode(this)~="signalFile"&&~hasChildrenSignal&&tmMode~="samples"
                        treeTableData.timeCol=getSampleRateOrTimeDisplayValue(this,str2double(memberID));
                    end
                else
                    treeTableData.nameCol=signalObj.Name;
                    treeTableData.nameColTooltip=treeTableData.nameCol;
                    treeTableData.hasChildren=hasChildrenSignal;
                    if~hasChildrenSignal&&tmMode~="samples"

                        treeTableData.timeCol=getSampleRateOrTimeDisplayValue(this,signalID);
                    end

                    totalChildrenRows=numChildrenSignal;
                end
                temp=getColorInHex(this,signalObj.ID);
                treeTableData.valueCol=['#',temp(1,:),temp(2,:),temp(3,:)];
            case "labelHeader"
                [memberID,labelDefID]=parseTreeTableRowID(this,mf0TreeTableRowData.rowID,true);
                lblDef=getLabelDefFromLabelDefID(this,labelDefID);
                treeTableData.nameCol=lblDef.labelDefinitionName;
                treeTableData.nameColTooltip=treeTableData.nameCol;

                if isemptyString(this,lblDef.parentLabelDefinitionID)

                    labelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,labelDefID,memberID);
                else

                    labelInstanceIDs=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,labelDefID,memberID,mf0TreeTableRowData.parentID);
                end
                totalChildrenRows=numel(labelInstanceIDs);


                if isUpdateChildrenRowsOfCurrentNodeNeeded
                    totalNewChildrenAdded=updateTreeTableDataForExpandedRows(this,mf0TreeTableRowData,totalChildrenRows);
                end
            case "attributeLabelInstance"
                attLabelInstance=getLabelInstanceFromLabelInstanceID(this,mf0TreeTableRowData.rowID);
                memberID=attLabelInstance.memberID;
                labelDefID=attLabelInstance.labelDefinitionID;
                lblDef=getLabelDefFromLabelDefID(this,labelDefID);
                treeTableData.nameCol=lblDef.labelDefinitionName;
                treeTableData.nameColTooltip=treeTableData.nameCol;
                totalChildrenRows=numel(getChildrenLabelDefIDs(this,lblDef));
                treeTableData.valueCol=attLabelInstance.labelInstanceValue;


                if isUpdateChildrenRowsOfCurrentNodeNeeded
                    totalNewChildrenAdded=updateTreeTableDataForExpandedRows(this,mf0TreeTableRowData,totalChildrenRows);
                end
            case "labelInstance"
                lblInstance=getLabelInstanceFromLabelInstanceID(this,mf0TreeTableRowData.rowID);
                lblDef=getLabelDefFromLabelDefID(this,lblInstance.labelDefinitionID);
                memberID=lblInstance.memberID;
                treeTableData.valueCol=lblInstance.labelInstanceValue;
                treeTableData.tMinCol=string(lblInstance.labelInstanceTimeMin);
                if lblDef.labelType=="roi"
                    treeTableData.tMaxCol=string(lblInstance.labelInstanceTimeMax);
                end
                totalChildrenRows=numel(getChildrenLabelDefIDs(this,lblDef));


                if isUpdateChildrenRowsOfCurrentNodeNeeded
                    totalNewChildrenAdded=updateTreeTableDataForExpandedRows(this,mf0TreeTableRowData,totalChildrenRows);
                end
            end
            treeTableData.isExpanded=mf0TreeTableRowData.isExpanded;
            treeTableData.hasChildren=totalChildrenRows>0;
            treeTableData.totalNewChildrenAdded=totalNewChildrenAdded;
            treeTableData.totalChildrenRows=totalChildrenRows;
            treeTableData.memberID=memberID;
        end

        function totalNewChildrenAdded=updateTreeTableDataForExpandedRows(this,mf0TreeTableRowData,totalChildrenRows)



            totalNewChildrenAdded=0;


            if(mf0TreeTableRowData.isExpandAll&&~mf0TreeTableRowData.isExpanded)...
                ||(mf0TreeTableRowData.isExpanded&&totalChildrenRows~=mf0TreeTableRowData.childrenRows.Size)
                totalNewChildrenAdded=totalChildrenRows-mf0TreeTableRowData.childrenRows.Size;
                updateTreeTableDataOnExpandCollapse(this,mf0TreeTableRowData);
            end
        end

        function treeTableRow=updateTreeTableRowMetaData(this,rowIdx,parentID,type,value)


            tx=this.Mf0DataModel.beginTransaction;
            treeTableRow=getMf0TreeTableRowByIndex(this,rowIdx,parentID);
            switch type
            case "isChecked"
                treeTableRow.isChecked=value;
            case "isExpanded"
                treeTableRow.isExpanded=value;
            otherwise
            end
            tx.commit;
        end

        function updateTreeTableRowMetaDataByID(this,rowIDs,labelInstanceRowIDs,value)
            tx=this.Mf0DataModel.beginTransaction;
            for idx=1:numel(rowIDs)
                treeTableRow=signallabelereng.datamodel.getTreeTableRowByID(this.Mf0DataModel,rowIDs(idx));
                if~isempty(treeTableRow)
                    treeTableRow.isChecked=value;
                end
            end
            for idx=1:numel(labelInstanceRowIDs)
                treeTableRow=signallabelereng.datamodel.getTreeTableRowByID(this.Mf0DataModel,labelInstanceRowIDs(idx));
                if~isempty(treeTableRow)
                    treeTableRow.isChecked=value;
                else


                    labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceRowIDs(idx));
                    labelInstance.isPlottedInTimeAxes=value;
                end
            end
            tx.commit;
        end

        function flag=isAddRowForChildrenSignalNeeded(~,childrenSignalIDs,parentRow,rowIdx)
            flag=true;
            if parentRow.childrenRows.Size>=rowIdx
                mf0TreeTableRowData=parentRow.childrenRows.at(rowIdx);
                flag=mf0TreeTableRowData.rowID~=string(childrenSignalIDs(rowIdx));
            end
        end

        function flag=isAddRowForLabelDefinitionNeeded(this,labelDefID,memberID,parentInstanceID)
            labelDef=getLabelDefFromLabelDefID(this,labelDefID);
            if labelDef.labelType=="attribute"

                labelDefRowID=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,labelDefID,memberID,parentInstanceID);
            else
                labelDefRowID=getHeaderID(this,labelDefID,memberID,parentInstanceID);
            end
            treeTableRowData=signallabelereng.datamodel.getTreeTableRowByID(this.Mf0DataModel,labelDefRowID);
            flag=isempty(treeTableRowData);
        end

        function info=updateTreeTableDataOnExpandCollapse(this,rowIdxOrData,parentID,isExpanded)
            tx=this.Mf0DataModel.beginTransaction;
            info.numOfRows=0;
            if nargin==2
                mf0TreeTableRowData=rowIdxOrData;
                isExpanded=true;
            else
                mf0TreeTableRowData=getMf0TreeTableRowByIndex(this,rowIdxOrData,parentID);


                mf0TreeTableRowData.isExpandAll=false;
            end
            if isExpanded
                switch mf0TreeTableRowData.rowDataType
                case "signal"
                    isMemberSignal=mf0TreeTableRowData.parentID=="";
                    signalID=str2double(mf0TreeTableRowData.rowID);
                    if isMemberSignal

                        memberID=mf0TreeTableRowData.rowID;
                    else
                        memberID=getMemberIDForSignalID(this,signalID);
                    end

                    signalChildrenIDs=getSignalChildrenIDs(this,signalID);
                    numSignalChildrenIDs=numel(signalChildrenIDs);
                    info.numOfRows=numSignalChildrenIDs;

                    isAddRowForChildrenSignal=false;
                    for cIdx=1:numSignalChildrenIDs




                        isAddRowForChildrenSignal=isAddRowForChildrenSignal||...
                        (cIdx==1&&isAddRowForChildrenSignalNeeded(this,signalChildrenIDs,mf0TreeTableRowData,cIdx));
                        if isAddRowForChildrenSignal
                            addTreeTableRowForSignalID(this,signalChildrenIDs(cIdx),mf0TreeTableRowData,cIdx);
                        end
                    end
                    if isMemberSignal

                        labelDefIDs=getAllParentLabelDefinitionIDs(this);
                        numLabelDefIDs=numel(labelDefIDs);
                        for lIdx=1:numLabelDefIDs


                            isAddRowForLabelDefinition=isAddRowForLabelDefinitionNeeded(this,labelDefIDs(lIdx),memberID,'');
                            if isAddRowForLabelDefinition
                                addTreeTableRowForLabelDefinitionID(this,labelDefIDs(lIdx),memberID,'',mf0TreeTableRowData,numSignalChildrenIDs+lIdx);
                            end
                        end
                        info.numOfRows=info.numOfRows+numel(labelDefIDs);
                    end
                case "labelHeader"
                    [memberID,labelDefID]=parseTreeTableRowID(this,mf0TreeTableRowData.rowID,true);
                    lblDef=getLabelDefFromLabelDefID(this,labelDefID);
                    if isemptyString(this,lblDef.parentLabelDefinitionID)

                        labelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,labelDefID,memberID);
                    else

                        labelInstanceIDs=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,labelDefID,memberID,mf0TreeTableRowData.parentID);
                    end


                    totalChildRows=numel(labelInstanceIDs);



                    startIdxForChildRows=mf0TreeTableRowData.childrenRows.Size;
                    if startIdxForChildRows<totalChildRows
                        for lIdx=startIdxForChildRows+1:totalChildRows
                            addTreeTableRowForLabelInstances(this,labelInstanceIDs(lIdx),mf0TreeTableRowData,lIdx);
                        end
                    end
                    info.numOfRows=totalChildRows;
                case{"labelInstance","attributeLabelInstance"}
                    lblInstance=getLabelInstanceFromLabelInstanceID(this,mf0TreeTableRowData.rowID);
                    lblDef=getLabelDefFromLabelDefID(this,lblInstance.labelDefinitionID);
                    memberID=lblInstance.memberID;

                    childrenLabelDefIDs=getChildrenLabelDefIDs(this,lblDef);
                    numChildLabelDefIDs=numel(childrenLabelDefIDs);
                    for lIdx=1:numChildLabelDefIDs


                        isAddRowForLabelDefinition=isAddRowForLabelDefinitionNeeded(this,childrenLabelDefIDs(lIdx),memberID,lblInstance.labelInstanceID);
                        if isAddRowForLabelDefinition
                            addTreeTableRowForLabelDefinitionID(this,childrenLabelDefIDs(lIdx),memberID,lblInstance.labelInstanceID,mf0TreeTableRowData,lIdx);
                        end
                    end
                    info.numOfRows=numChildLabelDefIDs;
                end
            end
            mf0TreeTableRowData.isExpanded=isExpanded;
            tx.commit;
        end








        function axesData=getLabelDefinitionsDataForAxes(this,labelDefID,info,checkedMemberIDs)





















            if nargin<4
                checkedSignalIDs=this.CheckedSignalIDs;
                numCheckedSignals=numel(checkedSignalIDs);
                if numCheckedSignals==0
                    axesData=[];
                    return;
                end
                memberIDsForCheckedSignals=getMemberIDForSignalID(this,checkedSignalIDs);
                memberIDs=unique(memberIDsForCheckedSignals,'stable');
            else
                memberIDs=string(checkedMemberIDs);
            end
            lblDef=getLabelDefFromLabelDefID(this,labelDefID);
            [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
            parentLabelDefinitionName=parentLblDef.labelDefinitionName;
            parentLabelDefID=parentLblDef.labelDefinitionID;
            axesDataStruct=getAxesDataStruct(this);




            axesData=repmat(axesDataStruct,numel(memberIDs),1);
            if lblDef.labelType=="attribute"&&nargin>2&&~isempty(info)






                for idx=1:numel(memberIDs)
                    memberID=memberIDs(idx);
                    signalID=getFirstMemberSignal(this,memberID);
                    axesData(idx).MemberID=memberID;
                    axesData(idx).SignalID=signalID;
                    axesData(idx).ParentLabelDefinitionID=parentLabelDefID;
                    axesData(idx).ParentLabelDefinitionName=parentLabelDefinitionName;
                    axesData(idx).LabelDefinitionID=labelDefID;
                    axesData(idx).LabelDefinitionName=lblDef.labelDefinitionName;
                    axesData(idx).LabelType=lblDef.labelType;
                    axesData(idx).LabelDataType=lblDef.labelDataType;
                    if lblDef.labelDataType=="categorical"
                        axesData(idx).LabelDataCategories=lblDef.categories;
                    end
                    axesData(idx).isSublabel=isSublabel;
                    if this.getAppName()=="featureExtractionMode"
                        axesData(idx).isEditable=false;
                    end
                    if~isempty(info.newAttrLabelInstanceIDs)
                        labelInstanceIDIndex=(info.newAttrLabelInstanceMemberIDs==memberID);
                        if any(labelInstanceIDIndex)
                            labelInstanceIDs=info.newAttrLabelInstanceIDs(labelInstanceIDIndex);
                            parentLabelInstanceIDs=info.newAttrParentLabelInstanceIDs(labelInstanceIDIndex);
                            labelInstanceValues=info.newAttrLabelInstanceValues(labelInstanceIDIndex);
                            axesData(idx).ParentLabelInstanceIDs=parentLabelInstanceIDs;
                            axesData(idx).LabelInstanceIDs=labelInstanceIDs;
                            axesData(idx).LabelInstanceValues=formatValueForClient(this,labelInstanceValues,lblDef.labelDataType);
                            axesData(idx).LabelInstanceTimeMinValues=NaN(numel(labelInstanceIDs),1);
                            axesData(idx).LabelInstanceTimeMaxValues=NaN(numel(labelInstanceIDs),1);
                        end
                    end
                end
            else
                for idx=1:numel(memberIDs)
                    memberID=memberIDs(idx);
                    signalID=getFirstMemberSignal(this,memberID);
                    axesData(idx).MemberID=memberID;
                    axesData(idx).SignalID=signalID;
                    axesData(idx).ParentLabelDefinitionID=parentLabelDefID;
                    axesData(idx).ParentLabelDefinitionName=parentLabelDefinitionName;
                    axesData(idx).LabelDefinitionID=labelDefID;
                    axesData(idx).LabelDefinitionName=lblDef.labelDefinitionName;
                    axesData(idx).LabelType=lblDef.labelType;
                    axesData(idx).isSublabel=isSublabel;
                    if this.getAppName()=="featureExtractionMode"
                        axesData(idx).isEditable=false;
                    end
                end
            end
        end

        function axesOutData=getLabelDefinitionsDataForAxesOnDelete(this,labelDefID,info,checkedMemberIDs)%#ok<INUSL>

            axesOutData=[];
            if nargin<4

                checkedSignalIDs=this.CheckedSignalIDs;
                numCheckedSignals=numel(checkedSignalIDs);
                if numCheckedSignals==0
                    return;
                end
                memberIDsForCheckedSignals=getMemberIDForSignalID(this,checkedSignalIDs);
                memberIDs=unique(memberIDsForCheckedSignals,'stable');
            else
                memberIDs=string(checkedMemberIDs);
            end

            axesDataStruct=getAxesDataStruct(this);






            labelDefIDs=unique(info.removedLabelDefinitionIDs,'stable');
            for memberIDx=1:numel(memberIDs)
                memberID=memberIDs(memberIDx);
                for lblDefIDx=1:numel(labelDefIDs)
                    axesOutTmp=axesDataStruct;
                    currentLabelDefID=labelDefIDs(lblDefIDx);
                    labelDefIDIndex=info.removedLabelDefinitionIDs==currentLabelDefID;
                    removedLabelDefinitionParentIDs=info.removedLabelDefinitionParentIDs(labelDefIDIndex);
                    removedLabelDefinitionParentNames=info.removedLabelDefinitionParentNames(labelDefIDIndex);
                    removedLabelDefinitionNames=info.removedLabelDefinitionNames(labelDefIDIndex);
                    removedLabelDefinitionTypes=info.removedLabelDefinitionTypes(labelDefIDIndex);
                    labelInstanceIDIndex=(info.removedLabelInstanceMemberIDs==memberID)&labelDefIDIndex;
                    parentLabelDefID=removedLabelDefinitionParentIDs(1);
                    isSublabel=~isemptyString(this,parentLabelDefID);
                    axesOutTmp.MemberID=memberID;
                    axesOutTmp.SignalID=getFirstMemberSignal(this,memberID);
                    axesOutTmp.ParentLabelDefinitionID=parentLabelDefID;
                    axesOutTmp.ParentLabelDefinitionName=removedLabelDefinitionParentNames(1);
                    axesOutTmp.LabelDefinitionID=currentLabelDefID;
                    axesOutTmp.LabelDefinitionName=removedLabelDefinitionNames(1);
                    axesOutTmp.LabelType=removedLabelDefinitionTypes(1);
                    axesOutTmp.isSublabel=isSublabel;
                    if any(labelInstanceIDIndex)&&~isempty(info.removedLabelInstanceIDs)
                        labelInstanceIDs=info.removedLabelInstanceIDs(labelInstanceIDIndex);
                        parentLabelInstanceIDs=info.parentLabelInstanceIDs(labelInstanceIDIndex);
                        axesOutTmp.ParentLabelInstanceIDs=parentLabelInstanceIDs;
                        axesOutTmp.LabelInstanceIDs=labelInstanceIDs;
                    end
                    axesOutData=[axesOutData;axesOutTmp];
                end
            end
        end




        function outData=getLabelDefinitionsData(this,data)




















            labelDefID=data.id;
            lblDef=getLabelDefFromLabelDefID(this,labelDefID);
            [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
            parentLabelDefID=parentLblDef.labelDefinitionID;
            parentLabelDefName=parentLblDef.labelDefinitionName;
            outData=struct(...
            'LabelName',lblDef.labelDefinitionName,...
            'LabelDefinitionName',lblDef.labelDefinitionName,...
            'IsFeature',lblDef.isFeature,...
            'FramePolicyType',lblDef.framePolicyType,...
            'FrameSize',lblDef.frameSize,...
            'FrameRateOrOverlapLength',lblDef.frameRateOrOverlapLength,...
            'LabelDefinitionID',labelDefID,...
            'ParentLabelDefinitionID',parentLabelDefID,...
            'ParentLabelName',parentLabelDefName,...
            'ParentLabelDefinitionName',parentLabelDefName,...
            'LabelType',lblDef.labelType,...
            'LabelDescription',lblDef.description,...
            'LabelDataType',lblDef.labelDataType,...
            'isSublabel',isSublabel,...
            'LabelDataCategories',string(lblDef.categories),...
            'LabelDataDefaultValue',lblDef.defaultValue);
        end




        function[successFlag,isShowIncompatibleLabelWarning]=addImportedSignalsAndLabelsToRepository(this,nonLSSMemberIDs,lss,lssMemberIDs)



            successFlag=true;
            isShowIncompatibleLabelWarning=false;
            mf0LabelDataStruct=getMf0LabelDataStruct(this);
            if~isempty(lss)
                [successFlag,isShowIncompatibleLabelWarning]=copyLSSLabelsToMf0Model(this,lss,lssMemberIDs);
            end


            tx=this.Mf0DataModel.beginTransaction;
            labelDefIDs=getAllParentLabelDefinitionIDs(this);
            attributeLabelDefs=[];



            for ldx=1:numel(labelDefIDs)
                lblDef=getLabelDefFromLabelDefID(this,labelDefIDs(ldx));
                if lblDef.labelType=="attribute"


                    attributeLabelDefs=[attributeLabelDefs;lblDef];
                end
            end

            for memIdx=1:numel(nonLSSMemberIDs)
                currentMemberID=string(nonLSSMemberIDs(memIdx));
                addTreeTableRowForSignalID(this,currentMemberID);


                for ldx=1:numel(attributeLabelDefs)
                    lblDef=attributeLabelDefs(ldx);
                    labelValue="";
                    if~isempty(lblDef.defaultValue)
                        labelValue=lblDef.defaultValue;
                    end
                    labelData=struct('LabelDefinitionID',attributeLabelDefs(ldx).labelDefinitionID,...
                    'LabelValue',labelValue,...
                    'ParentLabelInstanceID',"");

                    addLabelInstance(this,currentMemberID,labelData,true,false,lblDef,mf0LabelDataStruct);
                end
            end
            tx.commit;
        end

        function[successFlag,isShowIncompatibleLabelWarning]=copyLSSLabelsToMf0Model(this,lss,lssMemberIDs)



            successFlag=true;
            isShowIncompatibleLabelWarning=false;
            lblDefs=lss.getLabelDefinitions();
            memberIDs=string(lssMemberIDs);
            mf0LabelDataStruct=getMf0LabelDataStruct(this);
            mf0ChildLabelDataStruct=mf0LabelDataStruct;
            tx=this.Mf0DataModel.beginTransaction;
            for memIdx=1:numel(memberIDs)
                currentMemberID=memberIDs(memIdx);
                mf0LabelDataStruct.memberID=currentMemberID;
                mf0ChildLabelDataStruct.memberID=currentMemberID;
                addTreeTableRowForSignalID(this,currentMemberID);
                for jdx=1:numel(lblDefs)
                    currentLblDef=lblDefs(jdx);
                    mf0LblDef=getParentLabelDefinitionFromLabelDefName(this,currentLblDef.Name);
                    lblInstancesData=lss.getLabelValues(memIdx,currentLblDef.Name);
                    if mf0LblDef.labelType=="attribute"
                        numOfLbls=1;
                    else
                        if isempty(lblInstancesData)

                            continue;
                        else
                            numOfLbls=height(lblInstancesData);
                        end
                    end
                    mf0ChildrenLblDefIDs=getChildrenLabelDefIDs(this,mf0LblDef);
                    mf0LabelDataStruct.labelDefinitionID=mf0LblDef.labelDefinitionID;
                    mf0LabelDataStruct.labelInstanceTimeMin=[];
                    mf0LabelDataStruct.labelInstanceTimeMax=[];
                    for lblIdx=1:numOfLbls
                        isParentAttribute=false;
                        if mf0LblDef.labelType=="attribute"
                            currentLabelInstanceValue=lblInstancesData;
                            if numel(currentLabelInstanceValue)>1||...
                                (mf0LblDef.labelDataType=="numeric"&&...
                                ~isreal(currentLabelInstanceValue))



                                isShowIncompatibleLabelWarning=true;
                                mf0LabelDataStruct.labelInstanceValue='';
                            else
                                mf0LabelDataStruct.labelInstanceValue=formatValueForClient(this,...
                                currentLabelInstanceValue,...
                                mf0LblDef.labelDataType,...
                                true);
                            end
                            isParentAttribute=true;
                        elseif string(mf0LblDef.labelType)=="point"
                            if iscell(lblInstancesData.Value)
                                currentLabelInstanceValue=lblInstancesData.Value{lblIdx};
                            else
                                currentLabelInstanceValue=lblInstancesData.Value(lblIdx);
                            end
                            if numel(currentLabelInstanceValue)>1||...
                                (mf0LblDef.labelDataType=="numeric"&&...
                                ~isreal(currentLabelInstanceValue))



                                isShowIncompatibleLabelWarning=true;
                                continue;
                            end
                            mf0LabelDataStruct.labelInstanceValue=formatValueForClient(this,...
                            currentLabelInstanceValue,...
                            mf0LblDef.labelDataType,...
                            true);
                            location=lblInstancesData.Location(lblIdx);
                            if isduration(location)
                                location=seconds(location);
                            end
                            mf0LabelDataStruct.labelInstanceTimeMin=location;
                        elseif mf0LblDef.labelType=="roi"
                            if iscell(lblInstancesData.Value)
                                currentLabelInstanceValue=lblInstancesData.Value{lblIdx};
                            else
                                currentLabelInstanceValue=lblInstancesData.Value(lblIdx);
                            end
                            if numel(currentLabelInstanceValue)>1||...
                                (mf0LblDef.labelDataType=="numeric"&&...
                                ~isreal(currentLabelInstanceValue))



                                isShowIncompatibleLabelWarning=true;
                                continue;
                            end
                            mf0LabelDataStruct.labelInstanceValue=formatValueForClient(this,...
                            currentLabelInstanceValue,...
                            mf0LblDef.labelDataType,...
                            true);
                            roiLimits=lblInstancesData.ROILimits(lblIdx,:);
                            if isduration(roiLimits)
                                roiLimits=seconds(roiLimits);
                            end
                            mf0LabelDataStruct.labelInstanceTimeMin=roiLimits(1);
                            mf0LabelDataStruct.labelInstanceTimeMax=roiLimits(2);
                        end

                        labelInstanceID=this.createInstanceInMf0Model(mf0LabelDataStruct);
                        for clblIdx=1:numel(mf0ChildrenLblDefIDs)
                            mf0CurrentChildLblDef=getLabelDefFromLabelDefID(this,mf0ChildrenLblDefIDs(clblIdx));
                            mf0ChildLabelDataStruct.labelDefinitionID=mf0CurrentChildLblDef.labelDefinitionID;
                            mf0ChildLabelDataStruct.labelInstanceTimeMin=[];
                            mf0ChildLabelDataStruct.labelInstanceTimeMax=[];
                            childLblInstancesData=lss.getLabelValues(memIdx,[currentLblDef.Name,mf0CurrentChildLblDef.labelDefinitionName]);
                            if mf0CurrentChildLblDef.labelType=="attribute"
                                if isParentAttribute||numOfLbls==1
                                    numOfChildLbls=1;
                                    currentParentChildLblInstancesData=childLblInstancesData;
                                elseif iscell(childLblInstancesData)

                                    numOfChildLbls=1;
                                    currentParentChildLblInstancesData=childLblInstancesData{lblIdx};
                                else

                                    numOfChildLbls=1;
                                    currentParentChildLblInstancesData=childLblInstancesData(lblIdx);
                                end
                            else
                                if isParentAttribute||numOfLbls==1
                                    currentParentChildLblInstancesData=childLblInstancesData;
                                else

                                    currentParentChildLblInstancesData=childLblInstancesData{lblIdx};
                                end
                                if isempty(currentParentChildLblInstancesData)

                                    continue;
                                end
                                numOfChildLbls=height(currentParentChildLblInstancesData);
                            end
                            mf0ChildLabelDataStruct.parentLabelInstanceID=labelInstanceID;
                            for sIdx=1:numOfChildLbls
                                if mf0CurrentChildLblDef.labelType=="attribute"
                                    if numel(currentParentChildLblInstancesData)>1||...
                                        (mf0CurrentChildLblDef.labelDataType=="numeric"&&...
                                        ~isreal(currentParentChildLblInstancesData))


                                        isShowIncompatibleLabelWarning=true;
                                        continue;
                                    end
                                    mf0ChildLabelDataStruct.labelInstanceValue=formatValueForClient(this,...
                                    currentParentChildLblInstancesData,...
                                    mf0CurrentChildLblDef.labelDataType,...
                                    true);
                                elseif mf0CurrentChildLblDef.labelType=="point"
                                    if iscell(currentParentChildLblInstancesData.Value)
                                        currentChildLabelInstanceValue=currentParentChildLblInstancesData.Value{sIdx};
                                    else
                                        currentChildLabelInstanceValue=currentParentChildLblInstancesData.Value(sIdx);
                                    end
                                    if numel(currentChildLabelInstanceValue)>1||...
                                        (mf0CurrentChildLblDef.labelDataType=="numeric"&&...
                                        ~isreal(currentChildLabelInstanceValue))


                                        isShowIncompatibleLabelWarning=true;
                                        continue;
                                    end
                                    mf0ChildLabelDataStruct.labelInstanceValue=formatValueForClient(this,...
                                    currentChildLabelInstanceValue,...
                                    mf0CurrentChildLblDef.labelDataType,...
                                    true);
                                    location=currentParentChildLblInstancesData.Location(sIdx);
                                    if isduration(location)
                                        location=seconds(location);
                                    end
                                    mf0ChildLabelDataStruct.labelInstanceTimeMin=location;
                                elseif mf0CurrentChildLblDef.labelType=="roi"
                                    if iscell(currentParentChildLblInstancesData.Value)
                                        currentChildLabelInstanceValue=currentParentChildLblInstancesData.Value{sIdx};
                                    else
                                        currentChildLabelInstanceValue=currentParentChildLblInstancesData.Value(sIdx);
                                    end

                                    if numel(currentChildLabelInstanceValue)>1||...
                                        (mf0CurrentChildLblDef.labelDataType=="numeric"&&...
                                        ~isreal(currentChildLabelInstanceValue))


                                        isShowIncompatibleLabelWarning=true;
                                        continue;
                                    end
                                    mf0ChildLabelDataStruct.labelInstanceValue=formatValueForClient(this,...
                                    currentChildLabelInstanceValue,...
                                    mf0CurrentChildLblDef.labelDataType,...
                                    true);
                                    roiLimits=currentParentChildLblInstancesData.ROILimits(sIdx,:);
                                    if isduration(roiLimits)
                                        roiLimits=seconds(roiLimits);
                                    end
                                    mf0ChildLabelDataStruct.labelInstanceTimeMin=roiLimits(1);
                                    mf0ChildLabelDataStruct.labelInstanceTimeMax=roiLimits(2);
                                end

                                this.createInstanceInMf0Model(mf0ChildLabelDataStruct);
                            end
                        end
                    end
                end
            end
            tx.commit;
        end

        function copyMf0ModelLabelsToLSS(this,LSSIn)



            memberIDs=string(this.getMemberIDs());
            lblDefIDs=getAllParentLabelDefinitionIDs(this);
            for idx=1:numel(lblDefIDs)
                mf0LabelDef=getLabelDefFromLabelDefID(this,lblDefIDs(idx));
                signalLabelDef=convertToSignalLabelDefinition(this,mf0LabelDef,true);
                addLabelDefinitions(LSSIn,signalLabelDef);
                for mdx=1:numel(memberIDs)
                    labelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,lblDefIDs(idx),memberIDs(mdx));
                    for ldx=1:numel(labelInstanceIDs)
                        labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceIDs(ldx));
                        value=formatValueForLSS(this,labelInstance.labelInstanceValue,signalLabelDef.LabelDataType);

                        if~isempty(value)
                            args={};
                            if mf0LabelDef.labelType=="point"
                                args{end+1}=labelInstance.labelInstanceTimeMin;
                            elseif mf0LabelDef.labelType=="roi"
                                args{end+1}=[labelInstance.labelInstanceTimeMin,labelInstance.labelInstanceTimeMax];
                            end
                            args{end+1}=value;
                            setLabelValue(LSSIn,mdx,signalLabelDef.Name,args{:});
                        end
                        childLblDefIDs=getChildrenLabelDefIDs(this,mf0LabelDef);
                        for cIdx=1:numel(childLblDefIDs)
                            mf0sLabelDef=getLabelDefFromLabelDefID(this,childLblDefIDs(cIdx));
                            slabelInstanceIDs=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,childLblDefIDs(cIdx),memberIDs(mdx),labelInstanceIDs(ldx));
                            for slIdx=1:numel(slabelInstanceIDs)
                                slabelInstance=getLabelInstanceFromLabelInstanceID(this,slabelInstanceIDs(slIdx));
                                value=formatValueForLSS(this,slabelInstance.labelInstanceValue,mf0sLabelDef.labelDataType);

                                if~isempty(value)
                                    args={};
                                    if mf0sLabelDef.labelType=="point"
                                        args{end+1}=slabelInstance.labelInstanceTimeMin;
                                    elseif mf0sLabelDef.labelType=="roi"
                                        args{end+1}=[slabelInstance.labelInstanceTimeMin,slabelInstance.labelInstanceTimeMax];
                                    end
                                    args{end+1}=value;
                                    if mf0LabelDef.labelType~="attribute"
                                        args{end+1}="LabelRowIndex";
                                        args{end+1}=ldx;
                                    end
                                    setLabelValue(LSSIn,mdx,[string(mf0LabelDef.labelDefinitionName),string(mf0sLabelDef.labelDefinitionName)],args{:});
                                end
                            end
                        end
                    end
                end
            end
        end

        function[successFlag,exceptionKeyword,outData]=getSignalChildren(this,parentIDs,isLazyLoadingChildernSignal)














            successFlag=true;
            exceptionKeyword='';
            outData=[];

            sigStruct=getTreeTableDataStruct(this);

            for sig_idx=1:length(parentIDs)

                currentID=str2double(parentIDs{sig_idx});


                signalIDs=this.getSignalChildrenIDs(currentID);
                if isLazyLoadingChildernSignal



                    signalIDs=signalIDs(end:-1:1);
                    sigStruct.rowPlacement='first';
                end
                sigData=repmat(sigStruct,length(signalIDs),1);
                for child_idx=1:length(signalIDs)
                    signalObj=Simulink.sdi.getSignal(signalIDs(child_idx));
                    sigData(child_idx).id=num2str(signalObj.ID);
                    sigData(child_idx).parent=num2str(currentID);
                    sigData(child_idx).SignalID=signalObj.ID;
                    sigData(child_idx).MemberID=int32(str2double(getMemberIDForSignalID(this,signalObj.ID)));
                    [~,sigName]=Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(signalObj.Name);
                    sigData(child_idx).col1=sigName;
                    temp=dec2hex(signal.sigappsshared.SignalUtilities.getAvgColorOfChildren(this.Engine,signalIDs(child_idx)));
                    sigData(child_idx).col2=['#',temp(1,:),temp(2,:),temp(3,:)];
                    sigData(child_idx).col3='';
                    sigData(child_idx).col4='';
                    childIDs=this.Engine.getSignalChildren(signalIDs(child_idx));
                    if isempty(childIDs)
                        sigData(child_idx).hasChildren=false;
                        sigData(child_idx).rowDataType='signal';

                        sigData(child_idx).col5=this.getSampleRateOrTimeDisplayValue(signalIDs(child_idx));
                    else
                        sigData(child_idx).hasChildren=true;
                        sigData(child_idx).rowDataType='signalHeader';
                    end
                end
                outData=[outData;sigData];
            end
        end

        function childrenIDs=getAllSignalChildrenIDs(this,parentID)
            childrenIDs=signal.sigappsshared.SignalUtilities.recurseGetAllChildren(this.Engine,parentID);
            childrenIDs=childrenIDs(:);
        end

        function parentIDs=getAllSignalParentIDs(this,childrenID)
            parentIDs=signal.sigappsshared.SignalUtilities.recurseGetAllParents(this.Engine,childrenID);
            parentIDs=parentIDs(:);
        end

        function childrenIDs=getAllSignalLeafChildrenIDs(this,parentID)

            childrenIDs=signal.sigappsshared.SignalUtilities.recurseGetAllLeafChildren(this.Engine,parentID);
            childrenIDs=childrenIDs(:);
            numChildrenIDs=numel(childrenIDs);
            realSigIdx=true(numChildrenIDs,1);
            for idx=1:numChildrenIDs
                [isComplex,isImagPart]=isSignalHasComplexData(this,childrenIDs(idx));
                if~isComplex

                    return;
                end
                if isImagPart
                    realSigIdx(idx)=false;
                end
            end
            childrenIDs=childrenIDs(realSigIdx);
        end

        function childrenIDs=getSignalChildrenIDs(this,parentID,isGetAllChildIDsForComplex)





            if nargin==2
                isGetAllChildIDsForComplex=false;
            end
            childrenIDs=[];
            sigChildrenIDs=this.Engine.getSignalChildren(parentID);
            numSigChildrenIDs=numel(sigChildrenIDs);
            if isGetAllChildIDsForComplex
                childrenIDs=sigChildrenIDs;
                return;
            end
            for cdx=1:numSigChildrenIDs
                [isComplex,IsImagPart]=isSignalHasComplexData(this,sigChildrenIDs(cdx));
                if~isComplex
                    childrenIDs=[childrenIDs;sigChildrenIDs(cdx)];
                    continue;
                end

                complexSigChildrenIDs=this.Engine.getSignalChildren(sigChildrenIDs(cdx));
                if isempty(complexSigChildrenIDs)&&~IsImagPart
                    childrenIDs=[childrenIDs;sigChildrenIDs(cdx)];
                elseif~isempty(complexSigChildrenIDs)


                    childrenIDs=[childrenIDs;complexSigChildrenIDs(1)];
                end
            end
        end

        function[isComplex,isImagPart]=isSignalHasComplexData(this,sigID)



            signalComplexityAndLeafPath=this.Engine.sigRepository.getSignalComplexityAndLeafPath(sigID);
            isComplex=signalComplexityAndLeafPath.IsComplex;
            isImagPart=signalComplexityAndLeafPath.IsImagPart;
        end

        function isHasChildrenSignal=isHasChildrenSignal(this,parentID,tmMode)
            isHasChildrenSignal=false;
            if nargin==3

                isHasChildrenSignal=tmMode=="inherentTimetable";
            end
            if~isHasChildrenSignal
                sigChildrenIDs=this.getSignalChildrenIDs(parentID);
                isHasChildrenSignal=~isempty(sigChildrenIDs);
            end
        end



        function makeAllSignalColorsSameAsTheirParents(this)
            memberIDs=this.getMemberIDs();
            for idx=1:length(memberIDs)
                this.makeSignalColorsSameAsGivenParent(memberIDs(idx));
            end
        end


        function makeSignalColorsSameAsGivenParent(this,memberID)
            rgb=this.Engine.getSignalLineColor(memberID);
            childSignalIDs=this.getAllSignalChildrenIDs(memberID);
            for jdx=1:length(childSignalIDs)
                this.Engine.setSignalLineColor(childSignalIDs(jdx),rgb);
            end
        end


        function makeAllSignalColorsSameAcrossMembers(this)
            memberIDs=this.getMemberIDs();
            for idx=1:length(memberIDs)
                this.makeSignalColorsSameAcrossMember(memberIDs(idx));
            end
        end



        function makeSignalColorsSameAcrossMember(this,memberID)
            colorIndexAcrossAllMembers=1;
            childSignalIDs=this.getAllSignalLeafChildrenIDs(memberID);
            baseColors=signal.sigappsshared.Utilities.getBaseColors();
            baseColorsSize=length(baseColors);
            for jdx=1:length(childSignalIDs)
                color=cell2mat(baseColors(colorIndexAcrossAllMembers));
                this.Engine.setSignalLineColor(childSignalIDs(jdx),color);
                if colorIndexAcrossAllMembers==baseColorsSize
                    colorIndexAcrossAllMembers=1;
                else
                    colorIndexAcrossAllMembers=1+colorIndexAcrossAllMembers;
                end
            end
        end



        function makeAllSignalColorsDifferentFromTheirParents(this)
            memberIDs=this.getMemberIDs();
            for idx=1:length(memberIDs)
                this.makeSignalColorsDifferentFromGivenParent(memberIDs(idx));
            end
        end


        function makeSignalColorsDifferentFromGivenParent(this,memberID)
            childSignalIDs=this.getAllSignalChildrenIDs(memberID);
            baseColors=signal.sigappsshared.Utilities.getBaseColors();
            for jdx=1:length(childSignalIDs)
                color=cell2mat(baseColors(this.SignalIDColorIndex));
                this.Engine.setSignalLineColor(childSignalIDs(jdx),color);
                this.updateColorIndex();
            end
        end


        function makeAllMemberColorsInOrderWhileImport(this,memberID)
            baseColors=signal.sigappsshared.Utilities.getBaseColors();
            color=cell2mat(baseColors(this.MemberIDColorIndex));
            this.Engine.setSignalLineColor(memberID,color);
            this.updateMemberIDColorIndex();
        end

        function updateMemberIDColorIndex(this)
            baseColors=signal.sigappsshared.Utilities.getBaseColors();
            baseColorsSize=length(baseColors);
            if this.MemberIDColorIndex==baseColorsSize
                this.MemberIDColorIndex=1;
            else
                this.MemberIDColorIndex=1+this.MemberIDColorIndex;
            end
        end

        function updateColorIndex(this)
            baseColors=signal.sigappsshared.Utilities.getBaseColors();
            baseColorsSize=length(baseColors);
            if this.SignalIDColorIndex==baseColorsSize
                this.SignalIDColorIndex=1;
            else
                this.SignalIDColorIndex=1+this.SignalIDColorIndex;
            end
        end

        function addToMemberIDcolorRuleMap(this,memberID,coloringType)
            this.MemberIDcolorRuleMap(memberID)=coloringType;
        end

        function val=isExistInMemberIDcolorRuleMap(this,memberID)
            val=isKey(this.MemberIDcolorRuleMap,memberID);
        end

        function val=getMemberIDcolorRuleMap(this)
            val=this.MemberIDcolorRuleMap;
        end

        function val=getMemberColorFromMemberIDcolorRuleMap(this,memberID)
            val=this.MemberIDcolorRuleMap(memberID);
        end

        function removeFromMemberIDcolorRuleMap(this,memberID)
            remove(this.MemberIDcolorRuleMap,memberID);
        end

        function outData=getImportedSignalsDataForTreeTable(this,memberIDs)


            if~isempty(getAllParentLabelDefinitionIDs(this))
                hasLabels=true;
            else
                hasLabels=false;
            end
            sigData=getTreeTableDataStruct(this);
            outData=repmat(sigData,length(memberIDs),1);
            for idx=1:numel(memberIDs)

                signalObj=Simulink.sdi.getSignal(memberIDs(idx));
                outData(idx).id=num2str(signalObj.ID);
                outData(idx).parent=[];
                outData(idx).MemberID=int32(str2double(getMemberIDForSignalID(this,signalObj.ID)));
                tmMode=getSignalTmMode(this,signalObj.ID);
                [~,~,~,outData(idx).col1]=this.convertToValidMemberName(signalObj.Name,tmMode);
                temp=this.getColorInHex(memberIDs(idx));
                outData(idx).col2=['#',temp(1,:),temp(2,:),temp(3,:)];
                outData(idx).col3='';
                outData(idx).col4='';
                isHasChildrenSignal=false;
                if~isHasChildrenSignal&&signalObj.Complexity~="complex"

                    isHasChildrenSignal=this.isHasChildrenSignal(memberIDs(idx),tmMode);
                end
                if strcmp(tmMode,"file")
                    outData(idx).hasChildren=hasLabels;
                    outData(idx).rowDataType='signalHeader';
                elseif~isHasChildrenSignal
                    outData(idx).rowDataType='signal';

                    outData(idx).col5=this.getSampleRateOrTimeDisplayValue(memberIDs(idx));
                    outData(idx).hasChildren=hasLabels;
                else
                    outData(idx).hasChildren=true;
                    outData(idx).rowDataType='signalHeader';
                end
            end
        end

        function value=getSampleRateOrTimeDisplayValue(this,memberID)
            [dispLabel,dispValue,dispUnits]=signal.sigappsshared.SignalUtilities.getSampleRateOrTimeDisplayValue(this.Engine,memberID);
            value=dispLabel+dispValue+" "+dispUnits;
        end

        function[outData,isAnyHasChildrenFlagInSignalDataTrue]=getSignalDataForAutoLabelDialog(this,signalIDs)


            sigData=getAutoLableDialogTreeTableDataStruct(this);
            isAnyHasChildrenFlagInSignalDataTrue=false;
            outData=repmat(sigData,length(signalIDs),1);
            for idx=1:numel(signalIDs)

                signalObj=Simulink.sdi.getSignal(signalIDs(idx));
                outData(idx).id=num2str(signalObj.ID);
                outData(idx).parent=[];
                outData(idx).SignalID=signalObj.ID;
                outData(idx).MemberID=int32(str2double(getMemberIDForSignalID(this,signalObj.ID)));
                tmMode=getSignalTmMode(this,signalObj.ID);
                [~,outData(idx).Name]=this.convertToValidMemberName(signalObj.Name,tmMode);
                childIDs=this.Engine.getSignalChildren(signalIDs(idx));

                if strcmp(tmMode,"file")
                    outData(idx).hasChildren=false;
                    outData(idx).rowDataType='signalHeader';
                elseif isempty(childIDs)
                    outData(idx).rowDataType='signal';
                    outData(idx).hasChildren=false;
                else
                    outData(idx).hasChildren=true;
                    outData(idx).rowDataType='signalHeader';
                    isAnyHasChildrenFlagInSignalDataTrue=true;
                end
            end
        end

        function[outData,isAnyHasChildrenFlagInSignalDataTrue]=getSignalLeafChildrenDataForAutoLabelDialog(this,parentIDs)


            outData=[];
            sigStruct=getAutoLableDialogTreeTableDataStruct(this);

            for sig_idx=1:length(parentIDs)
                currentID=str2double(parentIDs{sig_idx});


                signalIDs=getLeafSignalIDsForMemberID(this,currentID);
                sigData=repmat(sigStruct,length(signalIDs),1);
                for child_idx=1:length(signalIDs)
                    signalObj=Simulink.sdi.getSignal(signalIDs(child_idx));
                    sigData(child_idx).id=num2str(signalObj.ID);
                    sigData(child_idx).parent=parentIDs{sig_idx};
                    sigData(child_idx).SignalID=signalObj.ID;
                    sigData(child_idx).MemberID=int32(str2double(getMemberIDForSignalID(this,signalObj.ID)));
                    [~,sigData(child_idx).Name]=Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(signalObj.Name);

                    sigData(child_idx).isFirstChild=child_idx==1;
                    childIDs=this.Engine.getSignalChildren(signalIDs(child_idx));

                    if isempty(childIDs)
                        sigData(child_idx).rowDataType='signal';
                        sigData(child_idx).hasChildren=false;
                    else
                        sigData(child_idx).hasChildren=true;
                        sigData(child_idx).rowDataType='signalHeader';
                        isAnyHasChildrenFlagInSignalDataTrue=true;
                    end
                end
                outData=[outData;sigData];
            end
        end

        function signalObj=getSignalObj(~,sigID)
            signalObj=Simulink.sdi.getSignal(sigID);
        end

        function[memberName,sigName,lssName,fullMemberName]=convertToValidMemberName(~,name,tmMode)

            isFileHeader=strcmp(tmMode,"file");
            if isFileHeader
                [~,fileName,ext]=fileparts(name);
                memberName=strcat(fileName,ext);
                sigName=name;
                lssName=[];
                fullMemberName=name;
            else
                [memberName,sigName,lssName]=Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(name);
                fullMemberName=memberName;
            end
        end

        function[outData]=getSignalDataForSignalSelectDialog(this,signalIDs,memberIDs)



            uniqueMemberIDs=unique(memberIDs,'stable');
            sigData=getAutoLableDialogTreeTableDataStruct(this);
            signalHeaderOutData=repmat(sigData,length(uniqueMemberIDs),1);
            for idx=1:numel(uniqueMemberIDs)

                memberID=str2double(uniqueMemberIDs(idx));
                signalObj=this.getSignalObj(memberID);
                signalHeaderOutData(idx).id=num2str(signalObj.ID);
                signalHeaderOutData(idx).parent=[];
                signalHeaderOutData(idx).SignalID=signalObj.ID;
                signalHeaderOutData(idx).MemberID=memberID;
                tmMode=getSignalTmMode(this,signalObj.ID);
                [~,signalHeaderOutData(idx).Name]=this.convertToValidMemberName(signalObj.Name,tmMode);
                signalHeaderOutData(idx).hasChildren=true;
                signalHeaderOutData(idx).rowDataType='signalHeader';
            end

            signalIDs=setdiff(signalIDs,str2double(uniqueMemberIDs));
            signalOutData=repmat(sigData,length(signalIDs),1);
            processedMemberIDs=[];
            for idx=1:numel(signalIDs)

                signalObj=this.getSignalObj(signalIDs(idx));
                signalOutData(idx).id=num2str(signalObj.ID);
                signalOutData(idx).parent=[];
                signalOutData(idx).SignalID=signalObj.ID;
                signalOutData(idx).MemberID=int32(str2double(memberIDs(idx)));
                [~,signalOutData(idx).Name]=Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(signalObj.Name);
                signalOutData(idx).rowDataType='signal';
                signalOutData(idx).parent=memberIDs(idx);
                signalOutData(idx).hasChildren=false;
                signalOutData(idx).isFirstChild=numel(find(processedMemberIDs==signalOutData(idx).MemberID))==0;
                processedMemberIDs=[processedMemberIDs;signalOutData(idx).MemberID];
            end
            outData=[signalHeaderOutData;signalOutData];
        end

        function[successFlag,exceptionKeyword,outData]=removeAllSignals(~,signalIDs)










            successFlag=true;
            exceptionKeyword='';
            outData=[];
            try
                for idx=1:numel(signalIDs)

                    signalObj=Simulink.sdi.getSignal(signalIDs(idx));
                    sigData.id=signalObj.ID;
                    sigData.parent=[];
                    sigData.col1=signalObj.Name;
                    temp=dec2hex(round(255.*signalObj.LineColor));
                    sigData.col2=['#',temp(1,:),temp(2,:),temp(3,:)];
                    sigData.col3='';
                    sigData.col4='';

                    sigData.hasChildren=true;
                    outData=[outData;sigData];
                end
            catch e
                successFlag=false;
                exceptionKeyword=e.identifier;
                outData=[];
            end
        end






        function axesOutData=getLabelDataOnAttributeUpdateForAutoLabel(this,info)



            axesOutData=[];
            labelInstanceIDs=info.updatedAttrLabelInstanceIDs;
            for idx=1:numel(labelInstanceIDs)
                newLabelData.LabelInstanceID=labelInstanceIDs(idx);
                labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceIDs(idx));
                newLabelData.ParentLabelInstanceID=string(labelInstance.parentLabelInstanceID);


                newAxesData=getLabelDataForAxes(this,newLabelData,true);
                axesOutData=[axesOutData;newAxesData];
            end
        end

        function axesLabelOutData=getLabelDataOnUndoForAutoLabel(this,info)
            axesLabelOutData=[];
            if~isempty(info.removedLabelInstanceIDs)
                axesDataStruct=getAxesDataStruct(this);
                memberIDs=unique(info.removedLabelInstanceMemberIDs,'stable');
                for memIdx=1:numel(memberIDs)
                    memberID=memberIDs(memIdx);
                    currentMemberInstancesIdx=(memberID==info.removedLabelInstanceMemberIDs);
                    labelDefIDs=info.removedLabelInstanceLabelDefIDs(currentMemberInstancesIdx);
                    labelDefID=labelDefIDs(1);
                    lblDef=getLabelDefFromLabelDefID(this,labelDefID);
                    [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
                    parentLabelDefinitionName=parentLblDef.labelDefinitionName;
                    parentLabelDefID=parentLblDef.labelDefinitionID;
                    axesData=axesDataStruct;
                    axesData.MemberID=memberID;
                    axesData.SignalID=getFirstMemberSignal(this,memberID);
                    axesData.LabelDefinitionID=labelDefID;
                    axesData.LabelDefinitionName=lblDef.labelDefinitionName;
                    axesData.ParentLabelDefinitionID=parentLabelDefID;
                    axesData.ParentLabelDefinitionName=parentLabelDefinitionName;
                    axesData.LabelType=lblDef.labelType;
                    axesData.isSublabel=isSublabel;
                    axesData.LabelInstanceIDs=info.removedLabelInstanceIDs(currentMemberInstancesIdx);
                    axesLabelOutData=[axesLabelOutData;axesData];
                end
            end


            for idx=1:numel(info.updateAttributLabelInstanceIDs)
                newLabelData.LabelInstanceID=info.updateAttributLabelInstanceIDs(idx);
                attLabelInstance=getLabelInstanceFromLabelInstanceID(this,info.updateAttributLabelInstanceIDs(idx));
                newLabelData.ParentLabelInstanceID=string(attLabelInstance.parentLabelInstanceID);


                newAxesData=getLabelDataForAxes(this,newLabelData,true);
                axesLabelOutData=[axesLabelOutData;newAxesData];
            end
        end




        function[axesOutData,treeTableData]=getLabelDataOnCreateForAutoLabel(this,labelData,info)



            axesOutData=[];
            isTreeTabelDataNeeded=~strcmp(this.getAppName(),'autoLabelMode')&&nargout==2;
            labelDefID=string(labelData.LabelDefinitionID);
            lblDef=getLabelDefFromLabelDefID(this,labelDefID);
            [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
            parentLabelDefinitionName=parentLblDef.labelDefinitionName;
            parentLabelDefID=parentLblDef.labelDefinitionID;
            childrenAttLabelDefIDs=[];
            if~isSublabel
                childrenAttLabelDefIDs=getAttributeChildrenLabelDefIDs(this,lblDef);
            end
            numMembers=numel(info.MemberIDs);
            axesDataStruct=getAxesDataStruct(this);
            treeTableDataStruct=getTreeTableDataStruct(this);



            treeTableData1=[];

            if isTreeTabelDataNeeded
                treeTableData2=repmat(treeTableDataStruct,numel(info.newInstanceIDs),1);
            else
                treeTableData2=[];
            end
            treeTableData2Idx=1;
            numOfNewAttrLabelInstance=numel(info.newAttrLabelInstanceIDs);
            numOfAttrSubLabelDefs=numel(childrenAttLabelDefIDs);

            if~isempty(info.newInstanceIDs)
                labelInstanceStartIdx=1;
                for idx=1:numMembers
                    memberID=info.MemberIDs(idx);
                    signalID=info.SignalIDs(idx);
                    labelInstanceIDs=info.newInstanceIDs;
                    currentMemberInstanceIDs=[];
                    currentMemberParentInstanceIDs=[];
                    currentMemberInstanceValues=[];
                    currentMemberInstanceTMin=[];
                    currentMemberInstanceTMax=[];
                    for labelInstanceIdx=labelInstanceStartIdx:numel(labelInstanceIDs)
                        newInstanceID=labelInstanceIDs(labelInstanceIdx);
                        newInstance=getLabelInstanceFromLabelInstanceID(this,newInstanceID);
                        if newInstance.memberID~=memberID
                            labelInstanceStartIdx=labelInstanceIdx;
                            break;
                        end
                        parentLabelInstanceID=string(newInstance.parentLabelInstanceID);
                        currentMemberInstanceIDs=[currentMemberInstanceIDs;newInstanceID];
                        currentMemberParentInstanceIDs=[currentMemberParentInstanceIDs;parentLabelInstanceID];
                        currentMemberInstanceValues=[currentMemberInstanceValues;string(newInstance.labelInstanceValue)];
                        currentMemberInstanceTMin=[currentMemberInstanceTMin;newInstance.labelInstanceTimeMin];
                        currentMemberInstanceTMax=[currentMemberInstanceTMax;newInstance.labelInstanceTimeMax];
                        if isTreeTabelDataNeeded
                            if lblDef.labelType~="attribute"
                                attributeLabelDefIdx=1;
                                childrenLabelDefIDs=getChildrenLabelDefIDs(this,lblDef);
                                for kk=1:numel(childrenLabelDefIDs)
                                    childLabelDefID=childrenLabelDefIDs(kk);
                                    childLblDef=getLabelDefFromLabelDefID(this,childLabelDefID);
                                    if childLblDef.labelType~="attribute"


                                        newTreeData=treeTableDataStruct;
                                        headerID=getHeaderID(this,childLabelDefID,memberID,newInstanceID);
                                        newTreeData.parent=newInstanceID;
                                        newTreeData.id=headerID;
                                        newTreeData.SignalID=getFirstMemberSignal(this,memberID);
                                        newTreeData.MemberID=memberID;
                                        newTreeData.col1=childLblDef.labelDefinitionName;
                                        newTreeData.rowDataType="labelHeader";
                                        treeTableData1=[treeTableData1;newTreeData];
                                    else


                                        newTreeData=treeTableDataStruct;







                                        for attribInstanceIdx=attributeLabelDefIdx:numOfAttrSubLabelDefs:numOfNewAttrLabelInstance




                                            attInstanceID=info.newAttrLabelInstanceIDs(attribInstanceIdx);
                                            attInstance=getLabelInstanceFromLabelInstanceID(this,attInstanceID);
                                            attInstanceParentInstanceID=string(attInstance.parentLabelInstanceID);
                                            attLblDefID=string(attInstance.labelDefinitionID);
                                            if childLabelDefID==attLblDefID&&attInstanceParentInstanceID==newInstanceID
                                                attlblDef=getLabelDefFromLabelDefID(this,attLblDefID);
                                                lblName=attlblDef.labelDefinitionName;
                                                attMemberID=attInstance.memberID;
                                                newTreeData.parent=attInstanceParentInstanceID;
                                                newTreeData.ParentLabelInstanceID=attInstanceParentInstanceID;
                                                newTreeData.id=attInstanceID;
                                                newTreeData.SignalID=getFirstMemberSignal(this,attMemberID);
                                                newTreeData.MemberID=attMemberID;
                                                newTreeData.col1=lblName;
                                                newTreeData.col2=string(attInstance.labelInstanceValue);
                                                newTreeData.rowDataType="attributeLabelInstance";
                                                newTreeData.isChecked=isAnySignalInMemberChecked(this,attMemberID);


                                                treeTableData1=[treeTableData1;newTreeData];
                                                break;
                                            end
                                        end
                                        attributeLabelDefIdx=attributeLabelDefIdx+1;
                                    end
                                end
                            end
                            lblDefID=newInstance.labelDefinitionID;
                            treeTableData2(treeTableData2Idx).id=newInstanceID;
                            treeTableData2(treeTableData2Idx).SignalID=getFirstMemberSignal(this,memberID);
                            treeTableData2(treeTableData2Idx).MemberID=memberID;
                            treeTableData2(treeTableData2Idx).col1='';
                            treeTableData2(treeTableData2Idx).col2=string(newInstance.labelInstanceValue);
                            if isemptyString(this,parentLabelInstanceID)
                                if lblDef.labelType=="attribute"
                                    treeTableData2(treeTableData2Idx).parent=memberID;
                                else

                                    treeTableData2(treeTableData2Idx).parent=getHeaderID(this,lblDefID,memberID);
                                end
                            else
                                if lblDef.labelType=="attribute"


                                    treeTableData2(treeTableData2Idx).parent=parentLabelInstanceID;
                                else

                                    treeTableData2(treeTableData2Idx).parent=getHeaderID(this,lblDefID,memberID,parentLabelInstanceID);
                                end
                                treeTableData2(treeTableData2Idx).ParentLabelInstanceID=parentLabelInstanceID;
                            end

                            if lblDef.labelType=="point"
                                treeTableData2(treeTableData2Idx).col3=newInstance.labelInstanceTimeMin;
                                treeTableData2(treeTableData2Idx).rowDataType="labelInstance";
                            elseif lblDef.labelType=="roi"
                                treeTableData2(treeTableData2Idx).col3=newInstance.labelInstanceTimeMin;
                                treeTableData2(treeTableData2Idx).col4=newInstance.labelInstanceTimeMax;
                                treeTableData2(treeTableData2Idx).rowDataType="labelInstance";
                            else
                                treeTableData2(treeTableData2Idx).rowDataType="attributeLabelInstance";
                            end
                            treeTableData2(treeTableData2Idx).isChecked=isAnySignalInMemberChecked(this,memberID);
                            treeTableData2Idx=treeTableData2Idx+1;
                        end
                    end


                    if~isAnySignalInMemberChecked(this,memberID)
                        continue;
                    end
                    axesDataTmp=axesDataStruct;
                    axesDataTmp.MemberID=memberID;
                    axesDataTmp.SignalID=signalID;
                    axesDataTmp.ParentLabelDefinitionID=parentLabelDefID;
                    axesDataTmp.ParentLabelDefinitionName=parentLabelDefinitionName;
                    axesDataTmp.LabelDefinitionID=labelDefID;
                    axesDataTmp.LabelDefinitionName=lblDef.labelDefinitionName;
                    axesDataTmp.LabelType=lblDef.labelType;
                    axesDataTmp.isSublabel=isSublabel;
                    axesDataTmp.ParentLabelInstanceIDs=currentMemberParentInstanceIDs;
                    axesDataTmp.LabelInstanceIDs=currentMemberInstanceIDs;
                    axesDataTmp.LabelInstanceValues=currentMemberInstanceValues;
                    axesDataTmp.LabelInstanceTimeMinValues=NaN(numel(labelInstanceIDs),1);
                    axesDataTmp.LabelInstanceTimeMaxValues=NaN(numel(labelInstanceIDs),1);

                    if lblDef.labelType=="point"
                        axesDataTmp.LabelInstanceTimeMinValues=currentMemberInstanceTMin;
                        axesDataTmp.LabelInstanceTimeMaxValues=NaN(numel(currentMemberInstanceTMin),1);
                    elseif lblDef.labelType=="roi"
                        axesDataTmp.LabelInstanceTimeMinValues=currentMemberInstanceTMin;
                        axesDataTmp.LabelInstanceTimeMaxValues=currentMemberInstanceTMax;
                    end
                    axesDataTmp.isVisible=true;
                    axesOutData=[axesOutData;axesDataTmp];
                end
            end

            if~isempty(info.newAttrLabelInstanceIDs)



                numAttLabels=numel(info.newAttrLabelInstanceIDs);
                aStartIdx=1;
                for idx=1:numMembers
                    memberID=info.MemberIDs(idx);
                    if~isAnySignalInMemberChecked(this,memberID)
                        continue;
                    end
                    signalID=info.SignalIDs(idx);
                    axesDataTmp=repmat(axesDataStruct,numOfAttrSubLabelDefs,1);
                    for jdx=1:numOfAttrSubLabelDefs

                        labelDefID=childrenAttLabelDefIDs(jdx);
                        attrLblDef=getLabelDefFromLabelDefID(this,labelDefID);
                        [attrParentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,attrLblDef);
                        attrParentLabelDefinitionName=attrParentLblDef.labelDefinitionName;
                        attrParentLabelDefID=attrParentLblDef.labelDefinitionID;
                        axesDataTmp(jdx).MemberID=memberID;
                        axesDataTmp(jdx).SignalID=signalID;
                        axesDataTmp(jdx).ParentLabelDefinitionID=attrParentLabelDefID;
                        axesDataTmp(jdx).ParentLabelDefinitionName=attrParentLabelDefinitionName;
                        axesDataTmp(jdx).LabelDefinitionID=labelDefID;
                        axesDataTmp(jdx).LabelDefinitionName=attrLblDef.labelDefinitionName;
                        axesDataTmp(jdx).LabelType=attrLblDef.labelType;
                        axesDataTmp(jdx).isSublabel=isSublabel;
                        axesDataTmp(jdx).isVisible=true;
                        for adx=1:numAttLabels

                            newAttrLabelInstance=getLabelInstanceFromLabelInstanceID(this,info.newAttrLabelInstanceIDs(adx));
                            if newAttrLabelInstance.memberID~=memberID||newAttrLabelInstance.labelDefinitionID~=string(labelDefID)
                                continue;
                            end
                            axesDataTmp(jdx).ParentLabelInstanceIDs=[axesDataTmp(jdx).ParentLabelInstanceIDs;string(newAttrLabelInstance.parentLabelInstanceID)];
                            axesDataTmp(jdx).LabelInstanceIDs=[axesDataTmp(jdx).LabelInstanceIDs;info.newAttrLabelInstanceIDs(adx)];
                            axesDataTmp(jdx).LabelInstanceValues=[axesDataTmp(jdx).LabelInstanceValues;string(newAttrLabelInstance.labelInstanceValue)];
                        end
                        axesDataTmp(jdx).LabelInstanceTimeMinValues=NaN(numel(axesDataTmp(jdx).LabelInstanceIDs),1);
                        axesDataTmp(jdx).LabelInstanceTimeMaxValues=NaN(numel(axesDataTmp(jdx).LabelInstanceIDs),1);
                    end
                    axesOutData=[axesOutData;axesDataTmp];
                end
            end
            treeTableData=[treeTableData1;treeTableData2];
        end





        function outData=getLabelDataForAxesOnCreate(this,labelData,info)


            outData=[];
            labelDefID=string(labelData.LabelDefinitionID);
            lblDef=getLabelDefFromLabelDefID(this,labelDefID);
            [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
            parentLabelDefinitionName=parentLblDef.labelDefinitionName;
            parentLabelDefID=parentLblDef.labelDefinitionID;
            numMembers=numel(info.MemberIDs);
            isLabelValueAutoComputed=isfield(info,'LabelDataSrc')&&info.LabelDataSrc=="automatedLabels";
            isLabelTimeAutoComputed=isLabelValueAutoComputed;
            axesDataStruct=getAxesDataStruct(this);

            if~isempty(info.newInstanceIDs)
                for idx=1:numMembers
                    memberID=info.MemberIDs(idx);
                    if~isAnySignalInMemberChecked(this,memberID)
                        continue;
                    end
                    signalID=info.SignalIDs(idx);
                    axesDataTmp=axesDataStruct;
                    axesDataTmp.MemberID=memberID;
                    axesDataTmp.SignalID=signalID;
                    axesDataTmp.ParentLabelDefinitionID=parentLabelDefID;
                    axesDataTmp.ParentLabelDefinitionName=parentLabelDefinitionName;
                    axesDataTmp.LabelDefinitionID=labelDefID;
                    axesDataTmp.LabelDefinitionName=lblDef.labelDefinitionName;
                    axesDataTmp.LabelType=lblDef.labelType;
                    axesDataTmp.isSublabel=isSublabel;
                    if this.getAppName()=="featureExtractionMode"
                        axesDataTmp.isEditable=false;
                    end
                    labelInstanceIDIndex=(info.newInstanceMemberIDs==string(memberID));
                    labelInstanceIDs=info.newInstanceIDs(labelInstanceIDIndex);
                    if isLabelValueAutoComputed
                        labelInstanceValues=info.newInstanceValues(labelInstanceIDIndex);

                        if isLabelTimeAutoComputed&&~isempty(info.newInstanceParentLabelInstanceIDs)
                            axesDataTmp.ParentLabelInstanceIDs=info.newInstanceParentLabelInstanceIDs(labelInstanceIDIndex);
                        end
                    else
                        labelInstanceValues=repmat(labelData.LabelValue,numel(labelInstanceIDs),1);
                        parentLabelInstanceID=string(labelData.ParentLabelInstanceID);
                        if~isemptyString(this,parentLabelInstanceID)
                            axesDataTmp.ParentLabelInstanceIDs=repmat(string(parentLabelInstanceID),numel(labelInstanceIDs),1);
                        end
                    end
                    axesDataTmp.LabelInstanceIDs=labelInstanceIDs;
                    axesDataTmp.LabelInstanceValues=formatValueForClient(this,labelInstanceValues,lblDef.labelDataType);
                    axesDataTmp.LabelInstanceTimeMinValues=NaN(numel(labelInstanceIDs),1);
                    axesDataTmp.LabelInstanceTimeMaxValues=NaN(numel(labelInstanceIDs),1);

                    if lblDef.labelType=="point"
                        if isLabelTimeAutoComputed
                            axesDataTmp.LabelInstanceTimeMinValues=info.newInstanceLocations(labelInstanceIDIndex,1);
                        else
                            axesDataTmp.LabelInstanceTimeMinValues=repmat(labelData.tMin,numel(labelInstanceIDs),1);
                        end
                    elseif lblDef.labelType=="roi"
                        if isLabelTimeAutoComputed
                            axesDataTmp.LabelInstanceTimeMinValues=info.newInstanceLocations(labelInstanceIDIndex,1);
                            axesDataTmp.LabelInstanceTimeMaxValues=info.newInstanceLocations(labelInstanceIDIndex,2);
                        else
                            axesDataTmp.LabelInstanceTimeMinValues=repmat(labelData.tMin,numel(labelInstanceIDs),1);
                            axesDataTmp.LabelInstanceTimeMaxValues=repmat(labelData.tMax,numel(labelInstanceIDs),1);
                        end
                    end
                    axesDataTmp.isVisible=true;
                    outData=[outData;axesDataTmp];
                end
            end
            if~isempty(info.newAttrLabelInstanceIDs)




                newAttrLabelDefIDs=strings(0,0);
                for idx=1:numel(info.newAttrLabelInstanceIDs)
                    attrLabelInstance=getLabelInstanceFromLabelInstanceID(this,info.newAttrLabelInstanceIDs(idx));
                    tempLblDefID=attrLabelInstance.labelDefinitionID;
                    newAttrLabelDefIDs=[newAttrLabelDefIDs;tempLblDefID];
                end
                labelDefIDs=unique(newAttrLabelDefIDs,'stable');
                for kk=1:numel(labelDefIDs)
                    labelDefID=labelDefIDs(kk);
                    for idx=1:numMembers
                        memberID=info.MemberIDs(idx);
                        if~isAnySignalInMemberChecked(this,memberID)
                            continue;
                        end
                        attrLblDef=getLabelDefFromLabelDefID(this,labelDefID);
                        [attrParentLblInfo,isSublabel]=getParentLabelDefOfLabelDef(this,attrLblDef);
                        attrParentLabelDefinitionName=attrParentLblInfo.labelDefinitionName;
                        attrParentLabelDefID=attrParentLblInfo.labelDefinitionID;
                        signalID=info.SignalIDs(idx);
                        axesDataTmp=axesDataStruct;
                        axesDataTmp.MemberID=memberID;
                        axesDataTmp.SignalID=signalID;
                        axesDataTmp.ParentLabelDefinitionID=attrParentLabelDefID;
                        axesDataTmp.ParentLabelDefinitionName=attrParentLabelDefinitionName;
                        axesDataTmp.LabelDefinitionID=labelDefID;
                        axesDataTmp.LabelDefinitionName=attrLblDef.labelDefinitionName;
                        axesDataTmp.LabelType=attrLblDef.labelType;
                        axesDataTmp.isSublabel=isSublabel;
                        if this.getAppName()=="featureExtractionMode"
                            axesDataTmp.isEditable=false;
                        end

                        labelInstanceIDIndex=(info.newAttrLabelInstanceMemberIDs==memberID)&(newAttrLabelDefIDs==labelDefID);
                        labelInstanceIDs=info.newAttrLabelInstanceIDs(labelInstanceIDIndex);
                        parentLabelInstanceIDs=info.newParentLabelInstanceIDsForAttrLabels(labelInstanceIDIndex);
                        labelInstanceValues=info.newAttrLabelInstanceValues(labelInstanceIDIndex);
                        axesDataTmp.ParentLabelInstanceIDs=parentLabelInstanceIDs;
                        axesDataTmp.LabelInstanceIDs=labelInstanceIDs;
                        axesDataTmp.LabelInstanceValues=formatValueForClient(this,labelInstanceValues,attrLblDef.labelDataType);
                        axesDataTmp.LabelInstanceTimeMinValues=NaN(numel(labelInstanceIDs),1);
                        axesDataTmp.LabelInstanceTimeMaxValues=NaN(numel(labelInstanceIDs),1);
                        axesDataTmp.isVisible=true;
                        outData=[outData;axesDataTmp];
                    end
                end
            end
        end

        function labelOutData=getLabelDataForAxes(this,labelData,isVisibleFlag,isHighlighted,signalIDCallback)




            if nargin<3
                isVisibleFlag=true;
            end
            if nargin<4
                isHighlighted=false;
            end

            if nargin<5
                signalIDCallback=@this.getFirstMemberSignal;
            end

            labelOutData=[];
            labelInstanceIDs=string(labelData.LabelInstanceID);
            numLabelInstance=numel(labelInstanceIDs);
            for idx=1:numLabelInstance
                labelInstanceID=labelInstanceIDs(idx);
                labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceID);
                memberID=labelInstance.memberID;

                if~isAnySignalInMemberChecked(this,memberID)
                    continue;
                end

                labelDefID=labelInstance.labelDefinitionID;
                lblDef=getLabelDefFromLabelDefID(this,labelDefID);
                [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
                parentLabelDefinitionName=parentLblDef.labelDefinitionName;
                parentLabelDefID=parentLblDef.labelDefinitionID;
                outData=this.getAxesDataStruct();
                outData.MemberID=memberID;
                outData.SignalID=signalIDCallback(memberID);
                outData.LabelDefinitionID=labelDefID;
                outData.LabelDefinitionName=lblDef.labelDefinitionName;
                outData.ParentLabelDefinitionID=parentLabelDefID;
                outData.ParentLabelDefinitionName=parentLabelDefinitionName;
                outData.LabelType=lblDef.labelType;
                outData.LabelDataType=lblDef.labelDataType;
                if lblDef.labelDataType=="categorical"
                    outData.LabelDataCategories=lblDef.categories;
                end
                outData.isSublabel=isSublabel;
                if this.getAppName()=="featureExtractionMode"
                    outData.isEditable=false;
                end
                outData.LabelInstanceIDs=labelInstanceID;
                outData.LabelInstanceValues=labelInstance.labelInstanceValue;
                outData.LabelInstanceTimeMinValues=labelInstance.labelInstanceTimeMin;
                outData.LabelInstanceTimeMaxValues=labelInstance.labelInstanceTimeMax;
                outData.ParentLabelInstanceIDs=string(labelInstance.parentLabelInstanceID);
                outData.isVisible=isVisibleFlag;
                outData.isHighlighted=isHighlighted;
                labelOutData=[labelOutData;outData];
            end

        end

        function outData=getLabelDataForAxesOnAttributeUpdate(this,labelData,isVisibleFlag,info)



            outData=[];
            if nargin>3
                labelInstanceIDs=info.updatedAttrLabelInstanceIDs;
                parentLabelInstanceIDs=info.updatedAttrParentLabelInstanceIDs;
            else
                labelInstanceIDs=string(labelData.LabelInstanceIDs);
                parentLabelInstanceIDs=string(labelData.ParentLabelInstanceIDs);
            end

            for idx=1:numel(labelInstanceIDs)
                newLabelData.LabelInstanceID=labelInstanceIDs(idx);
                newLabelData.ParentLabelInstanceID=parentLabelInstanceIDs(idx);
                newOutData=getLabelDataForAxes(this,newLabelData,isVisibleFlag);
                outData=[outData;newOutData];
            end
        end

        function outData=getLabelDataForAxesOnLabelCheck(this,labelData,isVisibleFlag)

            outData=[];
            labelInstanceID=string(labelData.LabelInstanceIDs);
            memberID=getMemberAndLabelDefIDFromLabelInstanceID(this,labelInstanceID);
            if isAnySignalInMemberChecked(this,memberID)
                parentLabelInstanceID=string(labelData.ParentLabelInstanceIDs);
                labelData.LabelInstanceID=labelInstanceID;
                labelData.ParentLabelInstanceID=parentLabelInstanceID;
                outData=getLabelDataForAxes(this,labelData,isVisibleFlag);
            end
        end

        function outAxesData=getLabelDataForAxesBySignalIDOnSignalCheck(this,newSignalIDs,labelDefIDs,includeSublabels,isMemberID)








            if nargin==5&&isMemberID


                memberIDs=string(newSignalIDs);
            else
                memberIDs=unique(getMemberIDForSignalID(this,newSignalIDs),'stable');
            end
            outAxesData=[];
            for memberIDx=1:numel(memberIDs)
                memberID=memberIDs(memberIDx);
                signalID=getFirstMemberSignal(this,memberID);



                if nargin<3
                    labelDefIDs=getAllLabelDefinitionIDs(this);
                elseif includeSublabels

                    lblDef=getLabelDefFromLabelDefID(this,labelDefIDs);
                    childrenLabelDefIDs=getChildrenLabelDefIDs(this,lblDef);
                    labelDefIDs=[labelDefIDs,childrenLabelDefIDs];
                end
                for lblDefIDx=1:numel(labelDefIDs)
                    labelDefID=labelDefIDs(lblDefIDx);
                    lblDef=getLabelDefFromLabelDefID(this,labelDefID);
                    labelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,labelDefID,memberID);
                    numLabelInstances=numel(labelInstanceIDs);
                    parentLabelInstanceIDs=repmat("",numLabelInstances,1);
                    valueVect=repmat("",numLabelInstances,1);
                    t1Vect=NaN(numLabelInstances,1);
                    t2Vect=NaN(numLabelInstances,1);
                    for lblInstanceIdx=1:numLabelInstances
                        lblInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceIDs(lblInstanceIdx));
                        parentLabelInstanceIDs(lblInstanceIdx)=lblInstance.parentLabelInstanceID;
                        valueVect(lblInstanceIdx)=formatValueForClient(this,lblInstance.labelInstanceValue,lblDef.labelDataType);
                        if lblDef.labelType=="point"
                            t1Vect(lblInstanceIdx)=lblInstance.labelInstanceTimeMin;
                        elseif lblDef.labelType=="roi"
                            t1Vect(lblInstanceIdx)=lblInstance.labelInstanceTimeMin;
                            t2Vect(lblInstanceIdx)=lblInstance.labelInstanceTimeMax;
                        end
                    end
                    [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
                    parentLabelDefinitionName=parentLblDef.labelDefinitionName;
                    parentLabelDefID=parentLblDef.labelDefinitionID;
                    outData=getAxesDataStruct(this);
                    outData.MemberID=memberID;
                    outData.SignalID=signalID;
                    outData.LabelDefinitionID=labelDefID;
                    outData.LabelDefinitionName=lblDef.labelDefinitionName;
                    outData.ParentLabelDefinitionID=parentLabelDefID;
                    outData.ParentLabelDefinitionName=parentLabelDefinitionName;
                    outData.LabelType=lblDef.labelType;
                    outData.LabelDataType=lblDef.labelDataType;
                    if lblDef.labelDataType=="categorical"
                        outData.LabelDataCategories=lblDef.categories;
                    end
                    outData.isSublabel=isSublabel;
                    if this.getAppName()=="featureExtractionMode"
                        outData.isEditable=false;
                    end


                    outData.isVisible=lblDef.labelType=="attribute";
                    if numLabelInstances~=0
                        outData.LabelInstanceIDs=labelInstanceIDs;
                        outData.ParentLabelInstanceIDs=parentLabelInstanceIDs;
                        outData.LabelInstanceValues=valueVect;
                        outData.LabelInstanceTimeMinValues=t1Vect;
                        outData.LabelInstanceTimeMaxValues=t2Vect;
                    end
                    outAxesData=[outAxesData;outData];
                end
            end
        end

        function outAxesData=getLabelDataForAxesOnDelete(this,info,signalIDCallback)



            if nargin<3
                signalIDCallback=@this.getFirstMemberSignal;
            end

            outAxesData=[];
            outDataStruct=getAxesDataStruct(this);
            memberID=info.removedLabelInstanceMemberID;
            labelDefIDs=unique(info.removedLabelInstanceLabelDefIDs,'stable');
            for lblDefIDx=1:numel(labelDefIDs)
                labelDefID=labelDefIDs(lblDefIDx);
                labelInstanceIDIndex=(info.removedLabelInstanceLabelDefIDs==labelDefID);
                labelInstanceIDs=info.removedLabelInstanceIDs(labelInstanceIDIndex);
                labelInstanceParentRowIDs=info.removedLabelInstanceParentRowIDs(labelInstanceIDIndex);
                lblDef=getLabelDefFromLabelDefID(this,labelDefID);
                [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
                parentLabelDefinitionName=parentLblDef.labelDefinitionName;
                parentLabelDefID=parentLblDef.labelDefinitionID;
                outData=outDataStruct;
                outData.MemberID=memberID;
                outData.SignalID=signalIDCallback(memberID);
                outData.LabelDefinitionID=labelDefID;
                outData.LabelDefinitionName=lblDef.labelDefinitionName;
                outData.ParentLabelDefinitionID=parentLabelDefID;
                outData.ParentLabelDefinitionName=parentLabelDefinitionName;
                outData.LabelType=lblDef.labelType;
                outData.isSublabel=isSublabel;
                outData.LabelInstanceIDs=labelInstanceIDs;
                outData.LabelInstanceParentRowIDs=labelInstanceParentRowIDs;
                outAxesData=[outAxesData;outData];
            end
        end

        function outData=getLabelDataForLabelSignalWidget(this,labelData,signalID,isVisibleFlag)%#ok<INUSL>

            if nargin<4
                isVisibleFlag=true;
            end

            outData=struct(...
            'ParentLabelDefinitionID','',...
            'ParentLabelDefinitionName','',...
            'LabelDefinitionID','',...
            'LabelDefinitionName','',...
            'LabelType','',...
            'LabelDataType','',...
            'LabelDataCategories',[],...
            'isSublabel','',...
            'ParentLabelInstanceID',[],...
            'LabelInstanceID',[],...
            'LabelInstanceValue',[],...
            'LabelInstanceTimeMinValue',[],...
            'LabelInstanceTimeMaxValue',[]);

            labelInstanceID=labelData.LabelInstanceID;
            labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceID);
            labelDefID=labelInstance.labelDefinitionID;
            lblDef=getLabelDefFromLabelDefID(this,labelDefID);
            [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
            parentLabelDefinitionName=parentLblDef.labelDefinitionName;
            parentLabelDefID=parentLblDef.labelDefinitionID;
            outData.LabelDefinitionID=labelDefID;
            outData.LabelDefinitionName=lblDef.labelDefinitionName;
            outData.ParentLabelDefinitionID=parentLabelDefID;
            outData.ParentLabelDefinitionName=parentLabelDefinitionName;
            outData.LabelType=lblDef.labelType;
            outData.LabelDataType=lblDef.labelDataType;
            if strcmp(lblDef.labelDataType,'categorical')
                outData.LabelDataCategories=lblDef.categories;
            end
            outData.isSublabel=isSublabel;
            outData.LabelInstanceID=labelInstanceID;
            outData.LabelInstanceValue=labelInstance.labelInstanceValue;
            outData.LabelInstanceTimeMinValue=labelInstance.labelInstanceTimeMin;
            outData.LabelInstanceTimeMaxValue=labelInstance.labelInstanceTimeMax;
            outData.ParentLabelInstanceID=labelData.ParentLabelInstanceID;
            outData.isChecked=isVisibleFlag;
        end

        function tmMode=getSignalTmMode(this,signalID)
            tmMode=this.Engine.getSignalTmMode(signalID);
        end

        function tmMode=getTmModeLabeledSignalSet(this,signalID)
            tmMode=signal.sigappsshared.SignalUtilities.getTmModeLabeledSignalSet(this.Engine,signalID);
        end

        function resampledSigID=getSignalResampledSigID(this,signalID)
            resampledSigID=this.Engine.getSignalTmResampledSigID(signalID);
        end

        function avgColor=getColorInHex(this,signalID)
            avgColor=dec2hex(round(255*this.Engine.getSignalLineColor(signalID)));
        end




        function outData=getSignalsData(this,signalIDs,operation)















            outData=[];
            plotIndex=[];
            if strcmp(operation,'check')
                plotIndex=1;
            end


            for idx=1:numel(signalIDs)

                signalID=signalIDs(idx);
                signalObj=this.getSignalObj(signalID);
                sigData.signal_id=signalObj.ID;
                sigData.name=signalObj.Name;
                temp=dec2hex(round(255.*signalObj.LineColor));
                sigData.color=['#',temp(1,:),temp(2,:),temp(3,:)];
                sigData.Complexity=signalObj.Complexity=="complex";
                sigData.TmMode=this.getSignalTmMode(signalID);
                sigData.TmModeLSS=this.getTmModeLabeledSignalSet(signalID);
                sigData.TmResampledSigID=this.getSignalResampledSigID(signalID);
                sigData.plot_indices=plotIndex;
                sigData.isEnum=false;
                sigData.is_enum=false;
                sigData.is_string=false;
                sigData.memberID=int32(str2double(getMemberIDForSignalID(this,signalID)));
                memberFileName="";
                fullMemberFileName="";
                if getSignalTmMode(this,sigData.memberID)=="file"
                    fullMemberFileName=this.Engine.sigRepository.getSignalName(sigData.memberID);
                    [~,memberFileName,~]=fileparts(fullMemberFileName);
                end
                sigData.memberFileName=memberFileName;
                sigData.fullMemberFileName=fullMemberFileName;
                memberColor=this.getColorInHex(sigData.memberID);
                sigData.memberColor=['#',memberColor(1,:),memberColor(2,:),memberColor(3,:)];
                sigData.linestyle='-';
                sigData.type='checked';
                outData=[outData;sigData];
            end
        end

        function outData=getSignalValue(this,signalID)
            runID=this.Engine.sigRepository.getAllRunIDs('signalLabeler');
            outData=signal.sigappsshared.SignalUtilities.getSignalValue(this.Engine,runID,signalID,true);
        end

        function flag=isAnyMemberSignalCheckedExcludingInputSignalID(this,signalID)


            memberID=getMemberIDForSignalID(this,signalID);
            signalIDs=getCheckedSignalIDsInMember(this,memberID);
            signalIDs=setdiff(signalIDs,signalID);
            flag=~isempty(signalIDs);
        end

        function info=undoAutomatedLabelInstance(this,autoAddedInstancesInfo)
            info.success=true;
            info.exception=strings(0,0);
            info.updateAttributLabelInstanceIDs=[];
            info.removedLabelInstanceIDs=[];
            info.removedLabelInstanceLabelDefIDs=[];
            info.removedLabelInstanceMemberIDs=[];
            info.removedLabelInstanceParentRowIDs=[];
            if nargin==1
                autoAddedInstancesInfo=this.getAutoAddedInstancesInfo();
                if isempty(autoAddedInstancesInfo)
                    return;
                end
                this.resetAutoAddedInstancesInfo();
            end
            isAttbLabelDef=autoAddedInstancesInfo.LabelDefinitionType=="attribute";
            for idx=1:numel(autoAddedInstancesInfo.InstanceIDs)
                labelInstanceID=autoAddedInstancesInfo.InstanceIDs(idx);
                if isAttbLabelDef

                    labelData=struct('LabelInstanceID',labelInstanceID,...
                    'LabelInstanceValue',autoAddedInstancesInfo.InstancesOldValues(idx));
                    updateLabelInstance(this,labelData,false);
                    info.updateAttributLabelInstanceIDs=[info.updateAttributLabelInstanceIDs;labelInstanceID];
                else

                    labelData=struct('LabelInstanceID',labelInstanceID);
                    labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceID);

                    info.removedLabelInstanceIDs=[info.removedLabelInstanceIDs;labelInstanceID];
                    info.removedLabelInstanceLabelDefIDs=[info.removedLabelInstanceLabelDefIDs;string(labelInstance.labelDefinitionID)];
                    info.removedLabelInstanceMemberIDs=[info.removedLabelInstanceMemberIDs;string(labelInstance.memberID)];
                    deleteInfo=deleteROIandPointLabelInstancesUnlabelAttributeInstances(this,labelData);
                    removedLabelInstanceParentRowID=deleteInfo.removedLabelInstanceParentRowIDs(deleteInfo.removedLabelInstanceIDs==labelInstanceID);
                    info.removedLabelInstanceParentRowIDs=[info.removedLabelInstanceParentRowIDs;removedLabelInstanceParentRowID];
                end
            end
        end

        function[successFlag,exceptionKeyword,info]=addAutomatedLabelInstance(this,memberIDs,requestedSignalInfos,labelDefintionIDs,functionHandle,labelerSettingsArguments,runTimeLimits)
            successFlag=true;
            exceptionKeyword='';
            info=struct;
            info.successFlag=successFlag;
            info.newAttrLabelInstanceIDs=[];
            info.newAttrLabelInstanceDefIDs=[];
            info.updatedAttrLabelInstanceOldValues=[];
            info.updatedAttrLabelInstanceIDs=[];
            info.newInstanceIDs=[];
            firstMemberSignalIDs=[];
            mf0LabelDataStruct=getMf0LabelDataStruct(this);

            this.resetAutoAddedInstancesInfo();
            tx=this.Mf0DataModel.beginTransaction;

            for memIdx=1:numel(memberIDs)


                memberID=memberIDs(memIdx);
                firstMemberSignalIDs=[firstMemberSignalIDs;getFirstMemberSignal(this,memberID)];
                memberInfo=this.getSignalData(this.getSignalIDsFromSignalInfo(requestedSignalInfos,memberID),runTimeLimits);
                data=memberInfo.Data;
                time=memberInfo.Time;
                c=size(labelDefintionIDs,2);
                numberOfParentInstanceLoops=1;
                isSublabeling=false;
                if c==1
                    allLabelDefintionIDs=labelDefintionIDs;
                    allParentLabelDefintionIDs=strings(0,1);
                elseif c==2
                    allLabelDefintionIDs=labelDefintionIDs(:,2);
                    allParentLabelDefintionIDs=labelDefintionIDs(:,1);
                end
                for idx=1:numel(allLabelDefintionIDs)
                    if~isempty(allParentLabelDefintionIDs)

                        isSublabeling=true;
                        parentLabelDef=getLabelDefFromLabelDefID(this,allParentLabelDefintionIDs(idx));
                        parentLabelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,allParentLabelDefintionIDs(idx),memberID);
                        numberOfParentInstanceLoops=numel(parentLabelInstanceIDs);
                    end
                    for jdx=1:numberOfParentInstanceLoops
                        parentLabelInstanceID="";
                        parentLabelInstanceValue=[];
                        parentLabelInstanceLocations=[];
                        if isSublabeling
                            parentLabelInstanceID=parentLabelInstanceIDs(jdx);
                            parentLabelInstance=getLabelInstanceFromLabelInstanceID(this,parentLabelInstanceID);
                            parentLabelInstanceValue=formatValueForLSS(this,parentLabelInstance.labelInstanceValue,parentLabelDef.labelDataType);
                            if parentLabelDef.labelType=="roi"
                                parentLabelInstanceLocations=[parentLabelInstance.labelInstanceTimeMin,parentLabelInstance.labelInstanceTimeMax];
                                if~isempty(runTimeLimits)&&~(parentLabelInstanceLocations(1)>=runTimeLimits(1)&&parentLabelInstanceLocations(2)<=runTimeLimits(2))


                                    continue;
                                end
                            elseif parentLabelDef.labelType=="point"
                                parentLabelInstanceLocations=parentLabelInstance.labelInstanceTimeMin;
                                if~isempty(runTimeLimits)&&~(parentLabelInstanceLocations(1)>=runTimeLimits(1)&&parentLabelInstanceLocations(1)<=runTimeLimits(2))


                                    continue;
                                end
                            end
                        end

                        try
                            if isempty(labelerSettingsArguments)
                                [labelValues,LabelLocs]=functionHandle(data,time,parentLabelInstanceValue,parentLabelInstanceLocations);
                            else
                                [labelValues,LabelLocs]=functionHandle(data,time,parentLabelInstanceValue,parentLabelInstanceLocations,labelerSettingsArguments{:});
                            end
                        catch e
                            info.successFlag=false;
                            info.exception=e.message;

                            break;
                        end

                        lblDef=getLabelDefFromLabelDefID(this,allLabelDefintionIDs(idx));
                        if~isempty(labelValues)
                            [verInfo,numLabels]=verifyLabelValuesAndTimeForAutoLabel(this,labelValues,LabelLocs,lblDef);
                            if~verInfo.successFlag

                                info=verInfo;
                                break;
                            end
                            if lblDef.labelType=="attribute"




                                if isSublabeling
                                    labelInstanceID=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,allLabelDefintionIDs(idx),memberID,parentLabelInstanceID);
                                else
                                    labelInstanceID=getLabelInstaceIDsForLabelDefIDAndMemberID(this,allLabelDefintionIDs(idx),memberID);
                                end



                                info.updatedAttrLabelInstanceIDs=[info.updatedAttrLabelInstanceIDs;labelInstanceID];
                                labelData=struct('LabelInstanceID',labelInstanceID,...
                                'LabelInstanceValue',formatValueForClient(this,labelValues,lblDef.labelDataType));
                                attrLabelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceID);
                                attrLabelInstanceOldValue=string(attrLabelInstance.labelInstanceValue);
                                updateInfo=updateLabelInstance(this,labelData,false);
                                if~updateInfo.successFlag

                                    undoAutomatedLabelInstance(this,createAutoAddedInstancesInfo(this,info));
                                    info.successFlag=false;
                                    info.exception=updateInfo.exception;
                                    break
                                end

                                info.successFlag=true;
                                info.updatedAttrLabelInstanceOldValues=[info.updatedAttrLabelInstanceOldValues;attrLabelInstanceOldValue];
                            else
                                for kdx=1:numLabels
                                    labelData=struct('LabelDefinitionID',lblDef.labelDefinitionID,...
                                    'ParentLabelInstanceID',parentLabelInstanceID,...
                                    'LabelValue',formatValueForClient(this,labelValues(kdx),lblDef.labelDataType),...
                                    'tMin',[],...
                                    'tMax',[]);
                                    if lblDef.labelType=="point"
                                        labelData.tMin=LabelLocs(kdx);
                                    else
                                        labelData.tMin=LabelLocs(kdx,1);
                                        labelData.tMax=LabelLocs(kdx,2);
                                    end
                                    [successFlag,exceptionKeyword,currLblInfo]=addLabelInstance(this,memberID,labelData,true,false,lblDef,mf0LabelDataStruct);
                                    if~successFlag

                                        undoAutomatedLabelInstance(this,createAutoAddedInstancesInfo(this,info));
                                        info.successFlag=false;
                                        info.exception=exceptionKeyword;
                                        break
                                    else
                                        info.successFlag=true;
                                        info.newInstanceIDs=[info.newInstanceIDs;currLblInfo.newInstanceIDs];


                                        info.newAttrLabelInstanceIDs=[info.newAttrLabelInstanceIDs;currLblInfo.newAttrLabelInstanceIDs];
                                    end
                                end
                            end
                        end
                    end
                    if~info.successFlag

                        break;
                    end
                end
                if~info.successFlag


                    successFlag=info.successFlag;
                    exceptionKeyword=info.exception;

                    break;
                end
            end
            tx.commit;
            if successFlag

                this.AutoAddedInstancesInfo=createAutoAddedInstancesInfo(this,info);



                info.SignalIDs=firstMemberSignalIDs;
                info.MemberIDs=memberIDs;
                info.NumInstances=numel(info.newAttrLabelInstanceIDs)+numel(info.newInstanceIDs);
                info.LabelDataSrc="automatedLabels";
                if this.getAppName()=="autoLabelMode"
                    this.setAutoAddedInstancesNewValueInfo(info);
                end
            end
        end

        function[info,labelValueRow]=verifyLabelValuesAndTimeForAutoLabel(~,labelValues,LabelLocs,lblDef)
            info.successFlag=true;
            info.exception='';



            [labelValueRow,labelValueCol]=size(string(labelValues));
            [labelLocationsRow,labelLocationsCol]=size(LabelLocs);



            if lblDef.labelType~="attribute"&&labelValueRow~=labelLocationsRow
                info.successFlag=false;
                info.exception='MATLAB:labeledSignalSet:incorrectNumcols';
                return;
            end
            if lblDef.labelType=="point"
                if labelValueCol>1
                    info.successFlag=false;
                    info.exception='InvalidLabelValueDimension';
                    return;
                elseif labelLocationsCol~=1
                    info.successFlag=false;
                    info.exception='InvalidLocationDimensionPoint';
                    return;
                elseif~isnumeric(LabelLocs)
                    info.successFlag=false;
                    info.exception='MATLAB:labeledSignalSet:invalidType';
                    return;
                end
            elseif lblDef.labelType=="roi"
                if labelValueCol>1
                    info.successFlag=false;
                    info.exception='InvalidLabelValueDimension';
                    return;
                elseif labelLocationsCol~=2
                    info.successFlag=false;
                    info.exception='InvalidLocationDimensionROI';
                    return;
                elseif~isnumeric(LabelLocs)
                    info.successFlag=false;
                    info.exception='MATLAB:labeledSignalSet:invalidType';
                    return;
                elseif any(LabelLocs(:,2)<LabelLocs(:,1))
                    info.successFlag=false;
                    info.exception='labeledSignalSet:InvalidROILimits';
                end
            elseif lblDef.labelType=="attribute"
                if labelValueCol>1||labelValueRow>1
                    info.successFlag=false;
                    info.exception='InvalidLabelValueDimension';
                    return;
                elseif labelLocationsCol>0||labelLocationsRow>0
                    info.successFlag=false;
                    info.exception='InvalidLocationDimension';
                    return;
                end
            end
            switch(lblDef.labelDataType)
            case "numeric"
                if~any(isnumeric(labelValues))
                    info.successFlag=false;
                    info.exception='signalLabelDefinition:MustBeNumeric';
                end
            case "logical"
                if~any(islogical(labelValues))
                    info.successFlag=false;
                    info.exception='signalLabelDefinition:MustBeLogical';
                end
            case "string"
                if~any(isstring(labelValues))
                    if~any(ischar(labelValues))
                        info.successFlag=false;
                        info.exception='signalLabelDefinition:MustBeString';
                    end
                end
            case "categorical"
                if all(iscategorical(labelValues))...
                    ||all(isstring(labelValues))...
                    ||all(ischar(labelValues))
                    validCategories=categories(categorical(lblDef.categories));
                    if~all(ismember(categories(categorical(cellstr(labelValues))),validCategories))
                        info.successFlag=false;
                        info.exception='signalLabelDefinition:InvalidCategoryValue';
                    end
                else
                    info.successFlag=false;
                    info.exception='signalLabelDefinition:InvalidCategoryValue';
                end
            end
        end

        function autoAddedInstancesInfo=createAutoAddedInstancesInfo(~,info)
            autoAddedInstancesInfo=struct('InstanceIDs',[],'LabelDefinitionType',"",'InstancesOldValues',[]);
            if isempty(info.updatedAttrLabelInstanceIDs)


                autoAddedInstancesInfo.InstanceIDs=info.newInstanceIDs;
                autoAddedInstancesInfo.LabelDefinitionType="roi/point";
            else





                autoAddedInstancesInfo.InstanceIDs=info.updatedAttrLabelInstanceIDs;
                autoAddedInstancesInfo.LabelDefinitionType="attribute";
                autoAddedInstancesInfo.InstancesOldValues=info.updatedAttrLabelInstanceOldValues;
            end
        end

        function info=getAutoAddedInstancesNewValueInfo(this)
            info=[];
            if~isfield(this.AutoAddedInstancesInfo,'newValueInfo')
                return;
            end
            info=this.AutoAddedInstancesInfo.newValueInfo;
        end

        function setAutoAddedInstancesNewValueInfo(this,info)
            this.AutoAddedInstancesInfo.newValueInfo=info;
        end

        function[signalIDs,memberIDs]=getCheckedSignalAndMemberIDs(this)
            signalIDs=this.CheckedSignalIDs;
            memberIDs=this.getMemberIDForSignalID(signalIDs);
        end

        function flag=isAnySignalInMemberChecked(this,memberID)
            if this.isFastLabelMode()
                flag=true;
                return;
            end
            signalIDs=getCheckedSignalIDsInMember(this,memberID);
            flag=~isempty(signalIDs);
        end

        function flag=isAnySignalInChildHeaderChecked(this,signalChildHeaderID,memberID)
            flag=false;
            if~isempty(signalChildHeaderID)
                flag=any(ismember(this.getAllSignalChildrenIDs(signalChildHeaderID),this.getCheckedSignalIDsInMember(memberID)));
            end
        end

        function[memberID,labelDefID]=parseTreeTableRowID(~,rowID,isReturnStrings)
            if nargin==2
                isReturnStrings=false;
            end
            rowIDSplit=split(rowID,'_');
            memberID=rowIDSplit{1};
            if~isReturnStrings
                memberID=str2double(memberID);
            end
            labelDefID=string(rowIDSplit{2});
        end

        function[memberID,labelDefID]=getMemberAndLabelDefIDFromLabelInstanceID(this,labelInstanceID)
            try
                lblInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceID);
                memberID=str2double(lblInstance.memberID);
                labelDefID=string(lblInstance.labelDefinitionID);
            catch

                [memberID,labelDefID]=parseTreeTableRowID(this,labelInstanceID);
            end
        end

        function memberIDs=getMemberIDForSignalID(this,signalIDs)





            memberIDsInApp=this.getMemberIDs();
            for idx=1:numel(signalIDs)
                signalID=signalIDs(idx);

                if any(ismember(memberIDsInApp,signalID))
                    memberIDs(idx)=string(signalID);
                    continue;
                end


                if this.isLeafSignalID(signalID)
                    memberIDs(idx)=this.getMemberIDForSignalIDByMap(memberIDsInApp,signalID);
                    continue;
                end


                leafSigIDs=signal.sigappsshared.SignalUtilities.recurseGetAllLeafChildren(this.Engine,signalID);
                memberIDs(idx)=this.getMemberIDForSignalIDByMap(memberIDsInApp,leafSigIDs(1));
            end
        end

        function memberID=getMemberIDForSignalIDByMap(this,memberIDsInApp,signalID)



            for jdx=1:numel(memberIDsInApp)
                leafSignalIDsForMemberID=this.getLeafSignalIDsForMemberID(memberIDsInApp(jdx));
                if any(ismember(leafSignalIDsForMemberID,signalID))
                    memberID=string(memberIDsInApp(jdx));
                    return;
                end
            end
        end

        function isLeafSignal=isLeafSignalID(this,signalID)
            isLeafSignal=any(this.getAllCheckableSignalIDs()==signalID);
        end

        function[memberID,isComplex]=correctMemberIDIfComplexSignal(this,inputMemberID)


            isComplex=false;
            memberID=inputMemberID;
            leafSigIDs=signal.sigappsshared.SignalUtilities.recurseGetAllLeafChildren(this.Engine,inputMemberID);
            if~isempty(leafSigIDs)
                if this.isSignalHasComplexData(inputMemberID)


                    isComplex=true;
                    memberID=leafSigIDs(1);
                    return;
                elseif this.isSignalHasComplexData(leafSigIDs(1))
                    isComplex=true;
                    memberID=inputMemberID;
                end
            end
        end



        function setupForAutoLabelMode(this,memberIDs,checkedSignalIDs,labelDefintionData)
            this.resetLeafSignalIDsForMemberIDAndMemberIDsInAutoLabelMode();
            this.EditableLabelDefintionsIDsInAutoLabelMode=string(labelDefintionData(:).LabelDefinitionID);
            this.addLeafSignalIDsForMemberIDInAutoLabelMode(memberIDs,checkedSignalIDs);

        end

        function axesOutData=getLabelDataForAxesInAutoLabelModeOnImport(this,memberIDs)
            memberIDs=unique(memberIDs,'stable');
            numberOfMembers=numel(memberIDs);
            parentLabelAxesData=[];
            if numberOfMembers==0
                return;
            end
            for lblDefIdx=1:numel(this.EditableLabelDefintionsIDsInAutoLabelMode)
                lblDef=getLabelDefFromLabelDefID(this,this.EditableLabelDefintionsIDsInAutoLabelMode(lblDefIdx));
                [parentLblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblDef);
                parentLabelDefinitionName=parentLblDef.labelDefinitionName;
                parentLabelDefID=parentLblDef.labelDefinitionID;
                if isSublabel
                    parentLabelAxesData=repmat(this.getAxesDataStruct(),numel(memberIDs),1);
                end



                axesData=repmat(this.getAxesDataStruct(),numel(memberIDs),1);





                for idx=1:numberOfMembers
                    memberID=memberIDs(idx);
                    signalIDs=this.getLeafSignalIDsForMemberIDInAutoLabelMode(memberID);


                    signalID=signalIDs(1);

                    if isSublabel
                        parentLabelAxesData(idx).MemberID=memberID;
                        parentLabelAxesData(idx).SignalID=signalID;
                        parentLabelAxesData(idx).LabelDefinitionID=parentLabelDefID;
                        parentLabelAxesData(idx).LabelDefinitionName=parentLblDef.labelDefinitionName;
                        parentLabelAxesData(idx).LabelType=parentLblDef.labelType;
                        parentLabelAxesData(idx).LabelDataType=parentLblDef.labelDataType;
                        if parentLblDef.labelDataType=="categorical"
                            parentLabelAxesData(idx).LabelDataCategories=parentLblDef.categories;
                        end
                        parentLabelAxesData(idx).isSublabel=false;
                        labelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,parentLabelDefID,memberID);
                        numInstance=numel(labelInstanceIDs);
                        parentLabelAxesData(idx).ParentLabelInstanceIDs=repmat("",numInstance,1);
                        parentLabelAxesData(idx).LabelInstanceValues=repmat("",numInstance,1);
                        parentLabelAxesData(idx).LabelInstanceTimeMinValues=nan(numInstance,1);
                        parentLabelAxesData(idx).LabelInstanceTimeMaxValues=nan(numInstance,1);
                        for kdx=1:numInstance
                            labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceIDs(kdx));
                            parentLabelAxesData(idx).LabelInstanceValues(kdx)=labelInstance.labelInstanceValue;
                            if parentLblDef.labelType=="point"
                                parentLabelAxesData(idx).LabelInstanceTimeMinValues(kdx)=labelInstance.labelInstanceTimeMin;
                            elseif parentLblDef.labelType=="roi"
                                parentLabelAxesData(idx).LabelInstanceTimeMinValues(kdx)=labelInstance.labelInstanceTimeMin;
                                parentLabelAxesData(idx).LabelInstanceTimeMaxValues(kdx)=labelInstance.labelInstanceTimeMax;
                            end
                        end
                        parentLabelAxesData(idx).LabelInstanceIDs=labelInstanceIDs;
                        parentLabelAxesData(idx).isVisible=true;
                        parentLabelAxesData(idx).isEditable=false;
                    end
                    axesData(idx).MemberID=memberID;
                    axesData(idx).SignalID=signalID;
                    axesData(idx).ParentLabelDefinitionID=parentLabelDefID;
                    axesData(idx).ParentLabelDefinitionName=parentLabelDefinitionName;
                    axesData(idx).LabelDefinitionID=this.EditableLabelDefintionsIDsInAutoLabelMode(lblDefIdx);
                    axesData(idx).LabelDefinitionName=lblDef.labelDefinitionName;
                    axesData(idx).LabelType=lblDef.labelType;
                    axesData(idx).LabelDataType=lblDef.labelDataType;
                    if lblDef.labelDataType=="categorical"
                        axesData(idx).LabelDataCategories=lblDef.categories;
                    end
                    axesData(idx).isSublabel=isSublabel;
                    axesData(idx).isVisible=true;
                    axesData(idx).isEditable=true;
                    if lblDef.labelType=="attribute"
                        labelInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,this.EditableLabelDefintionsIDsInAutoLabelMode(lblDefIdx),memberID);
                        numInstance=numel(labelInstanceIDs);
                        axesData(idx).LabelInstanceIDs=labelInstanceIDs;
                        axesData(idx).ParentLabelInstanceIDs=repmat("",numInstance,1);
                        axesData(idx).LabelInstanceValues=repmat("",numInstance,1);
                        axesData(idx).LabelInstanceTimeMinValues=nan(numInstance,1);
                        axesData(idx).LabelInstanceTimeMaxValues=nan(numInstance,1);
                        for kdx=1:numInstance
                            labelInstance=getLabelInstanceFromLabelInstanceID(this,labelInstanceIDs(kdx));
                            axesData(idx).ParentLabelInstanceIDs(kdx)=labelInstance.parentLabelInstanceID;
                            axesData(idx).LabelInstanceValues(kdx)=labelInstance.labelInstanceValue;
                        end
                    end
                end
            end
            axesOutData=[parentLabelAxesData;axesData];
        end



        function y=getDataStoreForApp(this)
            y=this.DataStoreForApp;
        end

        function setDataStoreForApp(this,ds)
            this.DataStoreForApp=ds;
        end

        function y=getAppDataMode(this)
            y=this.AppDataMode;
        end

        function setAppDataMode(this,appDataMode)
            this.AppDataMode=appDataMode;
        end

        function y=getFileModeSettings(this)
            y=this.FileModeSettings;
        end

        function setFileModeSettings(this,y)
            this.FileModeSettings=y;
        end

        function resetSettingOnNoMemberSignals(this)
            this.setAppDataMode('');
            this.FileModeSettings=struct('isFileExtensionsSpecified',false,...
            'isSignalVarNamesSpecified',false,...
            'isSampleRateVariableNameSpecified',false,...
            'isSampleTimeVariableNameSpecified',false,...
            'isTimeValuesVariableNameSpecified',false,...
            'isSampleRateSpecified',false,...
            'isSampleTimeSpecified',false,...
            'isTimeValuesSpecified',false,...
            'currentFileExtension','',...
            'dialogSettings',[]);
            this.setIsTimeSpecified([]);
            this.setDatastoreConstructor(@signalDatastore);
            this.DataStoreForApp=[];
            this.PlotSignalAfterLazyLoadComplete=false;
        end

        function y=getDatastoreConstructor(this)
            y=this.DatastoreConstructor;
        end

        function setDatastoreConstructor(this,datastoreConstructor)
            this.DatastoreConstructor=datastoreConstructor;
        end

        function y=isPlotSignalAfterLazyLoadComplete(this)
            y=this.PlotSignalAfterLazyLoadComplete;
        end

        function setPlotSignalAfterLazyLoadComplete(this,flag)
            this.PlotSignalAfterLazyLoadComplete=flag;
        end

        function[v,errStr]=evaluateValue(~,value,type,nonnegativeFlag)
            [v,errStr]=signal.sigappsshared.Utilities.evaluateValue(value,type,nonnegativeFlag);
        end

        function[flag,errObj]=validateNonUniformTimeValues(~,tv)

            errObj='';

            flag=signal.sigappsshared.Utilities.validateNonUniformTimeValues(sort(tv));

            if~flag
                errObj=message('SDI:sigAnalyzer:InvalidNonUnifSampledTime');
            end
        end

        function info=checkTimeMetadataForDataStore(this,timeDataOrVar,timeValuesType,isInputMustBeScalar)
            info.success=false;
            info.errorMsg="";
            info.data=[];
            info.isNewTimeValueCanBeConvertedToMatrix=false;
            isNewTimeValueCanBeConvertedToMatrix=true;

            if isInputMustBeScalar&&numel(timeDataOrVar)~=1
                info.success=false;
                return;
            end

            if any(ismissing(timeDataOrVar))
                info.success=false;
                return;
            end

            for idx=1:numel(timeDataOrVar)
                switch(timeValuesType)
                case "TimeValues"
                    if isnumeric(timeDataOrVar{idx})

                        tv=timeDataOrVar{idx};
                    else
                        [tv,errStr]=evaluateValue(this,timeDataOrVar{idx},'timevector',true);
                    end

                    isError=false;
                    if~isempty(errStr)
                        isError=true;
                    end
                    if length(tv)~=length(unique(tv))
                        errStr=getString(message('SDI:dialogs:TimeVectorUnique'));
                        isError=true;
                    end


                    if~isError&&~issorted(tv)
                        errStr=getString(message('SDI:dialogs:TimeVectorSorted'));
                        isError=true;
                    end

                    if~isError
                        [isValidNonUnifData,errObj]=this.validateNonUniformTimeValues(tv);
                        if~isValidNonUnifData
                            errStr=getString(message(errObj.Identifier));
                        end
                    end
                    if idx==1
                        info.data={};
                        firstTvLength=numel(tv);
                    elseif isNewTimeValueCanBeConvertedToMatrix&&firstTvLength~=numel(tv)
                        isNewTimeValueCanBeConvertedToMatrix=false;
                    end
                    if isempty(errStr)

                        info.data{end+1}=tv(:);
                        info.success=true;
                    else
                        info.errorMsg=errStr;
                        info.data=[];
                        info.success=false;
                        return;
                    end
                case{"SampleRate","SampleTime"}
                    [fsOrTs,errStr]=evaluateValue(this,timeDataOrVar{idx},'scalar',false);
                    if isempty(errStr)

                        info.data=[info.data;fsOrTs];
                        info.success=true;
                    else
                        info.errorMsg=errStr;
                        info.data=[];
                        info.success=false;
                        return;
                    end
                end
            end
            if isNewTimeValueCanBeConvertedToMatrix

                info.isNewTimeValueCanBeConvertedToMatrix=isNewTimeValueCanBeConvertedToMatrix;
            end
        end

        function info=isValidDataValue(this,values)
            if iscell(values)
                isAllValuesTimeTable=signal.sigappsshared.Utilities.checkAllInCellIsTimetable(values);
                isAnyValuesTimeTable=signal.sigappsshared.Utilities.checkAnyInCellIsTimetable(values);
                if~isAllValuesTimeTable&&isAnyValuesTimeTable

                    info.success=false;
                    info.errorMsg='InvalidData';
                    info.errorID='InvalidDataWithMixedTime';
                    return;
                end
            elseif istimetable(values)
                isAllValuesTimeTable=true;
                isAnyValuesTimeTable=true;
            else
                isAllValuesTimeTable=false;
                isAnyValuesTimeTable=false;
            end
            info.success=signal.sigappsshared.Utilities.checkNumericValue(values)||...
            signal.sigappsshared.Utilities.checkCellOfMatrix(values)||...
            signal.sigappsshared.Utilities.checkCellOfTimetables(values)||...
            signal.sigappsshared.Utilities.checkTimetable(values);
            if~info.success
                info.errorMsg='InvalidData';
                info.errorID='NonNumericData';
            else
                fileModeSettings=this.getFileModeSettings();
                isTimeInfoSpecified=fileModeSettings.isSampleRateSpecified||...
                fileModeSettings.isSampleTimeSpecified||...
                fileModeSettings.isTimeValuesSpecified||...
                fileModeSettings.isSampleRateVariableNameSpecified||...
                fileModeSettings.isSampleTimeVariableNameSpecified||...
                fileModeSettings.isTimeValuesVariableNameSpecified;
                appDataMode=this.getAppDataMode();
                if isTimeInfoSpecified&&isAnyValuesTimeTable

                    info.success=false;
                    info.errorMsg='InvalidData';
                    info.errorID='InvalidDataWithTime';
                    return;
                end
                if~isTimeInfoSpecified&&isAllValuesTimeTable


                    if iscell(values)
                        fs=signal.sigappsshared.Utilities.getAllFsOfTimetable(values);
                        if~all(fs==fs(1))
                            info.success=false;
                            info.errorMsg='InvalidData';
                            info.errorID='InvalidDataWithMixedTimeTable';
                        end
                    end
                end
                isAppTimeModeLocked=~isempty(appDataMode)&&~isempty(this.getIsTimeSpecified());
                if isAppTimeModeLocked&&this.getIsTimeSpecified()

                    if~isTimeInfoSpecified&&~isAllValuesTimeTable


                        info.success=false;
                        info.errorMsg='InvalidData';
                        info.errorID='InvalidDataWithOutTime';
                        return;
                    elseif isTimeInfoSpecified&&isAnyValuesTimeTable

                        info.success=false;
                        info.errorMsg='InvalidData';
                        info.errorID='InvalidDataWithTime';
                        return;
                    end
                elseif isAppTimeModeLocked&&isAnyValuesTimeTable

                    info.success=false;
                    info.errorMsg='InvalidData';
                    info.errorID='InvalidDataWithTime';
                    return;
                end
            end
        end

        function info=isValidTimeValue(~,value)
            info.success=false;
            info.TimeValues=value;
            try


                validateattributes(value,{'numeric','duration'},{'vector','real','finite'});
                info.success=true;
            catch e
                info.errorMsg=e.message;
                info.success=false;
                return;
            end

            if length(value)~=length(unique(value))
                info.errorMsg=getString(message('SDI:dialogs:TimeVectorUnique'));
                info.success=false;
                return;
            end


            if~issorted(value)
                info.errorMsg=getString(message('SDI:dialogs:TimeVectorSorted'));
                info.success=false;
                return;
            end


            isValidNonUnifData=signal.sigappsshared.Utilities.validateNonUniformTimeValues(sort(value));
            if~isValidNonUnifData
                info.errorMsg=getString(message('SDI:sigAnalyzer:InvalidNonUnifSampledTime'));
                info.success=false;
                return;
            end
            if isduration(value)
                info.TimeValues=seconds(value);
            end
        end

        function info=isValidTimeAndDatalength(~,data,time)
            info.success=false;
            if iscell(data)
                [row,~]=cellfun(@size,data);
                info.success=all(row==length(time));
            elseif isvector(data)
                info.success=(length(time)==length(data));
            else
                info.success=(length(time)==size(data,1));
            end
            if~info.success
                info.errorMsg=getString(message('SDI:dialogsLabeler:InvalidTimeMetadataTimeValuesSize'));
            end
        end

        function info=getMemberIDsRequiringLazyLoad(this,memberIDs)
            info.memberIDsForLazyLoad=[];
            info.memberIDsNotForLazyLoad=[];
            for idx=1:numel(memberIDs)
                memberID=memberIDs(idx);
                tmMode=this.getSignalTmMode(int32(memberID));
                if strcmp(tmMode,"file")&&isempty(this.getLeafSignalIDsForMemberID(memberID))
                    info.memberIDsForLazyLoad=[info.memberIDsForLazyLoad;memberID];
                else
                    info.memberIDsNotForLazyLoad=[info.memberIDsNotForLazyLoad;memberID];
                end
            end
        end

        function info=getDataFromDataStoreForMemberID(this,memberID)
            info.success=false;
            info.varsToImport=[];
            info.dataToImport=[];
            info.mode=[];
            info.Fs='';
            info.Ts='';
            info.St=0;
            info.Tv='';
            info.fileID=memberID;

            if strcmp(this.getAppDataMode(),'audioFile')

                [success,errMsg]=audio.labeler.internal.AudioModeController.checkoutAudioToolboxLicense();
                if~success
                    info.success=false;
                    info.fileName='';
                    info.varName='';
                    info.errorID='AudioToolboxLicenseFailedAtRead';
                    info.errorMsg=errMsg;
                    return;
                end
            end

            dataStore=this.getDataStoreForApp();
            signalObj=this.getSignalObj(memberID);
            fileIdx=strcmp(dataStore.Files,string(signalObj.Name));
            tempDataStore=subset(dataStore,fileIdx);
            w=warning('off');
            restoreWarn=onCleanup(@()warning(w));
            try
                [memberData,memberinfo]=tempDataStore.read();
                validationInfo=this.isValidDataValue(memberData);
                if~validationInfo.success
                    info.success=validationInfo.success;
                    info.fileName=tempDataStore.Files;
                    info.varName=memberinfo.SignalVariableNames;
                    info.errorMsg=validationInfo.errorMsg;
                    info.errorID=validationInfo.errorID;
                    return;
                end
                validationInfo.success=true;
                fileModeSettings=this.getFileModeSettings();
                if fileModeSettings.isSampleRateVariableNameSpecified
                    validationInfo=this.checkTimeMetadataForDataStore(string(memberinfo.SampleRate),'SampleRate',true);
                    validationInfo.errorID='InvalidSampleRate';
                    validationInfo.varName=tempDataStore.SampleRateVariableName;
                elseif fileModeSettings.isSampleTimeVariableNameSpecified
                    validationInfo=this.checkTimeMetadataForDataStore(string(memberinfo.SampleTime),'SampleTime',true);
                    validationInfo.errorID='InvalidSampleTime';
                    validationInfo.varName=tempDataStore.SampleTimeVariableName;
                elseif fileModeSettings.isTimeValuesVariableNameSpecified
                    validationInfo=this.isValidTimeValue(memberinfo.TimeValues);
                    if validationInfo.success
                        memberinfo.TimeValues=validationInfo.TimeValues;
                    end
                    validationInfo.errorID='InvalidTimeValues';
                    validationInfo.varName=tempDataStore.TimeValuesVariableName;
                end

                if validationInfo.success&&...
                    (fileModeSettings.isTimeValuesVariableNameSpecified||fileModeSettings.isTimeValuesSpecified)
                    validationInfo=this.isValidTimeAndDatalength(memberData,memberinfo.TimeValues);
                    validationInfo.errorID='InvalidDataAndTimeLength';
                    validationInfo.varName=memberinfo.SignalVariableNames;
                end

                if~validationInfo.success
                    info.success=validationInfo.success;
                    info.fileName=tempDataStore.Files;
                    info.varName=validationInfo.varName;
                    info.errorMsg=validationInfo.errorMsg;
                    info.errorID=validationInfo.errorID;
                    return;
                end
                info.success=true;
            catch ex
                info.success=false;
                info.fileName=tempDataStore.Files;
                info.varName='';
                info.errorID=this.parseErrorID(ex.identifier);
                info.errorMsg=ex.message;
                return;
            end
            if iscell(memberData)

                if isfield(memberinfo,'SignalVariableNames')
                    info.varsToImport=memberinfo.SignalVariableNames;
                else
                    info.varsToImport={char("channel"+1:numel(memberinfo.SignalVariableNames))};
                end
                info.dataToImport=memberData;
            else
                if isfield(memberinfo,'SignalVariableNames')
                    info.varsToImport={char(memberinfo.SignalVariableNames)};
                else
                    info.varsToImport={'channel'};
                end
                info.dataToImport={memberData};
            end
            if isfield(memberinfo,'SampleRate')
                info.Fs=memberinfo.SampleRate;
                info.mode='fs';
                isTimeSpecified=true;
            elseif isfield(memberinfo,'SampleTime')
                info.Ts=memberinfo.SampleTime;
                info.mode='ts';
                isTimeSpecified=true;
            elseif isfield(memberinfo,'TimeValues')
                info.Tv=memberinfo.TimeValues;
                info.mode='tv';
                isTimeSpecified=true;
            else
                if isa(memberData,'timetable')
                    info.mode='inherent';
                    isTimeSpecified=true;
                elseif iscell(memberData)&&isa(memberData{1},'timetable')
                    info.mode='inherent';
                    isTimeSpecified=true;
                else
                    info.mode='samples';
                    isTimeSpecified=false;
                end
            end
            if isempty(this.getIsTimeSpecified())
                this.setIsTimeSpecified(isTimeSpecified);
            end
        end

        function info=addImportedFilesToDataStore(this,dataFromImportDialog)
            info.success=false;
            info.errorMsg='';
            info.errorID='';
            info.newFileNames={};
            info.signalVarNames={};
            info.isSignalVarNamesInfile=false;
            info.mode=[];
            info.Fs='';
            info.Ts='';
            info.St='';
            info.Tv='';
            fileModeSettings=this.getFileModeSettings();
            inputDataFromImportDialog=dataFromImportDialog;
            fileNamesOrRegExp=dataFromImportDialog.fileNamesOrRegExp;
            if~iscell(dataFromImportDialog.fileNamesOrRegExp)

                fileNamesOrRegExp=signal.sigappsshared.Utilities.parseCommaSeperateStringAsCellOfStrings(dataFromImportDialog.fileNamesOrRegExp,true);
            end
            dataStoreArgsFromDialog={fileNamesOrRegExp};
            if fileModeSettings.isFileExtensionsSpecified||isfield(dataFromImportDialog,'extension')
                fileModeSettings.isFileExtensionsSpecified=true;
                dataStoreArgsFromDialog{end+1}='FileExtensions';
                dataStoreArgsFromDialog{end+1}=dataFromImportDialog.extension;
            elseif~isempty(fileModeSettings.currentFileExtension)



                dataStoreArgsFromDialog{end+1}='FileExtensions';
                dataStoreArgsFromDialog{end+1}=fileModeSettings.currentFileExtension;
            end
            if isfield(dataFromImportDialog,'includeSubFolders')
                dataStoreArgsFromDialog{end+1}='IncludeSubfolders';
                dataStoreArgsFromDialog{end+1}=dataFromImportDialog.includeSubFolders;
            end
            if fileModeSettings.isSignalVarNamesSpecified||isfield(dataFromImportDialog,'SignalVariableNames')
                fileModeSettings.isSignalVarNamesSpecified=true;
                dataStoreArgsFromDialog{end+1}='SignalVariableNames';
                dataFromImportDialog.SignalVariableNames=signal.sigappsshared.Utilities.parseCommaSeperateStringAsCellOfStrings(dataFromImportDialog.SignalVariableNames);
                dataStoreArgsFromDialog{end+1}=dataFromImportDialog.SignalVariableNames;
            end
            if(~isempty(this.FileModeSettings.dialogSettings)&&this.FileModeSettings.dialogSettings.timeMode=="time")...
                ||dataFromImportDialog.timeMode=="time"
                if fileModeSettings.isSampleRateVariableNameSpecified||isfield(dataFromImportDialog,'SampleRateVariableName')
                    fileModeSettings.isSampleRateVariableNameSpecified=true;
                    dataStoreArgsFromDialog{end+1}='SampleRateVariableName';
                    dataStoreArgsFromDialog{end+1}=dataFromImportDialog.SampleRateVariableName;
                elseif fileModeSettings.isSampleTimeVariableNameSpecified||isfield(dataFromImportDialog,'SampleTimeVariableName')
                    fileModeSettings.isSampleTimeVariableNameSpecified=true;
                    dataStoreArgsFromDialog{end+1}='SampleTimeVariableName';
                    dataStoreArgsFromDialog{end+1}=dataFromImportDialog.SampleTimeVariableName;
                elseif fileModeSettings.isTimeValuesVariableNameSpecified||isfield(dataFromImportDialog,'TimeValuesVariableName')
                    fileModeSettings.isTimeValuesVariableNameSpecified=true;
                    dataStoreArgsFromDialog{end+1}='TimeValuesVariableName';
                    dataStoreArgsFromDialog{end+1}=dataFromImportDialog.TimeValuesVariableName;
                elseif fileModeSettings.isSampleRateSpecified||isfield(dataFromImportDialog,'SampleRate')
                    fileModeSettings.isSampleRateSpecified=true;
                    dataStoreArgsFromDialog{end+1}='SampleRate';
                    sampleRate=signal.sigappsshared.Utilities.parseCommaSeperateStringAsCellOfStrings(dataFromImportDialog.SampleRate);
                    timeDataInfo=this.checkTimeMetadataForDataStore(sampleRate,'SampleRate',false);
                    if~timeDataInfo.success
                        info.success=false;
                        info.errorMsg=timeDataInfo.errorMsg;
                        info.errorType='TimeMetaDataCheckFailed';
                        return;
                    end
                    sampleRate=timeDataInfo.data;
                    m=signal.sigappsshared.Utilities.getFrequencyMultiplier(lower(dataFromImportDialog.units));
                    dataFromImportDialog.SampleRate=sampleRate*m;
                    dataStoreArgsFromDialog{end+1}=dataFromImportDialog.SampleRate;
                elseif fileModeSettings.isSampleTimeSpecified||isfield(dataFromImportDialog,'SampleTime')
                    fileModeSettings.isSampleTimeSpecified=true;
                    dataStoreArgsFromDialog{end+1}='SampleTime';
                    sampleTime=signal.sigappsshared.Utilities.parseCommaSeperateStringAsCellOfStrings(dataFromImportDialog.SampleTime);
                    timeDataInfo=this.checkTimeMetadataForDataStore(sampleTime,'SampleTime',false);
                    if~timeDataInfo.success
                        info.success=false;
                        info.errorMsg=timeDataInfo.errorMsg;
                        info.errorType='TimeMetaDataCheckFailed';
                        return;
                    end
                    sampleTime=timeDataInfo.data;
                    m=signal.sigappsshared.Utilities.getTimeMultiplier(lower(dataFromImportDialog.units));
                    dataFromImportDialog.SampleTime=sampleTime.*m;
                    dataStoreArgsFromDialog{end+1}=dataFromImportDialog.SampleTime;
                elseif fileModeSettings.isTimeValuesSpecified||isfield(dataFromImportDialog,'TimeValues')
                    fileModeSettings.isTimeValuesSpecified=true;
                    dataStoreArgsFromDialog{end+1}='TimeValues';
                    timeValues=signal.sigappsshared.Utilities.parseCommaSeperateStringAsCellOfStrings(dataFromImportDialog.TimeValues);
                    timeDataInfo=this.checkTimeMetadataForDataStore(timeValues,'TimeValues',false);
                    if~timeDataInfo.success
                        info.success=false;
                        info.errorMsg=timeDataInfo.errorMsg;
                        info.errorType='TimeMetaDataCheckFailed';
                        return;
                    end
                    dataFromImportDialog.TimeValues=timeDataInfo.data;


                    if timeDataInfo.isNewTimeValueCanBeConvertedToMatrix
                        timeValues=cell2mat(dataFromImportDialog.TimeValues);
                    else
                        timeValues=timeDataInfo.data;
                    end
                    dataStoreArgsFromDialog{end+1}=timeValues;
                end
            end
            try
                datastoreConstructor=this.getDatastoreConstructor();
                dataStoreForArgsFromDialog=datastoreConstructor(dataStoreArgsFromDialog{:});
                if numel(unique(dataStoreForArgsFromDialog.Files))~=numel(dataStoreForArgsFromDialog.Files)
                    info.success=false;
                    info.errorID='InvalidMergeMembers';
                    info.errorMsg='';
                    info.errorType='DataStoreCreationFailed';
                    return;
                end
                info.newFileNames=dataStoreForArgsFromDialog.Files;
                info.success=true;
            catch ex
                info.success=false;
                info.errorID=this.parseErrorID(ex.identifier);
                info.errorMsg=ex.message;
                info.errorType='DataStoreCreationFailed';
                return;
            end
            info.signalVarNames={};

            [isSuccess,errorID]=this.updateDataStore(dataStoreForArgsFromDialog);
            if~isSuccess

                info.success=false;
                info.errorID=errorID;
                info.errorMsg='';
                info.errorType='DataStoreCreationFailed';
                return;
            end
            if isempty(this.FileModeSettings.dialogSettings)
                fileModeSettings.dialogSettings=inputDataFromImportDialog;



                if~fileModeSettings.isFileExtensionsSpecified&&strcmp(inputDataFromImportDialog.appDataMode,'signalFile')
                    fileModeSettings.currentFileExtension=this.getFileExtension(dataStoreForArgsFromDialog.Files{1});
                end
                this.FileModeSettings=fileModeSettings;
            end
            if this.FileModeSettings.dialogSettings.timeMode~="none"

                this.setIsTimeSpecified(this.FileModeSettings.dialogSettings.timeMode~="samples");
            end
        end

        function info=removeImportedFilesFromDataStore(this,memberID)
            signalObj=this.getSignalObj(memberID);
            dataStoreForApp=this.getDataStoreForApp();
            if numel(dataStoreForApp.Files)==1
                this.DataStoreForApp=[];
                info.success=true;
                return;
            end
            fileIdx=strcmp(dataStoreForApp.Files,string(signalObj.Name));
            this.DataStoreForApp=subset(dataStoreForApp,~fileIdx);
            info.success=true;
        end

        function[isSuccess,exceptionKeyword]=updateDataStore(this,dataStoreToAdd)
            dataStoreForApp=this.getDataStoreForApp();
            isSuccess=false;
            exceptionKeyword='';
            if~isempty(dataStoreForApp)
                try

                    mergerLSS=labeledSignalSet(dataStoreForApp).merge(labeledSignalSet(dataStoreToAdd));
                    dataStoreForApp=mergerLSS.getPrivateSourceData();
                    isSuccess=true;
                    exceptionKeyword="";
                catch ex
                    exceptionKeyword=this.parseErrorID(ex.identifier);
                    isSuccess=false;
                end
                if isSuccess
                    this.DataStoreForApp=dataStoreForApp;
                end
            elseif this.getAppDataMode()~="inMemory"
                this.DataStoreForApp=dataStoreToAdd;
                isSuccess=true;
            end
        end

        function[isSuccess,exceptionKeyword]=updateDataStoreAndFileModeSettings(this,dataStoreToAdd)
            [isSuccess,exceptionKeyword]=this.updateDataStore(dataStoreToAdd);
            fileModeSettings=this.getFileModeSettings();
            if isSuccess&&isempty(fileModeSettings.dialogSettings)&&isa(dataStoreToAdd,"signalDatastore")
                inputDataFromImportDialog=struct('fileNamesOrRegExp','',...
                'extension','',...
                'timeMode','none',...
                'includeSubFolders',0);
                validProps=dataStoreToAdd.getCurrentValidProps();
                if any(validProps=="SignalVariableNames")
                    fileModeSettings.isSignalVarNamesSpecified=true;
                    inputDataFromImportDialog.SignalVariableNames=signal.sigappsshared.Utilities.convertToCommaSeperateString(dataStoreToAdd.SignalVariableNames);
                end
                if any(validProps=="SampleRateVariableName")
                    fileModeSettings.isSampleRateVariableNameSpecified=true;
                    inputDataFromImportDialog.SampleRateVariableName=dataStoreToAdd.SampleRateVariableName;
                    inputDataFromImportDialog.timeMode='time';
                elseif any(validProps=="SampleTimeVariableName")
                    fileModeSettings.isSampleTimeVariableNameSpecified=true;
                    inputDataFromImportDialog.SampleTimeVariableName=dataStoreToAdd.SampleTimeVariableName;
                    inputDataFromImportDialog.timeMode='time';
                elseif any(validProps=="TimeValuesVariableName")
                    fileModeSettings.isTimeValuesVariableNameSpecified=true;
                    inputDataFromImportDialog.TimeValuesVariableName=dataStoreToAdd.TimeValuesVariableName;
                    inputDataFromImportDialog.timeMode='time';
                elseif any(validProps=="SampleRate")
                    fileModeSettings.isSampleRateSpecified=true;

                    inputDataFromImportDialog.SampleRate='';
                    inputDataFromImportDialog.units='Hz';
                    inputDataFromImportDialog.timeMode='time';
                elseif any(validProps=="SampleTime")
                    fileModeSettings.isSampleTimeSpecified=true;

                    inputDataFromImportDialog.SampleTime='';
                    inputDataFromImportDialog.units='s';
                    inputDataFromImportDialog.timeMode='time';
                elseif any(validProps=="TimeValues")
                    fileModeSettings.isTimeValuesSpecified=true;

                    inputDataFromImportDialog.TimeValues='';
                    inputDataFromImportDialog.timeMode='time';
                end



                if~fileModeSettings.isFileExtensionsSpecified
                    fileModeSettings.currentFileExtension=this.getFileExtension(dataStoreToAdd.Files{1});
                end
                if inputDataFromImportDialog.timeMode~="none"

                    this.setIsTimeSpecified(inputDataFromImportDialog.timeMode~="samples");
                end

                fileModeSettings.dialogSettings=inputDataFromImportDialog;
                this.FileModeSettings=fileModeSettings;
            elseif isSuccess&&isa(dataStoreToAdd,"audioDatastore")
                fileModeSettings.isSampleRateSpecified=true;
                this.FileModeSettings=fileModeSettings;
            end
        end


        function lblDef=getLabelDefFromLabelDefID(this,labelDefID)
            lblDef=this.Mf0LabelDataRepository.labelDefinitions.getByKey(labelDefID);
        end

        function[parentlblDef,isSublabel]=getParentLabelDefOfLabelDef(this,lblInfo)



            parentLabelDefID=lblInfo.parentLabelDefinitionID;
            isSublabel=~isemptyString(this,parentLabelDefID);
            if isSublabel
                parentlblDef=getLabelDefFromLabelDefID(this,parentLabelDefID);
            else
                parentlblDef=struct('labelDefinitionID','',...
                'labelDefinitionName','');
            end
        end

        function childrenLabelDefIDs=getChildrenLabelDefIDs(~,lblDef)
            childrenLabelDefIDs=string(lblDef.childerenLabelDefinitionIDs.toArray);
        end

        function attChildrenLabelDefIDs=getAttributeChildrenLabelDefIDs(this,lblDef)
            attChildrenLabelDefIDs=[];
            if(lblDef.childerenLabelDefinitionIDs.Size==0)
                return;
            end
            childrenLabelDefIDs=getChildrenLabelDefIDs(this,lblDef);
            for idx=1:numel(childrenLabelDefIDs)
                currentLabelDefID=childrenLabelDefIDs(idx);
                childLblDef=getLabelDefFromLabelDefID(this,currentLabelDefID);
                if childLblDef.labelType=="attribute"
                    attChildrenLabelDefIDs=[attChildrenLabelDefIDs;currentLabelDefID];
                end
            end
        end

        function lblDefIDs=getAllParentLabelDefinitionIDs(this)
            lblDefIDs=string(this.Mf0LabelDataRepository.parentLabelDefinitionIDs.toArray);
        end

        function lblDefIDs=getAllLabelDefinitionIDs(this)

            parentLblDefIDs=string(this.Mf0LabelDataRepository.parentLabelDefinitionIDs.toArray);
            lblDefIDs=[];
            for idx=1:numel(parentLblDefIDs)
                if idx==1
                    lblDefIDs=parentLblDefIDs(idx);
                else
                    lblDefIDs=[lblDefIDs,parentLblDefIDs(idx)];
                end
                parentLblDef=getLabelDefFromLabelDefID(this,parentLblDefIDs(idx));
                childrenLabelDefIDs=getChildrenLabelDefIDs(this,parentLblDef);
                lblDefIDs=[lblDefIDs,childrenLabelDefIDs];
            end
        end

        function flag=isHaveLabelDefWithLabelDefName(this,labelDefName,parentLabelDefID)
            lblDefID=signallabelereng.datamodel.getLabelDefIDForLabelDefNameAndParentLabelDefID(this.Mf0DataModel,labelDefName,parentLabelDefID);
            flag=~isemptyString(this,lblDefID);
        end

        function lblDef=getParentLabelDefinitionFromLabelDefName(this,name)

            lblDef=[];
            if isAppHasLabelsDef(this)
                lblDefID=signallabelereng.datamodel.getLabelDefIDForLabelDefNameAndParentLabelDefID(this.Mf0DataModel,name,"");
                if~isemptyString(this,lblDefID)
                    lblDef=getLabelDefFromLabelDefID(this,lblDefID);
                end
            end
        end

        function lblDefs=getAllSignalLabelDefinitions(this)
            lblDefs=[];
            lblDefIDs=getAllParentLabelDefinitionIDs(this);
            for idx=1:numel(lblDefIDs)
                lblDefs=[lblDefs;convertToSignalLabelDefinition(this,lblDefIDs(idx),false)];
            end
        end

        function[flag,errorID,uniqueLabelDefs]=validateCompatibleLabelDefinitionsForMerge(this,newParentLblDefs)




            flag=true;
            uniqueLabelDefs=[];
            errorID="";
            for k=1:numel(newParentLblDefs)

                newLblDef=newParentLblDefs(k);
                unsupportedFlag=any(strcmp(newLblDef.LabelDataType,"timetable"))||any(strcmp(newLblDef.LabelDataType,"table"));
                if unsupportedFlag
                    flag=false;
                    errorID='UnsupportedLabelDefinitions';
                    return;
                end
                currentModelLblDef=getParentLabelDefinitionFromLabelDefName(this,newLblDef.Name);
                if~isempty(currentModelLblDef)
                    currentLblDef=convertToSignalLabelDefinition(this,currentModelLblDef,true);
                    if~isempty(currentLblDef)
                        if~compareDefinitions(currentLblDef,newLblDef)
                            flag=false;
                            errorID='UnequalLabelDefinitionValues';
                            return;
                        end

                    end
                elseif nargout==3
                    uniqueLabelDefs=[uniqueLabelDefs;newLblDef];
                end
            end
        end

        function lblDef=convertToSignalLabelDefinition(this,mf0LblDefOrID,isDef)
            if~isDef
                mf0LblDef=this.getLabelDefFromLabelDefID(mf0LblDefOrID);
            else
                mf0LblDef=mf0LblDefOrID;
            end
            labelType=mf0LblDef.labelType;
            isROIFeature=false;
            if mf0LblDef.isFeature
                if labelType=="roi"
                    labelType="roiFeature";
                    isROIFeature=true;
                else
                    labelType="attributeFeature";
                end
            end
            if isROIFeature
                if mf0LblDef.framePolicyType=="framerate"
                    if string(mf0LblDef.labelDataType)=="categorical"
                        lblDef=signalLabelDefinition(mf0LblDef.labelDefinitionName,...
                        'LabelType',labelType,...
                        'LabelDataType','categorical',...
                        'FrameSize',mf0LblDef.frameSize,...
                        'FrameRate',mf0LblDef.frameRateOrOverlapLength,...
                        'Categories',string(mf0LblDef.categories));
                    else
                        lblDef=signalLabelDefinition(mf0LblDef.labelDefinitionName,...
                        'LabelType',labelType,...
                        'FrameSize',mf0LblDef.frameSize,...
                        'FrameRate',mf0LblDef.frameRateOrOverlapLength,...
                        'LabelDataType',mf0LblDef.labelDataType);
                    end
                else
                    if string(mf0LblDef.labelDataType)=="categorical"
                        lblDef=signalLabelDefinition(mf0LblDef.labelDefinitionName,...
                        'LabelType',labelType,...
                        'LabelDataType','categorical',...
                        'FrameSize',mf0LblDef.frameSize,...
                        'FrameOverlapLength',mf0LblDef.frameRateOrOverlapLength,...
                        'Categories',string(mf0LblDef.categories));
                    else
                        lblDef=signalLabelDefinition(mf0LblDef.labelDefinitionName,...
                        'LabelType',labelType,...
                        'FrameSize',mf0LblDef.frameSize,...
                        'FrameOverlapLength',mf0LblDef.frameRateOrOverlapLength,...
                        'LabelDataType',mf0LblDef.labelDataType);
                    end
                end
            else
                if string(mf0LblDef.labelDataType)=="categorical"
                    lblDef=signalLabelDefinition(mf0LblDef.labelDefinitionName,...
                    'LabelType',labelType,...
                    'LabelDataType','categorical',...
                    'Categories',string(mf0LblDef.categories));
                else
                    lblDef=signalLabelDefinition(mf0LblDef.labelDefinitionName,...
                    'LabelType',labelType,...
                    'LabelDataType',mf0LblDef.labelDataType);
                end
            end
            lblDef.Description=mf0LblDef.description;
            lblDef.DefaultValue=formatValueForLSS(this,mf0LblDef.defaultValue,mf0LblDef.labelDataType);
            childLblDefIDs=string(mf0LblDef.childerenLabelDefinitionIDs.toArray);
            for idx=1:numel(childLblDefIDs)
                mf0ChildLblDef=this.getLabelDefFromLabelDefID(childLblDefIDs(idx));
                childLblDef=convertToSignalLabelDefinition(this,mf0ChildLblDef,true);
                lblDef.Sublabels=[lblDef.Sublabels;childLblDef];
            end
        end

        function lblInstanceIDs=getLabelInstaceIDsForLabelDefIDAndMemberID(this,labelDefID,memberID)

            lblInstanceIDs=string(signallabelereng.datamodel.getLabelInstaceIDsForLabelDefIDAndMemberID(...
            this.Mf0DataModel,labelDefID,memberID));
            if lblInstanceIDs(1)==""
                lblInstanceIDs=string.empty;
            end
        end

        function lblInstanceIDs=getLabelInstaceIDsForMemberID(this,memberID)

            lblInstanceIDs=string(signallabelereng.datamodel.getLabelInstaceIDsForMemberID(...
            this.Mf0DataModel,memberID));
            if lblInstanceIDs(1)==""
                lblInstanceIDs=string.empty;
            end
        end

        function lblInstanceIDs=getLabelInstanceIDsForLabelDefIDAndParentInstanceID(this,labelDefID,memberID,parentInstanceID)

            lblInstanceIDs=string(signallabelereng.datamodel.getLabelInstanceIDsForLabelDefIDAndParentInstanceID(...
            this.Mf0DataModel,labelDefID,memberID,parentInstanceID));
            if lblInstanceIDs(1)==""
                lblInstanceIDs=string.empty;
            end
        end

        function lblInstanceIDs=getLabelInstanceIDsForParentLabelInstanceID(this,parentLblInstanceID)

            lblInstanceIDs=string(signallabelereng.datamodel.getLabelInstanceIDsForParentLabelInstanceID(...
            this.Mf0DataModel,parentLblInstanceID));
            if lblInstanceIDs(1)==""
                lblInstanceIDs=string.empty;
            end
        end

        function lblInstance=getLabelInstanceFromLabelInstanceID(this,instanceID)
            lblInstance=this.Mf0DataModel.findElement(instanceID);
        end

        function dataStruct=getMf0LabelDataStruct(~)

            dataStruct=struct('memberID','',...
            'labelDefinitionID','',...
            'parentLabelInstanceID','',...
            'labelInstanceID','',...
            'labelInstanceValue','',...
            'isPlottedInTimeAxes',false,...
            'labelInstanceTimeMin',[],...
            'labelInstanceTimeMax',[]);
        end

        function labelInstanceID=createInstanceInMf0Model(this,labelDataForMF0)
            labelDataForMF0.labelInstanceNumericValue=str2double(labelDataForMF0.labelInstanceValue);
            lblInst=this.Mf0LabelDataRepository.createIntoLabelInstances(labelDataForMF0);

            labelInstanceID=string(lblInst.UUID);
            lblInst.labelInstanceID=labelInstanceID;
        end

        function signalID=getFirstCheckedSignalIDInMember(this,memberID)
            signalIDs=getCheckedSignalIDsInMember(this,memberID);
            if isempty(signalIDs)
                signalID=[];
            else
                signalID=signalIDs(1);
            end
        end

        function flag=isemptyString(~,str)
            str=string(str);
            flag=isempty(str)||str=="";
        end

        function[valuesOut,isDataValueEmptyOrMissing]=formatValueForClient(~,values,valueType,isDataFromLSS)
            if nargin<4
                isDataFromLSS=false;
            end
            isDataValueEmptyOrMissing=false;
            if isDataFromLSS&&isempty(values)
                valuesOut="";
                isDataValueEmptyOrMissing=true;
                return;
            end
            if isDataFromLSS
                if valueType=="numeric"
                    if ismissing(values)
                        valuesOut="";
                    else

                        valuesOut=sprintf("%.20g",values);
                    end
                else
                    if(valueType=="categorical"&&isundefined(values))||ismissing(values)
                        valuesOut="";
                    else
                        valuesOut=string(values);
                    end
                end
            else
                valuesOut=string(values);
            end
            if isDataFromLSS
                valuesOut(isempty(valuesOut))="";
                valuesOut(ismissing(valuesOut))="";
            end
        end
    end



    methods(Access=protected)

        function y=getFileExtension(~,fullFileName)
            parsedValues=strsplit(fullFileName,'.');
            y=['.',parsedValues{end}];
        end

        function y=parseErrorID(~,errorIdentifier)
            parsedValues=strsplit(errorIdentifier,':');
            y=parsedValues{end};
        end

        function[value,info]=formatValueForLSS(~,valueString,dataType)

            info.successFlag=true;
            info.exception="";
            if isempty(valueString)||string(valueString)==""
                value=[];
                return;
            end
            if dataType=="numeric"


                if isnumeric(valueString)
                    value=valueString;
                else
                    value=str2double(valueString);
                    if isnan(value)
                        info.successFlag=false;
                        info.exception="MustBeNumeric";
                    end
                end
            elseif dataType=="logical"
                if string(valueString)=="true"||string(valueString)=="1"
                    value=true;
                else
                    value=false;
                end
            else
                value=string(valueString);
            end
        end



        function ID=getHeaderID(this,labelDefID,memberID,parentInstanceID)

            if nargin<4||isemptyString(this,parentInstanceID)
                ID=memberID+"_"+labelDefID+"_";
            else
                ID=memberID+"_"+labelDefID+"_"+parentInstanceID+"_";
            end

        end

        function signalIDs=getSignalIDForMemberID(this,signalIDs,memberID)


            memberIDsForSigIDs=getMemberIDForSignalID(this,signalIDs);
            memberIdx=(memberIDsForSigIDs==memberID);
            signalIDs=signalIDs(memberIdx);
        end

        function signalIDs=getMemberSignals(this,memberID)

            if~strcmp(this.getAppName(),'autoLabelMode')
                childrenSignals=getLeafSignalIDsForMemberID(this,memberID);
            else
                childrenSignals=getLeafSignalIDsForMemberIDInAutoLabelMode(this,memberID);
            end
            if isempty(childrenSignals)
                signalIDs=double(memberID);
            else
                signalIDs=childrenSignals(:);
            end
        end

        function signalID=getFirstMemberSignal(this,memberID)
            callback=this.getCheckedSignalIDsCallback();
            signalID=callback(string(memberID));
        end

        function signalID=getFirstSignalIDInMember(this,memberID)


            signalID=getFirstCheckedSignalIDInMember(this,memberID);
            if isempty(signalID)
                signalIDs=getMemberSignals(this,memberID);
                signalID=signalIDs(1);
            end
        end


        function parentID=getTreeTableParentID(this,isSublabel,labelType,lblDefID,memberID,parentLabelInstanceID)

            if isSublabel
                if labelType=="attribute"
                    parentID=parentLabelInstanceID;
                else
                    parentID=getHeaderID(this,lblDefID,memberID,parentLabelInstanceID);
                end
            else
                if labelType=="attribute"
                    parentID=memberID;
                else
                    parentID=getHeaderID(this,lblDefID,memberID);
                end
            end
        end

        function treeTableDataStruct=getTreeTableDataStruct(~)
















            treeTableDataStruct=struct(...
            'parentID','',...
            'rowID','',...
            'SignalID',[],...
            'MemberID',[],...
            'nameCol','',...
            'nameColTooltip','',...
            'valueCol','',...
            'tMinCol','',...
            'tMaxCol','',...
            'timeCol','',...
            'rowDataType','',...
            'isExpanded','',...
            'isChecked',false,...
            'hasChildren',false);
        end

        function axesDataStruct=getAxesDataStruct(~)

            axesDataStruct=struct(...
            'chunckPart',1,...
            'totalChuncks',1,...
            'MemberID','',...
            'SignalID','',...
            'ParentLabelDefinitionID','',...
            'ParentLabelDefinitionName','',...
            'LabelDefinitionID','',...
            'LabelDefinitionName','',...
            'LabelType','',...
            'LabelDataType','',...
            'LabelDataCategories',[],...
            'isSublabel','',...
            'ParentLabelInstanceIDs',[],...
            'LabelInstanceIDs',[],...
            'LabelInstanceValues',[],...
            'LabelInstanceTimeMinValues',[],...
            'LabelInstanceTimeMaxValues',[]);
        end

        function treeTableDataStruct=getAutoLableDialogTreeTableDataStruct(~)











            treeTableDataStruct=struct(...
            'parent','',...
            'id','',...
            'SignalID',[],...
            'MemberID',[],...
            'Name','',...
            'rowDataType','',...
            'isFirstChild',false,...
            'hasChildren',false);
        end

        function signalIDs=getSignalIDsFromSignalInfo(~,signalInfo,memberID)


            signalIDs=signalInfo.("x"+memberID);
        end

        function signalData=getSignalData(this,signalIDs,runTimeLimits)
            numOfSignalIDs=numel(signalIDs);
            [isConversionToCellArrayNeeded,firstSignalLength,indexVector]=this.verifySignalLength(signalIDs,runTimeLimits);
            if isConversionToCellArrayNeeded
                signalData.Data{numOfSignalIDs}=cell(0,numOfSignalIDs);
                signalData.Time{numOfSignalIDs}=cell(0,numOfSignalIDs);
            else
                signalData.Data=zeros(firstSignalLength,numOfSignalIDs);
                signalData.Time=zeros(firstSignalLength,numOfSignalIDs);
            end
            for idx=1:numOfSignalIDs
                data=this.getSignalValue(signalIDs(idx));
                if(~isempty(runTimeLimits))
                    if isConversionToCellArrayNeeded


                        indexVector=this.getDataIdxForRunTimeLimits(data.Time,runTimeLimits);
                    end
                    sigData=data.Data(indexVector);
                    sigTime=data.Time(indexVector);
                else
                    sigData=data.Data;
                    sigTime=data.Time;
                end
                if isConversionToCellArrayNeeded
                    signalData.Data{:,idx}=sigData(:);
                    signalData.Time{:,idx}=sigTime(:);
                else
                    signalData.Data(:,idx)=sigData(:);
                    signalData.Time(:,idx)=sigTime(:);
                end
            end
        end

        function[flag,firstSignalLength,indexVector]=verifySignalLength(this,signalIDs,runTimeLimits)
            flag=false;
            indexVector=[];
            for idx=1:numel(signalIDs)
                currentSignalLength=this.Engine.getSignalTmNumPoints(signalIDs(idx));
                if idx==1
                    firstSignalLength=currentSignalLength;
                end
                if firstSignalLength~=currentSignalLength
                    flag=true;
                    return;
                end
            end
            if~isempty(signalIDs)&&~isempty(runTimeLimits)


                data=this.getSignalValue(signalIDs(1));
                indexVector=this.getDataIdxForRunTimeLimits(data.Time,runTimeLimits);
                firstSignalLength=sum(indexVector);
            end
        end

        function indexVector=getDataIdxForRunTimeLimits(~,timeData,runTimeLimits)
            tStart=runTimeLimits(1);
            tEnd=runTimeLimits(2);
            indexVector=timeData>=tStart&timeData<=tEnd;
        end

        function uuid=generateUUID(~)
            uuid=matlab.lang.internal.uuid();
        end
    end
    methods(Static)
        function dmrFileName=generateDmrFileName()
            dmrFileName=fullfile(tempdir,'signalLabeler_'+matlab.lang.internal.uuid()+".dmr");
        end
    end
end
