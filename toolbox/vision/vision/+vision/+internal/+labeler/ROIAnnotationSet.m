



classdef ROIAnnotationSet<vision.internal.labeler.AnnotationSet

    properties(Access=protected)


SublabelSet



AttributeSet





    end

    properties(Access=private)
ROIAnnotationStructManager
    end

    properties(Access=protected,Hidden)
        Version=ver('vision');
    end

    properties(Hidden)


BackupAnnotationStruct
BackupFrameHasAnnotations
    end




    methods

        function this=ROIAnnotationSet(labelSet,subLabelSet,attributeSet)

            this.ROIAnnotationStructManager=vision.internal.labeler.annotation.ROIAnnotationStructManager();
            this.AnnotationStructManager=this.ROIAnnotationStructManager;

            this.LabelSet=labelSet;
            this.SublabelSet=subLabelSet;
            this.AttributeSet=attributeSet;


            configure(this);
        end


        function addSourceInformation(this,signalName,signalType,numImages,resetFrameAndPixelFlag)

            createAndAddAnnotationStruct(this.ROIAnnotationStructManager,annotationType.ROI,signalName,numImages,this.LabelSet,this.SublabelSet,this.AttributeSet,signalType);

            if nargin<5
                resetFrameAndPixelFlag=true;
            end

            if resetFrameAndPixelFlag
                resetFrameHasAnnotations(this.ROIAnnotationStructManager,signalName);
                resetIsPixelLabelChanged(this.ROIAnnotationStructManager,signalName);
            end

            if~isempty(this.BackupAnnotationStruct)
                completeLoadObj(this,signalName);
            end
        end


        function appendSourceInformation(this,signalName,signalType,numImages)



            if~hasAnnotation(this.ROIAnnotationStructManager,signalName)

                addSourceInformation(this,signalName,signalType,numImages);
            else
                repeatLastAnnotationStruct(this.ROIAnnotationStructManager,signalName,numImages,[]);
            end

        end


        function configure(this)


            configure@vision.internal.labeler.AnnotationSet(this);


            addlistener(this.LabelSet,'PixelLabelRemoved',@this.onPixelLabelRemoved);


            addlistener(this.SublabelSet,'SublabelAdded',@this.onSublabelAdded);
            addlistener(this.SublabelSet,'SublabelRemoved',@this.onSublabelRemoved);
            addlistener(this.SublabelSet,'SublabelChanged',@this.onSublabelChanged);


            addlistener(this.AttributeSet,'AttributeAdded',@this.onAttributeAdded);
            addlistener(this.AttributeSet,'AttributeRemoved',@this.onAttributeRemoved);
            addlistener(this.AttributeSet,'AttributeChanged',@this.onAttributeChanged);
        end


        function updateAttributeAnnotation(this,signalName,frameIdx,roiUID,labelName,sublabelName,attribData)

            updateAttributeAnnotation(this.ROIAnnotationStructManager,signalName,frameIdx,roiUID,labelName,sublabelName,attribData);
        end

        function resetIsPixelLabelChangedAll(this)
            resetIsPixelLabelChangedAll(this.ROIAnnotationStructManager);
        end

        function resetIsPixelLabelChanged(this,signalName)
            resetIsPixelLabelChanged(this.ROIAnnotationStructManager,signalName);
        end

        function setIsPixelLabelChangedAll(this)
            setIsPixelLabelChangedAll(this.ROIAnnotationStructManager);
        end

        function setIsPixelLabelChanged(this,signalName)
            setIsPixelLabelChanged(this.ROIAnnotationStructManager,signalName);
        end

        function setIsPixelLabelChangedByIdx(this,signalName,idx)
            setIsPixelLabelChangedByIdx(this.ROIAnnotationStructManager,signalName,idx);
        end

        function isPixelLabelChanged=getIsPixelLabelChanged(this,signalName)
            isPixelLabelChanged=getIsPixelLabelChanged(this.ROIAnnotationStructManager,signalName);
        end


        function LabelUID=getParentLabelUID(this,signalName,frameIdx,labelName,sublabelName,sublabelUID)

            LabelUID='';
            if isempty(sublabelName)
                return;
            end

            LabelUID=getParentLabelUID(this.ROIAnnotationStructManager,signalName,frameIdx,labelName,sublabelName,sublabelUID);
        end


        function attribInstanceData=getAttributeInstanceValue(this,signalName,frameIdx,roiUID,attribDefData)
            attribInstanceData=getAttributeInstanceValue(this.ROIAnnotationStructManager,signalName,frameIdx,roiUID,attribDefData);
        end


        function addAnnotation(this,signalName,frameIdx,labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions,varargin)

            assert(ischar(signalName)||isstring(signalName));

            if isempty(varargin)
                doAppend=false;
            else
                doAppend=varargin{1};
            end


            if~iscell(positions)
                positions={positions};
            end

            isPixelLabel=~isempty(positions)&&(ischar(positions{1})||isstring(positions{1}));
            if~isPixelLabel
                sublabelNames=cellstr(sublabelNames);
                labelNames=cellstr(labelNames);
                sublabelUIDs=cellstr(sublabelUIDs);
                labelUIDs=cellstr(labelUIDs);
            end

            addAnnotation(this.ROIAnnotationStructManager,signalName,frameIdx,...
            doAppend,isPixelLabel,...
            labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions);
        end


        function updateAttribAnnotationAtAttribCreation(this,attribData)
            updateAttribAnnotationAtAttribCreation(this.ROIAnnotationStructManager,attribData);
        end


        function appendAnnotation(this,signalName,index,labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions)
            doAppend=true;
            addAnnotation(this,signalName,index,labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions,doAppend)
        end

        function updateSignalName(this,oldName,newName)
            updateSignalName(this.ROIAnnotationStructManager,oldName,newName);
        end


        function appendAttributeFields(~,attributes)
            inS=attributes;
            tmpS=externalParseStruct(inS);
            outS=flattenStructAndReset(tmpS);%#ok<NASGU>
        end


        function removeAnnotation(this,signalName,index,labelName,dataIndex)

            removeAnnotation(this.ROIAnnotationStructManager,signalName,index,labelName,dataIndex);
        end


        function removeAllAnnotations(this,indices)
            removeAllAnnotations(this.ROIAnnotationStructManager,indices);
        end


        function[allUIDs,allPositions,allNames,allColors,allShapes,...
            allAttributes]=queryAnnotationsInInterval(this,signalName,indices)


            [allUIDs,allPositions,allNames,allColors,allShapes,...
            allAttributes]=queryAnnotationsInInterval(...
            this.ROIAnnotationStructManager,signalName,indices);
        end


        function numAnnotations=queryShapeSummary(this,signalName,labelName,indices)
            numAnnotations=queryShapeSummary(this.ROIAnnotationStructManager,signalName,labelName,indices);
        end


        function numAnnotations=queryPixelSummary(this,signalName,pixelLabelIndex,indices)
            numAnnotations=queryPixelSummary(this.ROIAnnotationStructManager,signalName,pixelLabelIndex,indices);
        end


        function num=queryNumSublabelInstances(this,signalName,frameIdx,labelName,labelUID,sublabelNames)
            num=queryNumSublabelInstances(this.ROIAnnotationStructManager,signalName,frameIdx,labelName,labelUID,sublabelNames);
        end



        function[positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=queryAnnotationByReaderId(this,readerIdx,frameIdx)



            [positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=...
            queryAnnotationByReaderId(this.ROIAnnotationStructManager,readerIdx,frameIdx);
        end

        function[positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes]=queryAnnotationBySignalName(this,signalName,frameIdx)



            [positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes]=...
            queryAnnotation(this.ROIAnnotationStructManager,signalName,frameIdx);
        end


        function labelMatrixValue=getPixelLabelAnnotation(this,signalName,index)

            labelMatrixValue=getPixelLabelAnnotation(this.ROIAnnotationStructManager,signalName,index);

        end


        function setPixelLabelAnnotation(this,signalName,index,labelPath)

            setPixelLabelAnnotation(this.ROIAnnotationStructManager,signalName,index,labelPath)
        end


        function[newS,hasAnyAttribDef]=removeAttribFromAnnotationStruct(this,signalName)
            [newS,hasAnyAttribDef]=removeAttribFromAnnotationStruct(this.ROIAnnotationStructManager,signalName);
        end


        function[TF,attribNames,attribVals]=getAttributeDataForThisSublabelROI(this,signalName,...
            labelName,sublabelName,roiUID,frameIdx)
            [TF,attribNames,attribVals]=getAttributeDataForThisSublabelROI(this.ROIAnnotationStructManager,signalName,...
            labelName,sublabelName,roiUID,frameIdx);

        end


        function[TF,attribNames,attribVals]=getAttributeDataForThisLabelROI(this,signalName,...
            labelName,roiUID,frameIdx)
            [TF,attribNames,attribVals]=getAttributeDataForThisLabelROI(this.ROIAnnotationStructManager,signalName,...
            labelName,roiUID,frameIdx);

        end


        function roiSublabels=queryROISublabelFamilyData(this,labelName)
            roiSublabels=this.ROISublabelSet.querySublabelFamily(labelName);
        end


        function[labelSet,subLabelSet,attributeSet]=getLabelSets(this)
            labelSet=this.LabelSet;
            subLabelSet=this.SublabelSet;
            attributeSet=this.AttributeSet;
        end


        function T=export2table(this,timeVectors,signalNames,maintainROIOrder)







            if~iscell(timeVectors)
                timeVectors={timeVectors};
            end

            if(isempty(maintainROIOrder))
                maintainROIOrder=false;
            end
            T=export2table(this.ROIAnnotationStructManager,timeVectors,signalNames,maintainROIOrder);

        end






        function replace(this,signalName,indices,varargin)

            replace(this.ROIAnnotationStructManager,signalName,indices,varargin{:})
        end


        function cache(this,signalNames)

            cache(this.ROIAnnotationStructManager,signalNames);
        end






        function uncache(this,signalNames)

            uncache(this.ROIAnnotationStructManager,signalNames);
        end




        function mergeWithCache(this,signalName,indices,varargin)
            mergeWithCache(this.ROIAnnotationStructManager,signalName,indices,varargin{:})
        end

    end




    methods(Access=protected)

        function onLabelAdded(this,~,data)

            added=this.LabelSet.queryLabel(data.Label);





            if added.ROI~=labelType.PixelLabel
                addLabel(this.ROIAnnotationStructManager,added.Label,[]);
            end
        end


        function onPixelLabelRemoved(this,varargin)
            labelName='PixelLabelData';
            removeLabel(this.ROIAnnotationStructManager,labelName);
        end


        function onSublabelAdded(this,~,data)
            added=this.SublabelSet.querySublabel(data.LabelName,data.SublabelName);





            if added.ROI~=labelType.PixelLabel
                addSublabel(this.ROIAnnotationStructManager,added.LabelName,added.Sublabel);
            end
        end


        function onSublabelRemoved(this,~,data)


            removed=this.SublabelSet.querySublabel(data.LabelName,data.SublabelName);



            if removed.ROI~=labelType.PixelLabel
                removeSublabel(this.ROIAnnotationStructManager,removed.LabelName,removed.Sublabel);
            end
        end


        function onSublabelChanged(this,~,data)
            labelName=data.LabelName;
            newSublabelName=data.SublabelName;
            oldSublabelName=data.OldSublabelName;
            changeSublabel(this.AnnotationStructManager,labelName,oldSublabelName,newSublabelName);
        end


        function onAttributeAdded(this,~,data)
            added=this.AttributeSet.queryAttribute(data.LabelName,data.SublabelName,data.AttributeName);

            labelName=added.LabelName;
            sublabelName=added.SublabelName;
            attributeName=added.Name;
            addAttribute(this.ROIAnnotationStructManager,labelName,sublabelName,attributeName);
        end


        function onAttributeRemoved(this,~,data)

            removed=this.AttributeSet.queryAttribute(data.LabelName,data.SublabelName,data.AttributeName);

            labelName=removed.LabelName;
            sublabelName=removed.SublabelName;
            attributeName=removed.Name;
            removeAttribute(this.ROIAnnotationStructManager,labelName,sublabelName,attributeName);
        end


        function onAttributeChanged(this,~,data)
            newAttribName=data.AttributeName;
            newAttribData=this.AttributeSet.queryAttribute(data.LabelName,data.SublabelName,newAttribName);
            oldAttribName=data.OldAttributeName;
            labelName=newAttribData.LabelName;
            sublabelName=newAttribData.SublabelName;
            changeAttribute(this.AnnotationStructManager,labelName,sublabelName,oldAttribName,newAttribName);
        end
    end




    methods(Hidden)
        function that=saveobj(this)
            that.SublabelSet=this.SublabelSet;
            that.AttributeSet=this.AttributeSet;
            that.ROIAnnotationStructManager=this.ROIAnnotationStructManager;
            that.Version=this.Version;
            that.LabelSet=this.LabelSet;
        end
    end


    methods(Static,Hidden)

        function this=loadobj(that)

            is20aOrGreater=isfield(that,'ROIAnnotationStructManager');
            is18aOrGreater=isfield(that,'SublabelSet');
            is18bOrGreater=isfield(that,'FrameHasAnnotations');

            labelSet=that.LabelSet;

            if is18aOrGreater
                sublabelSet=that.SublabelSet;
                attributeSet=that.AttributeSet;
            else
                sublabelSet=vision.internal.labeler.ROISublabelSet;
                attributeSet=vision.internal.labeler.ROIAttributeSet;
            end

            this=vision.internal.labeler.ROIAnnotationSet(labelSet,...
            sublabelSet,attributeSet);

            if is20aOrGreater
                this.ROIAnnotationStructManager=that.ROIAnnotationStructManager;
                this.AnnotationStructManager=this.ROIAnnotationStructManager;
            else

                needsAnnotStructSetup=false;
                needsFrameHasAnnotationSetup=false;

                if is18aOrGreater
                    this.BackupAnnotationStruct=that.AnnotationStruct;
                else
                    needsAnnotStructSetup=true;
                end

                if is18bOrGreater&&...
                    any(that.FrameHasAnnotations)





                    this.BackupFrameHasAnnotations=that.FrameHasAnnotations;
                else
                    needsFrameHasAnnotationSetup=true;
                end

                if needsAnnotStructSetup||needsFrameHasAnnotationSetup
                    annotationStruct=that.AnnotationStruct;
                    frameHasAnnotations=false(that.NumImages,1);

                    numFrames=length(that.AnnotationStruct);
                    allLabelNames=fieldnames(that.AnnotationStruct);

                    for frame=1:numFrames
                        annotationExists=false;
                        for lInx=1:numel(allLabelNames)
                            label=allLabelNames{lInx};
                            if~strcmp(label,'PixelLabelData')
                                roiPos=that.AnnotationStruct(frame).(label);
                                if~isempty(roiPos)
                                    [numROIs,~]=size(roiPos);

                                    if numROIs>0
                                        annotationExists=true;
                                    end

                                    structArray=struct.empty(0,numROIs);
                                    structArray(1).Position=[];
                                    structArray(1).LabelUIDs='';

                                    for roiNum=1:numROIs
                                        roiStruct=struct();

                                        roiStruct.Position=that.AnnotationStruct(frame).(label)(roiNum,:);
                                        roiStruct.LabelUIDs=vision.internal.getUniqueID();

                                        structArray(roiNum)=roiStruct;
                                    end
                                    annotationStruct(frame).(label)=structArray;
                                else
                                    annotationStruct(frame).(label)=[];
                                end
                            end
                        end
                        frameHasAnnotations(frame)=annotationExists;
                    end

                    if needsAnnotStructSetup
                        this.BackupAnnotationStruct=annotationStruct;
                    end

                    if needsFrameHasAnnotationSetup
                        this.BackupFrameHasAnnotations=frameHasAnnotations;
                    end
                end
            end
        end
    end

    methods



        function completeLoadObj(this,signalName)
            replaceAnnotationStruct(this.ROIAnnotationStructManager,...
            signalName,this.BackupAnnotationStruct);
            replaceFrameHasAnnotations(this.ROIAnnotationStructManager,...
            signalName,this.BackupFrameHasAnnotations);

            this.BackupAnnotationStruct=[];
            this.BackupFrameHasAnnotations=[];
        end
    end
end
