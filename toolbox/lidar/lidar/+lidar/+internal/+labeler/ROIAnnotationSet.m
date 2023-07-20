classdef ROIAnnotationSet<vision.internal.labeler.ROIAnnotationSet




    properties(Access=private)
ROIAnnotationStructManager
    end



    methods
        function this=ROIAnnotationSet(labelSet,subLabelSet,attributeSet,varargin)

            this@vision.internal.labeler.ROIAnnotationSet(labelSet,subLabelSet,attributeSet);
            this.ROIAnnotationStructManager=lidar.internal.labeler.annotation.ROIAnnotationStructManager();
            this.AnnotationStructManager=this.ROIAnnotationStructManager;

            if nargin>3
                that=varargin{1};
                if~isempty(that.AnnotationStructManager.AnnotationStructs)
                    annStruct={};
                    for i=1:numel(that.AnnotationStructManager.NumAnnotationStructs)
                        annStruct{end+1}=lidar.internal.labeler.annotation.ROIAnnotationStruct(that.AnnotationStructManager.AnnotationStructs{i},...
                        labelSet,subLabelSet,attributeSet);
                    end
                    this.AnnotationStructManager.AnnotationStructs=annStruct;
                end
            end

            configure(this);
        end

        function configure(this)



            addlistener(this.LabelSet,'LabelAdded',@this.onLabelAdded);
            addlistener(this.LabelSet,'LabelRemoved',@this.onLabelRemoved);
            addlistener(this.LabelSet,'LabelChanged',@this.onLabelChanged);
            addlistener(this.AttributeSet,'AttributeAdded',@this.onAttributeAdded);
            addlistener(this.AttributeSet,'AttributeRemoved',@this.onAttributeRemoved);
            addlistener(this.LabelSet,'VoxelLabelRemoved',@this.onVoxelLabelRemoved);

        end
    end
    methods(Access=protected)

        function onLabelAdded(this,evt,data)

            added=this.LabelSet.queryLabel(data.Label);





            if added.ROI~=lidarLabelType.Voxel
                addLabel(this.ROIAnnotationStructManager,added.Label,[]);
            end
        end


        function onVoxelLabelRemoved(this,varargin)
            labelName='VoxelLabelData';
            removeLabel(this.ROIAnnotationStructManager,labelName);
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
    end

    methods

        function addSourceInformation(this,signalName,signalType,numImages,resetFrameAndVoxelFlag)

            createAndAddAnnotationStruct(this.ROIAnnotationStructManager,annotationType.ROI,signalName,numImages,this.LabelSet,this.SublabelSet,this.AttributeSet,signalType);

            if nargin<5
                resetFrameAndVoxelFlag=true;
            end

            if resetFrameAndVoxelFlag
                resetFrameHasAnnotations(this.ROIAnnotationStructManager,signalName);
                resetIsVoxelLabelChanged(this.ROIAnnotationStructManager,signalName);
            end
        end


        function updateAttributeAnnotation(this,signalName,frameIdx,roiUID,labelName,sublabelName,attribData)

            updateAttributeAnnotation(this.ROIAnnotationStructManager,signalName,frameIdx,roiUID,labelName,sublabelName,attribData);
        end


        function resetIsVoxelLabelChangedAll(this)
            resetIsVoxelLabelChangedAll(this.ROIAnnotationStructManager);
        end

        function resetIsVoxelLabelChanged(this,signalName)
            resetIsVoxelLabelChanged(this.ROIAnnotationStructManager,signalName);
        end


        function setIsVoxelLabelChangedAll(this)
            setIsVoxelLabelChangedAll(this.ROIAnnotationStructManager);
        end

        function setIsVoxelLabelChangedByIdx(this,signalName,idx)
            setIsVoxelLabelChangedByIdx(this.ROIAnnotationStructManager,signalName,idx);
        end


        function isVoxelLabelChanged=getIsVoxelLabelChanged(this,signalName)
            isVoxelLabelChanged=getIsVoxelLabelChanged(this.ROIAnnotationStructManager,signalName);
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

            isVoxelLabel=~isempty(positions)&&(ischar(positions{1})||isstring(positions{1}));
            if~isVoxelLabel
                sublabelNames=cellstr(sublabelNames);
                labelNames=cellstr(labelNames);
                sublabelUIDs=cellstr(sublabelUIDs);
                labelUIDs=cellstr(labelUIDs);
            end

            addAnnotation(this.ROIAnnotationStructManager,signalName,frameIdx,...
            doAppend,isVoxelLabel,...
            labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions);
        end


        function updateAttribAnnotationAtAttribCreation(this,attribData)
            updateAttribAnnotationAtAttribCreation(this.ROIAnnotationStructManager,attribData);
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


        function numAnnotations=queryVoxelSummary(this,signalName,voxelLabelIndex,indices)
            numAnnotations=queryVoxelSummary(this.ROIAnnotationStructManager,signalName,voxelLabelIndex,indices);
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


        function labelMatrixValue=getVoxelLabelAnnotation(this,signalName,index)

            labelMatrixValue=getVoxelLabelAnnotation(this.ROIAnnotationStructManager,signalName,index);

        end


        function setVoxelLabelAnnotation(this,signalName,index,labelPath)

            setVoxelLabelAnnotation(this.ROIAnnotationStructManager,signalName,index,labelPath)
        end



        function[TF,attribNames,attribVals]=getAttributeDataForThisLabelROI(this,signalName,...
            labelName,roiUID,frameIdx)
            [TF,attribNames,attribVals]=getAttributeDataForThisLabelROI(this.ROIAnnotationStructManager,signalName,...
            labelName,roiUID,frameIdx);

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

            labelSet=that.LabelSet;

            sublabelSet=that.SublabelSet;
            attributeSet=that.AttributeSet;

            this=lidar.internal.labeler.ROIAnnotationSet(labelSet,...
            sublabelSet,attributeSet);

            this.ROIAnnotationStructManager=that.ROIAnnotationStructManager;
            this.AnnotationStructManager=this.ROIAnnotationStructManager;
        end
    end

end
