classdef FrameAnnotationStructManager<lidar.internal.labeler.annotation.AnnotationStructManager




    methods

        function cache(this)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=getAnnotationStructFromIdNoCheck(this,i);
                thisAnnotationStructObj.cache();
            end
        end

        function uncache(this)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=getAnnotationStructFromIdNoCheck(this,i);
                thisAnnotationStructObj.uncache();
            end
        end


        function[names,colors,ids]=queryAnnotation(this,frameIdx)

            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=getAnnotationStructFromIdNoCheck(this,i);



                [names,colors,ids]=thisAnnotationStructObj.queryAnnotation(frameIdx);
                if~isempty(ids)
                    return;
                end
            end
        end


        function[names,colors,ids]=queryAnnotationByReaderId(this,readerIdx,frameIdx)
            annotStructObj=getAnnotationStructFromIdNoCheck(this,readerIdx);
            [names,colors,ids]=annotStructObj.queryAnnotation(frameIdx);
        end


        function[names,colors,ids]=queryAnnotationBySignalName(this,signalName,frameIdx)
            annotStructObj=getAnnotationStruct(this,signalName);
            [names,colors,ids]=annotStructObj.queryAnnotation(frameIdx);
        end



        function addAnnotation(this,signalName,frameIdx,labelNames,varargin)

            annotStructObj=getAnnotationStruct(this,signalName);
            addAnnotation(annotStructObj,frameIdx,labelNames,varargin{:});

        end


        function removeAnnotation(this,signalName,frameIdx,labelNames)

            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            removeAnnotation(thisAnnotationStruct,frameIdx,...
            labelNames);
        end


        function numAnnotations=querySummary(this,signalName,labelNames,indices)
            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            numAnnotations=querySummary(thisAnnotationStruct,labelNames,indices);
        end


        function replace(this,signalName,indices)

            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            replace(thisAnnotationStruct,indices);
        end


        function labelDataTable=export2table(this,timeVectors,signalNames)

            if nargin==2||(nargin==3&&isempty(signalNames))
                numSignals=this.NumAnnotationStructs;
                queryByName=false;
            else
                signalNames=cellstr(signalNames);
                numSignals=numel(signalNames);
                queryByName=true;
            end

            labelDataTable=cell(1,numSignals);

            for signalId=1:numSignals

                timeVector=seconds(timeVectors{signalId});

                if size(timeVector,2)~=1
                    timeVector=timeVector';
                end

                if queryByName
                    thisAnnotationStructObj=getAnnotationStructFromName(this,signalNames{signalId});
                else
                    thisAnnotationStructObj=getAnnotationStructFromIdNoCheck(this,signalId);
                end
                assert(isempty(timeVector)||numel(timeVector)==thisAnnotationStructObj.NumImages,...
                'Expected timeVector and annotation set length to be consistent.')



                annoS=getAnnotationStruct(thisAnnotationStructObj);
                T=struct2table(annoS,'AsArray',true);

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


        function mergeWithCache(this,signalName,indices,validFieldNames)

            thisAnnotationStructObj=getAnnotationStruct(this,signalName);
            mergeWithCache(thisAnnotationStructObj,indices,validFieldNames)
        end
    end
end
