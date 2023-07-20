classdef ROIAnnotationStructManager<lidar.internal.labeler.annotation.AnnotationStructManager




    methods

        function cache(this,signalNames)
            signalNames=cellstr(signalNames);
            for i=1:numel(signalNames)
                signalName=signalNames{i};

                thisAnnotationStructObj=getAnnotationStruct(this,signalName);
                thisAnnotationStructObj.cache();
            end
        end

        function uncache(this,signalNames)
            signalNames=cellstr(signalNames);
            for i=1:numel(signalNames)
                signalName=signalNames{i};

                thisAnnotationStructObj=getAnnotationStruct(this,signalName);
                thisAnnotationStructObj.uncache();
            end
        end


        function updateAttributeAnnotation(this,signalName,frameIdx,roiUID,labelName,sublabelName,attribData)

            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            updateAttributeAnnotation(thisAnnotationStruct,frameIdx,roiUID,labelName,sublabelName,attribData);
        end


        function[positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=...
            queryAnnotationByReaderId(this,readerIdx,frameIdx)
            thisAnnotationStructObj=getAnnotationStructFromIdNoCheck(this,readerIdx);
            [positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,order,roiVisibility]=...
            thisAnnotationStructObj.queryAnnotation(frameIdx);
        end


        function[positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes]=...
            queryAnnotation(this,signalName,frameIdx)
            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            [positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes]=...
            thisAnnotationStructObj.queryAnnotation(frameIdx);
        end


        function addAnnotation(this,signalName,frameIdx,doAppend,isVoxelLabel,...
            labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions)

            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            addAnnotation(thisAnnotationStructObj,frameIdx,doAppend,isVoxelLabel,...
            labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions);
        end


        function removeLabel(this,labelName)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=this.AnnotationStructs{i};
                thisAnnotationStructObj.removeLabel(labelName);
            end
        end

        function addAttribute(this,labelName,sublabelName,attributeName)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=this.AnnotationStructs{i};
                thisAnnotationStructObj.addAttribute(labelName,sublabelName,attributeName);
            end
        end

        function removeAttribute(this,labelName,sublabelName,attributeName)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=this.AnnotationStructs{i};

                thisAnnotationStructObj.removeAttribute(labelName,sublabelName,attributeName);
            end
        end


        function attribInstanceData=getAttributeInstanceValue(this,signalName,frameIdx,roiUID,attribDefData)
            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            attribInstanceData=getAttributeInstanceValue(thisAnnotationStructObj,frameIdx,roiUID,attribDefData);
        end

        function updateAttribAnnotationAtAttribCreation(this,attribData)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=this.AnnotationStructs{i};
                thisAnnotationStructObj.updateAttribAnnotationAtAttribCreation(attribData);
            end
        end



        function[allUIDs,allPositions,allNames,allColors,allShapes,...
            allAttributes]=queryAnnotationsInInterval(this,signalName,indices)

            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            [allUIDs,allPositions,allNames,allColors,allShapes,...
            allAttributes]=queryAnnotationsInInterval(...
            thisAnnotationStructObj,indices);
        end


        function numAnnotations=queryShapeSummary(this,signalName,labelName,indices)
            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            numAnnotations=queryShapeSummary(thisAnnotationStructObj,labelName,indices);
        end


        function numAnnotations=queryVoxelSummary(this,signalName,voxelLabelIndex,indices)
            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            numAnnotations=queryVoxelSummary(thisAnnotationStructObj,voxelLabelIndex,indices);
        end


        function num=queryNumSublabelInstances(this,signalName,frameIdx,labelName,labelUID,sublabelNames)
            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            num=queryNumSublabelInstances(thisAnnotationStructObj,frameIdx,labelName,labelUID,sublabelNames);
        end


        function labelMatrixValue=getVoxelLabelAnnotation(this,signalName,index)

            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            if isempty(thisAnnotationStructObj)
                labelMatrixValue=[];

                return;
            end
            labelMatrixValue=getVoxelLabelAnnotation(thisAnnotationStructObj,index);
        end


        function setVoxelLabelAnnotation(this,signalName,index,labelPath)

            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            if isempty(thisAnnotationStructObj)


                return;
            end

            setVoxelLabelAnnotation(thisAnnotationStructObj,index,labelPath);
        end


        function[TF,attribNames,attribVals]=getAttributeDataForThisLabelROI(this,signalName,...
            labelName,roiUID,frameIdx)
            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            [TF,attribNames,attribVals]=getAttributeDataForThisLabelROI(thisAnnotationStructObj,...
            labelName,roiUID,frameIdx);

        end


        function labelDataTable=export2table(this,timeVectors,signalNames,maintainROIOrder)

            signalNames=cellstr(signalNames);
            numSignals=numel(signalNames);

            if(isempty(maintainROIOrder))
                maintainROIOrder=false;
            end

            labelDataTable=cell(1,numSignals);

            for signalId=1:numSignals

                timeVector=seconds(timeVectors{signalId});

                if size(timeVector,2)~=1
                    timeVector=timeVector';
                end

                thisAnnotationStructObj=getAnnotationStructFromName(this,signalNames{signalId});

                assert(isempty(timeVector)||numel(timeVector)==thisAnnotationStructObj.NumImages,...
                'Expected timeVector and annotation set length to be consistent.')

                newS=formatAnnotationStructure(thisAnnotationStructObj);

                if maintainROIOrder
                    newS=labelStruct2OrderedROIStruct(thisAnnotationStructObj,newS);
                else

                    newS=dropPolygonROIsOrder(thisAnnotationStructObj,newS);
                end
                T=struct2table(newS,'AsArray',true);


                if hasVoxelAnnotation(thisAnnotationStructObj)
                    notChar=cellfun(@(x)~ischar(x),T.VoxelLabelData);
                    T.VoxelLabelData(notChar)={''};
                end

                if~isempty(timeVector)

                    numTimes=thisAnnotationStructObj.NumImages;
                    HoursMins=zeros(numTimes,2);
                    HoursMinsSecs=horzcat(HoursMins,timeVector);

                    maxTime=timeVector(end);

                    displayFormat=vision.internal.labeler.getNiceDurationFormat(maxTime);
                    durationVector=duration(HoursMinsSecs,'Format',displayFormat);


                    T=table2timetable(T,'RowTimes',durationVector);
                end
                labelDataTable{signalId}=T;
            end
        end


        function replace(this,signalName,indices,varargin)

            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            replace(thisAnnotationStructObj,indices,varargin{:});
        end


        function mergeWithCache(this,signalName,indices,varargin)

            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            mergeWithCache(thisAnnotationStructObj,indices,varargin{:})
        end

    end

    methods

        function resetFrameHasAnnotations(this,signalName)
            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            resetFrameHasAnnotations(thisAnnotationStruct);
        end

        function resetIsVoxelLabelChangedAll(this)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStruct=getAnnotationStructFromIdNoCheck(this,i);
                resetIsVoxelLabelChanged(thisAnnotationStruct);
            end
        end

        function resetIsVoxelLabelChanged(this,signalName)
            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            if~isempty(thisAnnotationStruct)
                resetIsVoxelLabelChanged(thisAnnotationStruct);
            end
        end

        function setIsVoxelLabelChangedAll(this)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStruct=getAnnotationStructFromIdNoCheck(this,i);
                setIsVoxelLabelChanged(thisAnnotationStruct);
            end
        end

        function setIsVoxelLabelChangedByIdx(this,signalName,idx)
            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            if~isempty(thisAnnotationStruct)
                setIsVoxelLabelChangedByIdx(thisAnnotationStruct,idx);
            end
        end

        function flagV=getIsVoxelLabelChanged(this,signalName)
            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            flagV=false;
            if~isempty(thisAnnotationStruct)
                flagV=getIsVoxelLabelChanged(thisAnnotationStruct);
            end
        end
    end
end
