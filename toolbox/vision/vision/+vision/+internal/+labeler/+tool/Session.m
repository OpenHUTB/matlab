






classdef Session<handle

    properties

        IsChanged logical



FileName

PixelLabelDataPath

TempDirectory

        ROILabelSet vision.internal.labeler.ROILabelSet

        ROISublabelSet vision.internal.labeler.ROISublabelSet

        ROIAttributeSet vision.internal.labeler.ROIAttributeSet

        FrameLabelSet vision.internal.labeler.FrameLabelSet

ROIAnnotations

FrameAnnotations


        AlgorithmInstances={};
    end

    properties(SetAccess=protected)
        ShowROILabelMode='hover'
    end


    properties(Dependent,SetAccess=private)
HasROILabels
NumROILabels
HasFrameLabels
NumFrameLabels
NumROISublabels
NumAttributes
    end


    properties(Access=protected,Hidden)
        Version;
    end




    methods

        function this=Session()
            this.reset();
        end


        function set.Version(this,~)
            value=getVersion(this);
            this.Version=value;
        end


        function v=get.Version(this)
            v=getVersion(this);
        end
    end




    methods(Abstract,Access=protected)
        value=getVersion(this);
    end




    methods
        function reset(this)

            this.FileName=[];
            this.ROILabelSet=vision.internal.labeler.ROILabelSet;
            this.ROISublabelSet=vision.internal.labeler.ROISublabelSet;
            this.ROIAttributeSet=vision.internal.labeler.ROIAttributeSet;
            this.ROIAnnotations=vision.internal.labeler.ROIAnnotationSet(this.ROILabelSet,this.ROISublabelSet,this.ROIAttributeSet);
            this.AlgorithmInstances={};



            resetIsPixelLabelChangedAll(this);

            this.FrameLabelSet=vision.internal.labeler.FrameLabelSet;
            this.FrameAnnotations=vision.internal.labeler.FrameAnnotationSet(this.FrameLabelSet);

            this.resetTempDirectory();
            this.IsChanged=false;
        end

        function setIsPixelLabelChangedAll(this)
            setIsPixelLabelChangedAll(this.ROIAnnotations);
        end

        function resetIsPixelLabelChangedAll(this)
            resetIsPixelLabelChangedAll(this.ROIAnnotations);
        end
    end

    methods(Access=private)
        function renameLabelForSublabel(this,oldLabelName,newLabelName)
            roiSublabels=queryROISublabelFamilyNames(this,oldLabelName);
            for i=1:numel(roiSublabels)

                this.ROISublabelSet.renameLabelForSublabel(oldLabelName,newLabelName,roiSublabels{i});
            end
        end
    end



    methods

        function showROILabelMode=get.ShowROILabelMode(this)
            showROILabelMode=this.ShowROILabelMode;
        end


        function setLabelVisiblityInSession(this,val)
            this.ShowROILabelMode=val;
        end


        function s=removaLabelname(~,labelName,s)
            if isfield(s,labelName)
                s=s.(labelName);
            end
        end


        function roiLabelDef=updateAttributes(this,roiLabelDef)
            thisLabelName=roiLabelDef.Label;
            thisLabelType=roiLabelDef.ROI;
            if(thisLabelType~=labelType.PixelLabel)
                attributeDefs=this.ROIAttributeSet.exportDef2struct(thisLabelName,'');
                attribS=[];
                attribS=appendAtributeofLabelToStruct(this,attribS,thisLabelName,attributeDefs);

                attribS=removaLabelname(this,thisLabelName,attribS);
                roiLabelDef.Attributes=attribS;
            end
        end


        function roiLabelDef=updateAttributesInStrct(this,roiLabelDef)
            thisLabelName=roiLabelDef.Name;

            attributeDefs=this.ROIAttributeSet.exportDef2struct(thisLabelName,'');
            attribS=[];
            attribS=appendAtributeofLabelToStruct(this,attribS,thisLabelName,attributeDefs);

            attribS=removaLabelname(this,thisLabelName,attribS);

            roiLabelDef.Attributes=attribS;
        end


        function roiLabel=appendAttributeDef(this,roiLabel)
            if hasAttributeDefined(this,roiLabel.Label)
                roiLabel=updateAttributes(this,roiLabel);
            end
        end


        function roiLabel=appendAttributeDefInStrct(this,roiLabel)
            if hasAttributeDefined(this,roiLabel.Name)
                roiLabel=updateAttributesInStrct(this,roiLabel);
            end
        end


        function[roiLabels,frameLabels]=getLabelDefinitions(this)




            import vision.internal.labeler.*;

            numROILabels=this.ROILabelSet.NumLabels;
            roiLabels=repmat(ROILabel(labelType.empty,'','',''),1,numROILabels);
            for n=1:numROILabels
                roiLabels(n)=this.ROILabelSet.queryLabel(n);
                roiLabels(n)=appendAttributeDef(this,roiLabels(n));
            end

            numFrameLabels=this.FrameLabelSet.NumLabels;
            frameLabels=repmat(FrameLabel('','',''),1,numFrameLabels);
            for n=1:numFrameLabels
                frameLabels(n)=this.FrameLabelSet.queryLabel(n);
            end
        end


        function isValid=isValidName(this,labelName)
            currROILabelNames={this.ROILabelSet.DefinitionStruct.Name};
            currFrameLabelNames={this.FrameLabelSet.DefinitionStruct.Name};
            isValid=isempty(find(strcmp(currROILabelNames,labelName),1))&&isempty(find(strcmp(currFrameLabelNames,labelName),1));
        end


        function gotMatch=hasMatchingName(array,name)
            gotMatch=false;
            for i=1:length(array)
                if strcmpi(array(i).Name,name)
                    gotMatch=true;
                    return;
                end
            end
        end

        function name=formMaskFileName(this,signalName,idx)
            signalName4Tool=getConvertedSignalName(this,signalName);
            name=sprintf('Label_%d.png',idx);
            if~isempty(signalName4Tool)
                name=[char(signalName4Tool),'_',name];
            end
        end

        function addAlgorithmLabels(this,signalName,t,index,labelData)



            if isempty(labelData)
                return;
            end

            index=max(index,1);

            if istable(labelData)
                labelData=table2struct(labelData);
            end

            if iscategorical(labelData)

                try
                    filename=fullfile(this.TempDirectory,formMaskFileName(this,signalName,index));
                    L=imread(filename);



                    lsz=size(L);
                    sz=size(labelData);
                    if~isequal(lsz(1:2),sz(1:2))
                        error(message('vision:labeler:PixelLabelDataSizeMismatch'))
                    end
                catch
                    L=zeros(size(labelData),'uint8');
                end



                appliedLabels=categories(labelData);

                for idx=1:numel(appliedLabels)
                    roiLabel=queryLabel(this.ROILabelSet,appliedLabels{idx});
                    L(labelData==appliedLabels{idx})=roiLabel.PixelLabelID;
                end

                TF=writeData(this,signalName,L,index);
                if~TF
                    filename='';
                end
                setPixelLabelAnnotation(this,signalName,index,filename);

            else
                isROILabel=isROI([labelData.Type]);
                isSceneLabel=isScene([labelData.Type]);

                autoROILabels=labelData(isROILabel);
                autoSceneLabels=labelData(isSceneLabel);

                autoROILabelNames={autoROILabels.Name};
                if isempty(autoROILabels)
                    autoROILabelUID={};
                    hasAutoAttribute=false;
                    autoROILabelAttributes={};
                else
                    autoROILabelUID={autoROILabels.LabelUID};
                    hasAutoAttribute=isfield(autoROILabels,'Attributes');
                    if hasAutoAttribute
                        autoROILabelAttributes={autoROILabels.Attributes};
                    else
                        autoROILabelAttributes=cell(numel(autoROILabelUID),1);
                    end
                end
                autoROIPositions={autoROILabels.Position};


                [oldROIPositions,oldROINames,~,...
                oldSelfUIDs,~,~,~]=queryROILabelAnnotationBySignalName(this,signalName,index);

                numLabels=numel([oldROINames,autoROILabelNames]);
                allEmptyStr=cell(1,numLabels);allEmptyStr(:)={''};
                allSublabelNames=allEmptyStr;
                allSublabelUIDs=allEmptyStr;

                addROILabelAnnotations(this,signalName,index,[oldROINames,autoROILabelNames],allSublabelNames,...
                [oldSelfUIDs,autoROILabelUID],allSublabelUIDs,...
                [oldROIPositions,autoROIPositions]);

                if hasAutoAttribute
                    updateAttributeAnnotationForAlgo(this,signalName,index,autoROILabelUID,autoROILabelNames,autoROILabelAttributes);
                end

                autoSceneLabelNames={autoSceneLabels.Name};
                if~isempty(autoSceneLabelNames)
                    signalNames=getSignalNames(this);
                    for readerIdx=1:numel(signalNames)
                        signalName_i=signalNames{readerIdx};
                        idx=getFrameIndexFromTime(this,t,signalName_i);
                        oldFrameLabelNames=queryFrameLabelAnnotationBySignalName(this,signalName_i,idx);
                        addFrameLabelAnnotation(this,signalName_i,idx,[oldFrameLabelNames,autoSceneLabelNames]);
                    end
                end
            end
            this.IsChanged=true;
        end


        function updateAttributeAnnotationForAlgo(this,signalName,index,labelUIDs,labelNames,attribScell)
            for i=1:numel(labelUIDs)
                attribS=attribScell{i};
                if isstruct(attribS)
                    attribNames=fieldnames(attribS);
                    for j=1:numel(attribNames)
                        attribData.AttributeName=attribNames{j};
                        attribData.AttributeValue=attribS.(attribNames{j});
                        this.ROIAnnotations.updateAttributeAnnotation(signalName,index,labelUIDs{i},labelNames{i},'',attribData);
                    end
                end
            end
        end


        function LabelUID=getParentLabelUID(this,signalName,frameIdx,labelName,sublabelName,sublabelUID)
            frameIdx=max(frameIdx,1);
            LabelUID=this.ROIAnnotations.getParentLabelUID(signalName,frameIdx,labelName,sublabelName,sublabelUID);
        end


        function attribInstanceData=getAttributeInstanceValue(this,signalName,frameIdx,roiUID,attribDefData)
            frameIdx=max(frameIdx,1);
            attribInstanceData=this.ROIAnnotations.getAttributeInstanceValue(signalName,frameIdx,roiUID,attribDefData);
        end


        function updateAnnotationsForAttributesValue(this,signalName,frameIdx,roiUID,labelName,sublabelName,attributeData)
            frameIdx=max(frameIdx,1);
            this.ROIAnnotations.updateAttributeAnnotation(signalName,frameIdx,roiUID,labelName,sublabelName,attributeData);
            this.IsChanged=true;
        end


        function updateAttribAnnotationAtAttribCreation(this,attribData)
            this.ROIAnnotations.updateAttribAnnotationAtAttribCreation(attribData);
            this.IsChanged=true;
        end




        function addROILabelAnnotations(this,signalName,frameIdx,labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions,varargin)













            frameIdx=max(frameIdx,1);

            this.ROIAnnotations.addAnnotation(signalName,frameIdx,labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions,varargin{:});
            this.IsChanged=true;
        end

        function updateSignalNameMultiple(this,oldNames,newNames)
            if numel(oldNames)==numel(newNames)
                for idx=1:numel(oldNames)
                    if oldNames(idx)~=newNames(idx)
                        this.updateSignalName(oldNames(idx),newNames(idx));
                    end
                end
            end
        end

        function updateSignalName(this,oldName,newName)
            this.ROIAnnotations.updateSignalName(oldName,newName);
            this.FrameAnnotations.updateSignalName(oldName,newName);

        end




        function setPixelLabelAnnotation(this,signalName,index,labelPath)

            if isempty(this.TempDirectory)
                setTempDirectory(this);
            end

            index=max(index,1);
            this.ROIAnnotations.setPixelLabelAnnotation(signalName,index,labelPath);

            setIsPixelLabelChangedByIdx(this.ROIAnnotations,signalName,index);
            this.IsChanged=true;
        end


        function[positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes]=queryROILabelAnnotationBySignalName(this,signalName,index)
            index=max(index,1);
            [positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes]=this.ROIAnnotations.queryAnnotationBySignalName(signalName,index);
        end


        function[positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=queryROILabelAnnotationByReaderId(this,readerIdx,index)

            index=max(index,1);

            [positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=this.ROIAnnotations.queryAnnotationByReaderId(readerIdx,index);
        end


        function numInstances=queryNumSublabelInstances(this,signalName,frameIdx,labelName,labelUID,sublabelNames)
            frameIdx=max(frameIdx,1);
            numInstances=this.ROIAnnotations.queryNumSublabelInstances(signalName,frameIdx,labelName,labelUID,sublabelNames);
        end


        function roiLabel=addROILabel(this,roiLabel,hFig)


            roiLabel=this.ROILabelSet.addLabel(roiLabel,hFig);
            this.IsChanged=true;
        end


        function[sublabelIDs,sublabelNames]=queryChildSublabelIDNames(this,labelName)
            [sublabelIDs,sublabelNames]=this.ROISublabelSet.queryChildSublabelIDNames(labelName);
        end


        function[attribIDs,attribNames]=queryChildAttributeIDNames(this,labelName,sublabelName)
            [attribIDs,attribNames]=this.ROIAttributeSet.queryChildAttributeIDNames(labelName,sublabelName);
        end


        function subLabel=addROISublabel(this,subLabelData)


            subLabel=this.ROISublabelSet.addSublabel(subLabelData);
            this.IsChanged=true;
        end


        function attribute=addROIAttribute(this,attributeData,hFig)


            attribute=this.ROIAttributeSet.addAttribute(attributeData,hFig);
            this.IsChanged=true;
        end


        function count=numExistingSublabels(this,labelName)


            currROILabelNames={this.ROISublabelSet.DefinitionStruct.LabelName};
            idxList=strcmp(currROILabelNames,labelName);
            count=sum(idxList);
        end


        function deleteROILabel(this,labelID)

            this.ROILabelSet.removeLabel(labelID);
            this.IsChanged=true;
        end


        function deleteROISublabel(this,labelName,sublabelName)

            this.ROISublabelSet.removeSublabel(labelName,sublabelName);
            this.IsChanged=true;
        end


        function deleteROIAttribute(this,labelName,sublabelName,attributeName)

            this.ROIAttributeSet.removeAttribute(labelName,sublabelName,attributeName);
            this.IsChanged=true;
        end


        function modifyValueOfAttributeList(this,labelName,sublabelName,attributeName,val)

            this.ROIAttributeSet.modifyValueOfAttributeList(labelName,sublabelName,attributeName,val);
            this.IsChanged=true;
        end


        function modifyLabelName(this,oldLabelName,newLabelName)


            renameLabelForSublabel(this,oldLabelName,newLabelName);




            this.ROILabelSet.renameLabel(oldLabelName,newLabelName);


            this.ROIAttributeSet.modifyLabelNameInAttribute(oldLabelName,newLabelName);
            this.IsChanged=true;
        end


        function modifyLabelColor(this,labelName,newLabelColor)


            this.ROILabelSet.changeLabelColor(labelName,newLabelColor);
            this.IsChanged=true;
        end


        function modifySublabelName(this,labelName,oldSublabelName,newSublabelName)


            this.ROISublabelSet.renameSublabel(labelName,oldSublabelName,newSublabelName);







            this.ROIAttributeSet.modifySublabelNameInAttribute(labelName,oldSublabelName,newSublabelName);
            this.IsChanged=true;
        end


        function modifyFrameLabelName(this,oldFrameLabelName,newFrameLabelName)

            this.FrameLabelSet.renameLabel(oldFrameLabelName,newFrameLabelName);
            this.IsChanged=true;
        end


        function modifySublabelColor(this,labelName,subLabelName,newSublabelColor)


            this.ROISublabelSet.changeColorSublabel(labelName,subLabelName,newSublabelColor);
            this.IsChanged=true;
        end


        function modifyNameOfAttribute(this,labelName,sublabelName,oldAttribName,newAttribName)

            this.ROIAttributeSet.modifyNameOfAttribute(labelName,sublabelName,oldAttribName,newAttribName);
            this.IsChanged=true;
        end


        function modifyAttributeDescription(this,labelName,sublabelName,attribName,newDesc)

            this.ROIAttributeSet.modifyAttributeDescription(labelName,sublabelName,attribName,newDesc);
            this.IsChanged=true;
        end


        function modifyLabelROIVisibility(this,labelData)


            this.ROILabelSet.changeROIVisibility(labelData);
            this.IsChanged=true;
        end


        function modifySubLabelROIVisibility(this,labelData)



            this.ROISublabelSet.changeSubLabelROIVisibility(labelData);
            this.IsChanged=true;
        end

        function roiLabel=queryROILabelData(this,indexOrName)
            roiLabel=this.ROILabelSet.queryLabel(indexOrName);
        end


        function TF=hasAttributeDefined(this,labelName)
            TF=this.ROIAttributeSet.hasAttributeDefined(labelName);
        end


        function TF=hasShapeLabels(this)
            TF=hasRectangularLabel(this.ROILabelSet)||...
            hasLineLabel(this.ROILabelSet)||...
            hasPolygonLabel(this.ROILabelSet)||...
            hasProjCuboidLabel(this.ROILabelSet);
        end


        function roiSublabel=queryROISublabelData(this,labelName,sublabelName)

            roiSublabel=this.ROISublabelSet.querySublabel(labelName,sublabelName);
            if isempty(roiSublabel.Color)
                labelName=roiSublabel.LabelName;
                color=this.ROILabelSet.queryLabelColor(labelName);
                roiSublabel.Color=color;
            end
        end


        function roiSublabels=queryROISublabelFamilyNames(this,labelName)

            roiSublabels=this.ROISublabelSet.querySublabelNames(labelName);
        end


        function roiSublabels=queryROISublabelFamilyData(this,labelName)

            roiSublabels=this.ROISublabelSet.querySublabelFamily(labelName);
        end


        function roiAttributeFamily=queryROIAttributeFamilyData(this,labelName,sublabelName)

            roiAttributeFamily=this.ROIAttributeSet.queryAttributeFamily(labelName,sublabelName);
        end


        function isPixLabel=isaPixelLabel(this,labelName)

            isPixLabel=isaPixelLabel(this.ROILabelSet,labelName);
        end


        function TF=hasPixelLabels(this)
            TF=hasPixelLabel(this.ROILabelSet);
        end


        function TF=frameHasPixelLabels(this,index)

            TF=~isempty(this.ROIAnnotations.getPixelLabelAnnotation(index));
        end


        function TF=hasRectangularLabels(this)
            TF=hasRectangularLabel(this.ROILabelSet);
        end


        function TF=hasSceneLabels(this)
            TF=hasSceneLabel(this.FrameLabelSet);
        end


        function TF=hasProjCuboidLabels(this)
            TF=hasProjCuboidLabel(this.ROILabelSet);
        end


        function TF=hasPolygonLabels(this)
            TF=hasPolygonLabel(this.ROILabelSet);
        end


        function N=getNumSublabels(this)
            N=this.ROISublabelSet.NumSublabels;
        end


        function N=getNumAttributes(this)
            N=this.ROIAttributeSet.NumAttributes;
        end


        function N=getNumPixelLabels(this)
            N=this.ROILabelSet.getNumROIByType(labelType.PixelLabel);
        end


        function N=getPixelLabels(this)
            N=getNextPixelLabel(this.ROILabelSet);
        end


        function pixelDataPath=getPixelLabelDataPath(this)
            pixelDataPath=this.PixelLabelDataPath;
        end


        function setPixelLabelDataPath(this,pixelDataPath)
            this.PixelLabelDataPath=pixelDataPath;
        end


        function verfiyROIVisibility(this)
            this.ROILabelSet.modifyROIVisibility;
        end





        function addFrameLabelAnnotation(this,signalName,index,labelNames)








            index=max(index,1);

            this.FrameAnnotations.addAnnotation(signalName,index,labelNames);
            this.IsChanged=true;
        end


        function deleteFrameLabelAnnotation(this,signalName,index,labelNames)








            index=max(index,1);

            this.FrameAnnotations.removeAnnotation(signalName,index,labelNames);
            this.IsChanged=true;
        end


        function[names,colors,ids]=queryFrameLabelAnnotation(this,index)

            index=max(index,1);
            [names,colors,ids]=this.FrameAnnotations.queryAnnotation(index);
        end


        function[names,colors,ids]=queryFrameLabelAnnotationByReaderId(this,readerIdx,index)

            index=max(index,1);
            [names,colors,ids]=this.FrameAnnotations.queryAnnotationByReaderId(readerIdx,index);
        end


        function[names,colors,ids]=queryFrameLabelAnnotationBySignalName(this,signalName,index)

            index=max(index,1);
            [names,colors,ids]=this.FrameAnnotations.queryAnnotationBySignalName(signalName,index);
        end



        function frameLabel=addFrameLabel(this,name)


            frameLabel=this.FrameLabelSet.addLabel(name);
            this.IsChanged=true;
        end


        function deleteFrameLabel(this,labelID)

            this.FrameLabelSet.removeLabel(labelID);
            this.IsChanged=true;
        end


        function frameLabel=queryFrameLabelData(this,indexOrName)
            frameLabel=this.FrameLabelSet.queryLabel(indexOrName);
        end



        function TF=writeData(this,signalName,L,idx)
            try
                imwrite(L,fullfile(this.TempDirectory,formMaskFileName(this,signalName,idx)));

                setIsPixelLabelChangedByIdx(this.ROIAnnotations,signalName,idx);
                TF=true;
            catch
                TF=false;
            end
        end



        function copyData(this,signalName,filename,idx)

            if isfile(filename)


                try
                    newFilePath=fullfile(this.TempDirectory,formMaskFileName(this,signalName,idx));
                    copyfile(filename,newFilePath);


                    fileattrib(newFilePath,'+w');
                    setPixelLabelAnnotation(this,signalName,idx,newFilePath);

                    setIsPixelLabelChangedByIdx(this.ROIAnnotations,signalName,idx);
                catch

                end
            else
                setPixelLabelAnnotation(this,signalName,idx,'');
            end

        end




        function updateROILabelDescription(this,labelID,descr)
            updateLabelDescription(this.ROILabelSet,labelID,descr);
        end


        function updateFrameLabelDescription(this,labelID,descr)
            updateLabelDescription(this.FrameLabelSet,labelID,descr);
        end


        function updateFrameLabelColor(this,labelName,color)

            changeLabelColor(this.FrameLabelSet,labelName,color)
        end


        function updateROILabelGroup(this,labelName,group)
            updateLabelGroup(this.ROILabelSet,labelName,group);
        end


        function updateFrameLabelGroup(this,labelName,group)
            updateLabelGroup(this.FrameLabelSet,labelName,group);
        end




        function updateROIGroupNames(this,oldGroupName,newGroupName)
            updateGroups(this.ROILabelSet,oldGroupName,newGroupName);
        end


        function updateFrameGroupNames(this,oldGroupName,newGroupName)
            updateGroups(this.FrameLabelSet,oldGroupName,newGroupName);
        end


        function reorderROILabelDefinitions(this,labelNames)
            reorderLabelDefinitions(this.ROILabelSet,labelNames);
        end


        function reorderFrameLabelDefinitions(this,labelNames)
            reorderLabelDefinitions(this.FrameLabelSet,labelNames);
        end


        function that=loadROILabelMode(this,that)


            if isfield(that,'ShowROILabelMode')
                this.ShowROILabelMode=that.ShowROILabelMode;
            else


                this.ShowROILabelMode='hover';
            end
        end
    end




    methods


        function loadLabelAnnotations(this,gTruth)

            definitions=gTruth.LabelDefinitions;
            loadLabelDefinitions(this,definitions)

            addData(this,gTruth);
        end


        function val=convertToLogical(~,popupIdxOrLogicalVal)

            if islogical(popupIdxOrLogicalVal)
                val=popupIdxOrLogicalVal;
            else
                popupIdx=popupIdxOrLogicalVal;
                if popupIdx==1
                    val=logical([]);
                elseif popupIdx==2
                    val=true;
                else
                    val=false;
                end
            end
        end


        function strctOut=appendAtributeofLabelToStruct(this,strctIn,labelName,attribDef4LabelStruct)
            strctOut=strctIn;
            if isempty(attribDef4LabelStruct)
                return;
            else
                for i=1:length(attribDef4LabelStruct)
                    attribS=attribDef4LabelStruct(i);
                    attribName=attribS.Name;
                    if attribS.Type==attributeType.List
                        strctOut.(labelName).(attribName).ListItems=attribS.Value;
                    elseif attribS.Type==attributeType.Logical
                        strctOut.(labelName).(attribName).DefaultValue=convertToLogical(this,attribS.Value);
                    else
                        strctOut.(labelName).(attribName).DefaultValue=attribS.Value;
                    end
                    strctOut.(labelName).(attribName).Description=attribS.Description;
                end
            end
        end


        function strctOut=appendSublabelToStruct(~,strctIn,labelName,sublabelDefStruct)
            strctOut=strctIn;
            if isempty(sublabelDefStruct)
                return;
            else
                for i=1:length(sublabelDefStruct)
                    sublabelS=sublabelDefStruct(i);
                    sublabelName=sublabelS.Name;
                    strctOut.(labelName).(sublabelName).Type=sublabelS.Type;
                    strctOut.(labelName).(sublabelName).Description=sublabelS.Description;
                    strctOut.(labelName).(sublabelName).LabelColor=sublabelS.Color;
                end
            end
        end


        function strctOut=appendAtributeofSublabelToStruct(this,strctIn,labelName,sublabelName,attribDef4SublabelStruct)
            strctOut=strctIn;
            if isempty(attribDef4SublabelStruct)
                return;
            else
                for i=1:length(attribDef4SublabelStruct)
                    attribS=attribDef4SublabelStruct(i);
                    attribName=attribS.Name;
                    if attribS.Type==attributeType.List
                        strctOut.(labelName).(sublabelName).(attribName).ListItems=attribS.Value;
                    elseif attribS.Type==attributeType.Logical
                        strctOut.(labelName).(sublabelName).(attribName).DefaultValue=convertToLogical(this,attribS.Value);
                    else
                        strctOut.(labelName).(sublabelName).(attribName).DefaultValue=attribS.Value;
                    end
                    strctOut.(labelName).(sublabelName).(attribName).Description=attribS.Description;
                end
            end
        end


        function sublabelAttribStruct=extractSublabelAttributeDefStruct(this,roiDefinitionsTable)

            s=[];
            labelNames=roiDefinitionsTable.Name;
            labelTypes=roiDefinitionsTable.Type;
            labelDescriptions=roiDefinitionsTable.Description;

            numLabels=length(labelNames);
            for i=1:numLabels

                if(labelTypes(i)~=labelType.PixelLabel)
                    labelName=labelNames{i};
                    sublabelDefStruct=this.ROISublabelSet.exportDef2struct(labelName);
                    attribDef4LabelStruct=this.ROIAttributeSet.exportDef2struct(labelName,'');
                    s=appendAtributeofLabelToStruct(this,s,labelName,attribDef4LabelStruct);
                    for j=1:length(sublabelDefStruct)
                        sublabelName=sublabelDefStruct(j).Name;
                        s=appendSublabelToStruct(this,s,labelName,sublabelDefStruct(j));

                        attribDef4SublabelStruct=this.ROIAttributeSet.exportDef2struct(labelName,sublabelName);
                        s=appendAtributeofSublabelToStruct(this,s,labelName,sublabelName,attribDef4SublabelStruct);
                    end


                    if isfield(s,labelName)


                        s.(labelName).Type=labelTypes(i);
                        s.(labelName).Description=labelDescriptions{i};
                    end
                end
            end

            sublabelAttribStruct=s;
        end


        function TF=hasSublabelOrAttributeDefs(this)
            hasSublabelDef=~isempty(this.ROISublabelSet.DefinitionStruct);
            hasAttribDef=~isempty(this.ROIAttributeSet.DefinitionStruct);
            TF=hasSublabelDef||hasAttribDef;
        end


        function defTableOut=addHierarchyColumnIfNeeded(this,defTableIn,sublabelAttribStruct)

            defTableOut=defTableIn;
            if hasSublabelOrAttributeDefs(this)
                labelNames=defTableOut.Name;
                numRows=numel(labelNames);
                defTableOut.Hierarchy=cell(numRows,1);
                if~isempty(sublabelAttribStruct)
                    for i=1:numRows
                        if isfield(sublabelAttribStruct,labelNames{i})
                            defTableOut.Hierarchy{i}=sublabelAttribStruct.(labelNames{i});
                        end
                    end
                end
            end
        end


        function defTableOut=addEmptyHierarchyColumn(~,defTableIn)
            defTableOut=defTableIn;
            names=defTableOut.Name;
            numRows=numel(names);
            defTableOut.Hierarchy=cell(numRows,1);
        end


        function definitions=exportLabelDefinitions(this)


            roiDefinitionsTable=this.ROILabelSet.export2table;

            sublabelAttribStruct=extractSublabelAttributeDefStruct(this,roiDefinitionsTable);
            roiDefinitionsTable=addHierarchyColumnIfNeeded(this,roiDefinitionsTable,sublabelAttribStruct);


            frameDefinitionsTable=this.FrameLabelSet.export2table;
            if hasSublabelOrAttributeDefs(this)
                frameDefinitionsTable=addEmptyHierarchyColumn(this,frameDefinitionsTable);
            end

            if~hasPixelLabel(this.ROILabelSet)


                roiDefinitionsTable.PixelLabelID=[];
                frameDefinitionsTable.PixelLabelID=[];
            end



            definitions=vertcat(roiDefinitionsTable,frameDefinitionsTable);
        end


        function labelObj=createLabelObject(~,labelDef)
            lblType=labelDef.Type;
            labelName=labelDef.Name;
            if isfield(labelDef,'Color')
                labelColor=labelDef.Color;
            else
                labelColor='';
            end

            if isfield(labelDef,'Group')
                groupName=labelDef.Group;
            else
                groupName='None';
            end

            if isfield(labelDef,'Description')
                labelDesc=labelDef.Description;
            else
                labelDesc='';
            end

            if labelDef.Type==labelType.PixelLabel

                pixelLabelID=labelDef.PixelLabelID;
                labelObj=vision.internal.labeler.ROILabel(lblType,labelName,labelDesc,groupName,pixelLabelID);
            else
                labelObj=vision.internal.labeler.ROILabel(lblType,labelName,labelDesc,groupName);
            end
            labelObj.Color=labelColor;
        end


        function TF=isAttributeStruct(~,attribS)
            TF=isstruct(attribS)&&...
            (isfield(attribS,'ListItems')||isfield(attribS,'DefaultValue'))&&...
            isfield(attribS,'Description');
        end


        function TF=isSublabelStruct(~,sublabelS)
            TF=isstruct(sublabelS)&&...
            isfield(sublabelS,'Type')&&...
            ((sublabelS.Type==labelType.Rectangle)||...
            (sublabelS.Type==labelType.Line)||...
            (sublabelS.Type==labelType.Polygon)||...
            (sublabelS.Type==labelType.ProjectedCuboid))&&...
            isfield(sublabelS,'Description');
        end


        function[type,val]=decodeAttributeTypeValue(~,attribS)

            if isfield(attribS,'ListItems')
                type=attributeType.List;
                val=attribS.ListItems;
            elseif isfield(attribS,'DefaultValue')
                if islogical(attribS.DefaultValue)
                    type=attributeType.Logical;
                    val=attribS.DefaultValue;
                elseif isnumeric(attribS.DefaultValue)
                    type=attributeType.Numeric;
                    val=attribS.DefaultValue;
                elseif(ischar(attribS.DefaultValue)||isstring(attribS.DefaultValue))
                    type=attributeType.String;
                    val=attribS.DefaultValue;
                else
                    type=attributeType.Numeric;
                    val=0;
                    assert(false);
                end
            end

        end


        function attribOfLblObjs=createAttribObjects(this,labelName,sublabelName,hierarchy)
            attribOfLblObjs={};
            f=fieldnames(hierarchy);
            for i=1:numel(f)
                attributeName=f{i};
                thisS=hierarchy.(attributeName);
                if isAttributeStruct(this,thisS)
                    description=thisS.Description;
                    [type,val]=decodeAttributeTypeValue(this,thisS);
                    attribOfLblObjs{end+1}=vision.internal.labeler.ROIAttribute(labelName,sublabelName,attributeName,type,val,description);%#ok<AGROW>
                end
            end
        end


        function attribOfLblObjs=createAttribOfLabelObjects(this,labelName,labelHierarchy)
            attribOfLblObjs=createAttribObjects(this,labelName,'',labelHierarchy);
        end


        function attribOfLblObjs=createAttribOfSublabelObjects(this,labelName,sublabelName,sublabelHierarchy)
            attribOfLblObjs=createAttribObjects(this,labelName,sublabelName,sublabelHierarchy);
        end


        function[sublabelObs,attribOfSubObjs]=createSublabelAttribObjects(this,labelName,labelHierarchy)
            sublabelObs={};
            attribOfSubObjs={};
            f=fieldnames(labelHierarchy);
            for i=1:numel(f)
                sublabelName=f{i};
                thisS=labelHierarchy.(sublabelName);
                if isSublabelStruct(this,thisS)
                    sublabelObs{end+1}=vision.internal.labeler.ROISublabel(labelName,thisS.Type,sublabelName,thisS.Description);%#ok<AGROW>




                    if isfield(thisS,'LabelColor')
                        sublabelObs{end}.Color=thisS.LabelColor;
                    end
                    attribOfSubObjs{end+1}=createAttribOfSublabelObjects(this,labelName,sublabelName,thisS);%#ok<AGROW>
                end
            end
        end


        function s=decodeImportedLabelDef(this,allDefs)
            numLabels=numel(allDefs);
            hasHierarchyCol=isfield(allDefs,'Hierarchy');

            for lbl=1:numLabels
                thisDef=allDefs(lbl);
                s.Label{lbl}=createLabelObject(this,thisDef);

                s.AttribOfLabel{lbl}={};
                s.Sublabel{lbl}={};
                s.AttribOfSublabel{lbl}={};

                if hasHierarchyCol
                    thisLabelHierarchy=thisDef.Hierarchy;
                    if~isempty(thisLabelHierarchy)
                        labelName=thisDef.Name;
                        s.AttribOfLabel{lbl}=createAttribOfLabelObjects(this,labelName,thisLabelHierarchy);

                        [thisSublabelObs,thisAttribObjs]=createSublabelAttribObjects(this,labelName,thisLabelHierarchy);
                        s.Sublabel{lbl}=thisSublabelObs;
                        s.AttribOfSublabel{lbl}=thisAttribObjs;
                    end
                end
            end
        end


        function addLabelData(this,signalName,definitions,labelData,indices,orderData)


            labels=table2struct(labelData);
            if(~isempty(orderData))
                polyOrderData=table2struct(orderData);
            else
                polyOrderData=[];
            end

            fields=fieldnames(labels);


            areROIsPresent=any(isROI([definitions.Type]));
            if areROIsPresent
                rectangleLabels=([definitions.Type]==labelType.Rectangle);
                lineLabels=([definitions.Type]==labelType.Line);
                polygonLabels=([definitions.Type]==labelType.Polygon);
                projCuboidLabels=([definitions.Type]==labelType.ProjectedCuboid);

                roiLabels=definitions{...
                (rectangleLabels|lineLabels|polygonLabels|projCuboidLabels),'Name'};
                [roiLabels,isROILabel]=intersect(fields,roiLabels,'stable');

                isPixelLabel=find(strcmp(fields,'PixelLabelData'));
            else
                isROILabel=false(size(fields));
            end


            areFrameLabelsPresent=any(isScene([definitions.Type]));
            if areFrameLabelsPresent
                frameLabels=definitions{isScene([definitions.Type]),'Name'};
                [~,isFrameLabel]=intersect(fields,frameLabels,'stable');
            else
                isFrameLabel=false(size(fields));
            end


            for n=1:numel(indices)
                positionsOrFrameLabel=struct2cell(labels(n));

                if(~isempty(polyOrderData))




                    roiOrder=cell(numel(positionsOrFrameLabel),1);

                    for f=1:numel(fields)
                        if(isfield(polyOrderData,fields{f}))
                            roiOrder{f}=polyOrderData(n).(fields{f});
                        end
                    end
                else
                    roiOrder=[];
                end

                if areROIsPresent
                    if~isempty(isROILabel)
                        positions=positionsOrFrameLabel(isROILabel);
                        numROILabels=length(positions);

                        if numROILabels
                            sublabelNames=repmat({''},numROILabels,1);
                            roiPositions=cell(numROILabels,1);
                            roiLabelList=repmat({''},numROILabels,1);
                            labelUID=repmat({''},numROILabels,1);
                            sublabelUID=repmat({''},numROILabels,1);
                            order=zeros(numROILabels,1);
                            attributeROIUID={};
                            attributeLabelNames={};
                            attributeSublabelNames={};
                            attributeData={};

                            idx=0;



                            containsSublabels=isstruct(positions{1});

                            for roiLabel=1:numROILabels

                                if~iscell(positions{roiLabel})&&size(positions{roiLabel},2)==2...
                                    &&~isstruct(positions{roiLabel})
                                    positions{roiLabel}={positions(roiLabel)};
                                end

                                numberOfROIs=getNumROIs(positions{roiLabel});
                                for roi=1:numberOfROIs
                                    if isempty(positions{roiLabel})

                                        continue;
                                    end
                                    if containsSublabels
                                        roiPosition=positions{roiLabel}(roi).Position;
                                    else
                                        roiPosition=positions{roiLabel}(roi,:);



                                    end

                                    idx=idx+1;
                                    roiLabelList{idx,1}=roiLabels{roiLabel};
                                    roiPositions{idx,1}=roiPosition;
                                    sublabelNames{idx,1}='';
                                    uid=vision.internal.getUniqueID();
                                    labelUID{idx,1}=uid;
                                    sublabelUID{idx,1}='';



                                    order(idx)=-1;
                                    if(~isempty(roiOrder))
                                        if(~isempty(roiOrder{roiLabel}))
                                            order(idx)=roiOrder{roiLabel}(roi);
                                        end
                                    end


                                    if containsSublabels
                                        fields=fieldnames(positions{roiLabel}(roi));
                                        sublabelAndAttrNames=fields(~(string(fields)=="Position"));
                                        numSubAndAttr=numel(sublabelAndAttrNames);
                                        attrNames={};
                                        subNames={};


                                        if isstruct(definitions.Hierarchy)
                                            definitions.Hierarchy=num2cell(definitions.Hierarchy);
                                        end

                                        hierarchyIdx=string(definitions.Name)==string(roiLabels{roiLabel});
                                        selectedHierarchy=definitions.Hierarchy{hierarchyIdx};

                                        for i=1:numSubAndAttr
                                            isValidStruct=~isempty(selectedHierarchy)&&...
                                            isfield(selectedHierarchy,sublabelAndAttrNames{i});



                                            if isValidStruct
                                                subAttrStruct=selectedHierarchy.(sublabelAndAttrNames{i});
                                            end
                                            if isValidStruct&&this.isAttributeStruct(subAttrStruct)
                                                attrNames=[attrNames;sublabelAndAttrNames{i}];%#ok<AGROW>
                                            else
                                                subNames=[subNames;sublabelAndAttrNames{i}];%#ok<AGROW>
                                            end
                                        end

                                        for attrNum=1:numel(attrNames)
                                            attrName=attrNames{attrNum,:};
                                            attributeROIUID{end+1}=uid;%#ok<AGROW>
                                            attributeLabelNames{end+1}=roiLabels{roiLabel};%#ok<AGROW>
                                            attributeSublabelNames{end+1}='';%#ok<AGROW>
                                            attribS=selectedHierarchy.(attrName);
                                            [type,~]=this.decodeAttributeTypeValue(attribS);
                                            attributeData{end+1}=struct('AttributeName',attrName,...
                                            'AttributeType',type,...
                                            'AttributeValue',positions{roiLabel}(roi).(attrName));%#ok<AGROW>
                                        end

                                        numberOfSubLabels=numel(subNames);
                                        for sublabel=1:numberOfSubLabels
                                            subName=subNames{sublabel,:};
                                            sublabelROIs=positions{roiLabel}(roi).(subName);
                                            numberOfSubROIs=numel(sublabelROIs);

                                            for subROI=1:numberOfSubROIs
                                                idx=idx+1;
                                                roiLabelList{idx,1}=roiLabels{roiLabel};
                                                roiPositions{idx,1}=sublabelROIs(subROI).Position;
                                                sublabelNames{idx,1}=subName;
                                                labelUID{idx,1}=uid;
                                                sublabelUID{idx,1}=vision.internal.getUniqueID();


                                                order(idx)=-1;

                                                fields=fieldnames(sublabelROIs(subROI));
                                                attributesOfSubNames=fields(2:end,:);

                                                for attrNum=1:numel(attributesOfSubNames)
                                                    attrName=attributesOfSubNames{attrNum,:};
                                                    attributeROIUID{end+1}=sublabelUID{idx,1};%#ok<AGROW>
                                                    attributeLabelNames{end+1}=roiLabels{roiLabel};%#ok<AGROW>
                                                    attributeSublabelNames{end+1}=subName;%#ok<AGROW>
                                                    attribS=selectedHierarchy.(subName).(attrName);
                                                    [type,~]=this.decodeAttributeTypeValue(attribS);
                                                    attributeData{end+1}=struct('AttributeName',attrName,...
                                                    'AttributeType',type,...
                                                    'AttributeValue',sublabelROIs(subROI).(attrName));%#ok<AGROW>                                                      
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            [~,sortidx]=sort(order,'descend');
                            this.ROIAnnotations.addAnnotation(signalName,indices(n),...
                            roiLabelList(sortidx),sublabelNames(sortidx),labelUID(sortidx),...
                            sublabelUID,roiPositions(sortidx));
                            for i=1:numel(attributeROIUID)
                                updateAnnotationsForAttributesValue(this,...
                                signalName,indices(n),attributeROIUID{i},...
                                attributeLabelNames{i},...
                                attributeSublabelNames{i},attributeData{i});
                            end
                        end
                    end

                    if isPixelLabel

                        if isempty(this.TempDirectory)
                            setTempDirectory(this);
                        end
                        positions=positionsOrFrameLabel(isPixelLabel);
                        assert(numel(positions)==1,'Expected just 1 file');

                        if~isempty(positions{1})



                            this.copyData(signalName,positions{1},...
                            indices(n));
                        end
                    end
                end

                if areFrameLabelsPresent
                    frLabelData=positionsOrFrameLabel(isFrameLabel);
                    this.FrameAnnotations.appendAnnotation(signalName,indices(n),...
                    frameLabels,frLabelData);
                end
            end
            this.IsChanged=true;
        end
    end

    methods(Access=protected)

        function TF=copyPixelLabelFileToTemp(this,signalName,idx)
            TF=true;
            try
                filePath=getPixelLabelAnnotation(this.ROIAnnotations,...
                signalName,idx);
                if~isempty(filePath)
                    maskFileName=formMaskFileName(this,signalName,idx);
                    newFilePath=fullfile(this.TempDirectory,maskFileName);


                    if~contains(filePath,maskFileName)
                        filePath=fullfile(filePath,maskFileName);
                    end
                    copyfile(filePath,newFilePath,'f');


                    fileattrib(newFilePath,'+w');
                    setPixelLabelAnnotation(this,signalName,idx,...
                    newFilePath);
                end
            catch
                setPixelLabelAnnotation(this,signalName,idx,'');
                TF=false;
            end
        end

        function TF=copyPixelLabelFileFromTemp(this,signalName,newFolder)
            TF=true;
            signalName=char(signalName);
            if~isempty(this.TempDirectory)
                for idx=1:getNumFramesBySignal(this,signalName)
                    try
                        filePath=getPixelLabelAnnotation(this.ROIAnnotations,...
                        signalName,idx);
                        if~isempty(filePath)
                            newFilePath=fullfile(newFolder,formMaskFileName(this,signalName,idx));
                            copyfile(filePath,newFilePath,'f');
                            setPixelLabelAnnotation(this,signalName,idx,...
                            newFilePath);
                        end
                    catch
                        setPixelLabelAnnotation(this,signalName,idx,'');
                        TF=false;
                    end
                end
            else
                TF=false;
            end
        end

        function addTempFilePathsToAnnotationSet(this,signalName)
            for idx=1:getNumFramesBySignal(this,signalName)
                filePath=getPixelLabelAnnotation(this.ROIAnnotations,...
                signalName,idx);
                if~isempty(filePath)
                    newFilePath=fullfile(this.TempDirectory,formMaskFileName(this,signalName,idx));
                    setPixelLabelAnnotation(this,signalName,idx,...
                    newFilePath);
                end
            end
        end

        function info=versionFromProductName(~,shortName,fullName)



            info=ver(shortName);
            info=vision.internal.labeler.tool.Session....
            findVersionInfoByProductName(info,fullName);
        end
    end

    methods(Static,Hidden)
        function info=findVersionInfoByProductName(info,fullName)




            if numel(info)>1
                names=string({info.Name});
                idx=find(fullName==names);
                assert(~isempty(idx),'Expected at least one entry in version info.');
                info=info(idx);
            end
        end
    end

    methods(Abstract)
        loadLabelDefinitions(this,defintions)
    end




    methods

        function cacheAnnotations(this,signalName)
            cache(this.ROIAnnotations,signalName);
            cache(this.FrameAnnotations);
        end


        function uncacheAnnotations(this,signalNames)
            uncache(this.ROIAnnotations,signalNames);
            uncache(this.FrameAnnotations);
        end
    end

    methods(Access=protected)
        function mergePixelLabelsInAnnotaitonSet(this,signalName,indices)


            autoDirectory=this.TempDirectory;
            cachedDirectory=fileparts(autoDirectory);

            for idx=1:numel(indices)

                maskFileName=formMaskFileName(this,signalName,indices(idx));
                autoLabelFile=fullfile(autoDirectory,maskFileName);
                cachedLabelFile=fullfile(cachedDirectory,maskFileName);

                if~exist(autoLabelFile,'file')
                    continue;
                end

                try
                    L=imread(cachedLabelFile);
                catch
                    L=[];
                end

                try
                    autoL=imread(autoLabelFile);

                    if isempty(L)
                        L=zeros(size(autoL),'uint8');
                    end


                    L(autoL>0)=autoL(autoL>0);
                    imwrite(L,cachedLabelFile);

                    setIsPixelLabelChangedByIdx(this.ROIAnnotations,signalName,indices(idx));
                    setPixelLabelAnnotation(this,signalName,indices(idx),...
                    cachedLabelFile);
                catch
                    setPixelLabelAnnotation(this,signalName,indices(idx),...
                    '');
                end

            end
        end


        function loadAlgorithmInstances(this,loadedSession)
            if isfield(loadedSession,'AlgorithmInstances')
                this.AlgorithmInstances=loadedSession.AlgorithmInstances;
            end
        end
    end




    methods

        function roiSummary=queryROISummary(this,signalName,labelNames,timeIndices)
            roiSummary=struct();
            for n=1:numel(labelNames)
                thisLabel=labelNames{n};
                if this.isaPixelLabel(thisLabel)
                    pixelLabelIndex=getPixelLabelIndex(this,thisLabel);
                    thisSummary=this.ROIAnnotations.queryPixelSummary(signalName,pixelLabelIndex,timeIndices);
                else
                    thisSummary=this.ROIAnnotations.queryShapeSummary(signalName,thisLabel,timeIndices);
                end
                roiSummary.(thisLabel)=thisSummary;
            end
        end


        function sceneSummary=querySceneSummary(this,signalName,labels,timeIndices)
            sceneSummary=this.FrameAnnotations.querySummary(signalName,labels,timeIndices);
        end


        function pixelLabelIndex=getPixelLabelIndex(this,labelName)


            for n=1:this.ROILabelSet.NumLabels
                if strcmp(this.ROILabelSet.DefinitionStruct(n).Name,labelName)...
                    &&strcmp(this.ROILabelSet.DefinitionStruct(n).Type,'PixelLabel')
                    pixelLabelIndex=this.ROILabelSet.DefinitionStruct(n).PixelLabelID;
                    return
                end
            end

            pixelLabelIndex=0;
        end
    end




    methods

        function TF=get.HasROILabels(this)
            TF=this.ROILabelSet.NumLabels>0;
        end


        function numLabels=get.NumROILabels(this)
            numLabels=this.ROILabelSet.NumLabels;
        end


        function numSublabels=get.NumROISublabels(this)
            numSublabels=this.ROISublabelSet.NumSublabels;
        end


        function numAttributes=get.NumAttributes(this)
            numAttributes=this.ROIAttributeSet.NumAttributes;
        end


        function TF=get.HasFrameLabels(this)
            TF=this.FrameLabelSet.NumLabels>0;
        end


        function numLabels=get.NumFrameLabels(this)
            numLabels=this.FrameLabelSet.NumLabels;
        end


        function objectNames=getNamesUnderHierarchy(this,parentName,varargin)







            objectNames={};

            if nargin==2
                sublabelName=[];
            elseif nargin==3
                sublabelName=varargin{1};
            else

                return
            end



            if isempty(sublabelName)

                for sIdx=1:this.NumROISublabels
                    thisSublabelItem=this.ROISublabelSet.DefinitionStruct(sIdx);
                    if strcmpi(thisSublabelItem.LabelName,parentName)
                        objectNames{end+1}=thisSublabelItem.Name;%#ok<AGROW>
                    end
                end

                for aIdx=1:this.NumAttributes
                    thisAttributeItem=this.ROIAttributeSet.DefinitionStruct(aIdx);


                    if strcmpi(thisAttributeItem.LabelName,parentName)&&...
                        isempty(thisAttributeItem.SublabelName)
                        objectNames{end+1}=thisAttributeItem.Name;%#ok<AGROW>
                    end
                end

            else


                for aIdx=1:this.NumAttributes
                    thisAttributeItem=this.ROIAttributeSet.DefinitionStruct(aIdx);
                    if strcmpi(thisAttributeItem.LabelName,parentName)&&...
                        strcmpi(thisAttributeItem.SublabelName,sublabelName)
                        objectNames{end+1}=thisAttributeItem.Name;%#ok<AGROW>
                    end
                end
            end

        end


        function labelVisibility=getGlobalPixelLabelVisibility(this)


            labelVisibility=true(255,1);
            roiDefStruct=this.ROILabelSet.DefinitionStruct;
            for i=1:numel(roiDefStruct)
                if isequal(roiDefStruct(i).Type,...
                    labelType.PixelLabel)&&~roiDefStruct(i).ROIVisibility
                    labelVisibility(roiDefStruct(i).PixelLabelID)=false;
                end
            end
        end
    end




    methods(Hidden)

        function setTempDirectory(this,foldername)
            if nargin==1
                [~,name]=fileparts(tempname);
                foldername=[tempdir,'Labeler_',name];

                status=mkdir(foldername);
                if~status



                    toolCenter=[400,400];
                    dialogManager=vision.internal.imageLabeler.tool.dialogs.DialogManager;
                    dlg=dialogManager.MandatoryDirectoryDialog(toolCenter,name);
                    foldername=dlg.Directory;
                end
            end
            this.TempDirectory=foldername;
        end


        function resetTempDirectory(this)

            if~isempty(this.TempDirectory)
                [pathstr,name,~]=fileparts(this.TempDirectory);



                if strcmp(name,'Automation')
                    rmdir(pathstr,'s');
                else
                    rmdir(this.TempDirectory,'s');
                end
                this.TempDirectory=[];
            end
        end


        function delete(this)
            this.resetTempDirectory();
        end
    end




    methods(Access=protected)

        function TF=isNameALabel(this,name)

            TF=false;
            for idx=1:this.NumROILabels
                thisLabelName=this.ROILabelSet.DefinitionStruct(idx).Name;
                if strcmpi(name,thisLabelName)
                    TF=true;
                    break
                end
            end
        end


        function TF=isNameASublabel(this,name)

            TF=false;
            for idx=1:this.NumROISublabels
                thisSublabelName=this.ROISublabelSet.DefinitionStruct(idx).Name;
                if strcmpi(name,thisSublabelName)
                    TF=true;
                    break
                end
            end
        end


        function TF=isNameAnAttribute(this,name)

            TF=false;
            for idx=1:this.NumAttributes
                thisAttributeName=this.ROIAttributeSet.DefinitionStruct(idx).Name;
                if strcmpi(name,thisAttributeName)
                    TF=true;
                    break
                end
            end
        end
    end

    methods(Sealed,Access=protected)

        function addDefinitions(this,definitions)

            index=find(string(definitions.Properties.VariableNames)=="LabelType",1);

            if~isempty(index)
                definitions.Properties.VariableNames{index}='Type';


                roiId=(definitions.Type==labelType.Line&...
                definitions.SignalType==vision.labeler.loading.SignalType.PointCloud)...
                |definitions.Type==labelType.Cuboid;
                definitions(roiId,:)=[];
            end


            idx=find(strcmpi(definitions.Properties.VariableNames,'LabelColor'));
            if~isempty(idx)
                definitions.Properties.VariableNames{idx}='Color';
            end

            definitions=table2struct(definitions);
            hasGroup=isfield(definitions,'Group');
            hasDescription=isfield(definitions,'Description');
            hasColor=isfield(definitions,'Color');






















            allDefs=definitions(isROI([definitions.Type]));

            if~isempty(allDefs)
                s=decodeImportedLabelDef(this,allDefs);


                for lbl=1:numel(s.Label)
                    roiLabel=s.Label{lbl};
                    this.ROILabelSet.addLabel(roiLabel);


                    thisLblAttribCells=s.AttribOfLabel{lbl};
                    for lblAt=1:numel(thisLblAttribCells)
                        this.ROIAttributeSet.addAttribute(thisLblAttribCells{lblAt});
                    end


                    thisSublabelCells=s.Sublabel{lbl};
                    thisSublblAttribCells=s.AttribOfSublabel{lbl};

                    for slbl=1:numel(thisSublabelCells)
                        color=queryLabelColor(this.ROILabelSet,lbl);


                        if isempty(thisSublabelCells{slbl}.Color)
                            thisSublabelCells{slbl}.Color=color;
                        end
                        this.ROISublabelSet.addSublabel(thisSublabelCells{slbl});


                        thisSublblAttribCells_s=thisSublblAttribCells{slbl};
                        for slblAt=1:numel(thisSublblAttribCells_s)
                            this.ROIAttributeSet.addAttribute(thisSublblAttribCells_s{slblAt});
                        end
                    end
                end
            end


            frameLabelDefs=definitions(isScene([definitions.Type]));
            for n=1:numel(frameLabelDefs)
                labelName=frameLabelDefs(n).Name;

                if hasGroup
                    labelGroup=frameLabelDefs(n).Group;
                else
                    labelGroup='None';
                end

                if hasDescription
                    labelDesc=frameLabelDefs(n).Description;
                else
                    labelDesc='';
                end

                frameLabel=vision.internal.labeler.FrameLabel(labelName,labelDesc,labelGroup);

                if hasColor
                    color=frameLabelDefs(n).Color;
                    frameLabel.Color=color;
                end

                this.FrameLabelSet.addLabel(frameLabel);
            end
            this.IsChanged=true;
        end
    end

    methods(Abstract)

        exportLabelAnnotations(this)



        readDataBySignalId(this,readerIdx,frameIndex,imageSize);
    end

    methods(Abstract,Access=protected)

        addData(this)
    end

    methods(Abstract,Hidden)

        saveobj(this)
    end

    methods(Abstract,Static,Hidden)

        loadobj(this)
    end

end


function n=getNumROIs(pos)
    if isstruct(pos)

        n=numel(pos);
    elseif ismatrix(pos)

        n=size(pos,1);
    elseif iscell(pos)
        n=numel(pos);
    else

        assert(false,"LabelData in groundTruth contains invalid entries.");
    end
end
