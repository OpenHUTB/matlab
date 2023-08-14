




classdef FrameAnnotationSet<vision.internal.labeler.AnnotationSet

    properties(Access=protected)


ValidFrameLabelNames



MergeCacheFlagManager
    end

    properties(Access=private)
FrameAnnotationStructManager
    end

    properties(Access=protected,Hidden)
        Version=ver('vision');
    end

    properties(Hidden)


BackupAnnotationStruct
    end

    methods

        function this=FrameAnnotationSet(labelSet,varargin)

            this.FrameAnnotationStructManager=lidar.internal.labeler.annotation.FrameAnnotationStructManager();
            this.AnnotationStructManager=this.FrameAnnotationStructManager;


            this.LabelSet=labelSet;

            if nargin>1
                that=varargin{1};
                if~isempty(that.AnnotationStructManager.AnnotationStructs)
                    annStruct={};
                    for i=1:numel(that.AnnotationStructManager.NumAnnotationStructs)
                        annStruct{end+1}=lidar.internal.labeler.annotation.FrameAnnotationStruct(that.AnnotationStructManager.AnnotationStructs{i},...
                        labelSet);
                    end
                    this.AnnotationStructManager.AnnotationStructs=annStruct;
                end
            end

            configure(this);
        end


        function addSourceInformation(this,signalName,numImages)

            createAndAddAnnotationStruct(this.FrameAnnotationStructManager,annotationType.Frame,signalName,numImages,this.LabelSet);
            if~isempty(this.BackupAnnotationStruct)
                completeLoadObj(this,signalName);
            end
        end


        function appendSourceInformation(this,signalName,numImages)

            if~hasAnnotation(this.FrameAnnotationStructManager,signalName)

                addSourceInformation(this,signalName,numImages);
            else
                repeatLastAnnotationStruct(this.FrameAnnotationStructManager,signalName,numImages,false);
            end
        end


        function configure(this)



            addlistener(this.LabelSet,'LabelAdded',@this.onLabelAdded);
            addlistener(this.LabelSet,'LabelRemoved',@this.onLabelRemoved);
            addlistener(this.LabelSet,'LabelChanged',@this.onLabelChanged);
        end


        function appendAnnotation(this,signalName,index,labelNames,positions)

            addAnnotation(this,signalName,index,labelNames,positions)
        end


        function addAnnotation(this,signalName,index,labelNames,varargin)







            if~isscalar(index)
                index=index(1):index(2);
            end

            labelNames=cellstr(labelNames);
            addAnnotation(this.FrameAnnotationStructManager,signalName,...
            index,labelNames,varargin{:});
        end

        function updateSignalName(this,oldName,newName)
            updateSignalName(this.FrameAnnotationStructManager,oldName,newName);
        end


        function removeAnnotation(this,signalName,index,labelNames)







            if~isscalar(index)
                index=index(1):index(2);
            end

            labelNames=cellstr(labelNames);
            removeAnnotation(this.FrameAnnotationStructManager,signalName,index,labelNames);
        end


        function removeAllAnnotations(this,indices)
            removeAllAnnotations(this.FrameAnnotationStructManager,indices);
        end


        function[names,colors,ids]=queryAnnotation(this,frameIdx)


            [names,colors,ids]=queryAnnotation(this.FrameAnnotationStructManager,frameIdx);
        end



        function[names,colors,ids]=queryAnnotationByReaderId(this,readerIdx,frameIdx)


            [names,colors,ids]=queryAnnotationByReaderId(this.FrameAnnotationStructManager,readerIdx,frameIdx);
        end



        function[names,colors,ids]=queryAnnotationBySignalName(this,signalName,frameIdx)
            annotS=getAnnotationStruct(this.FrameAnnotationStructManager,signalName);
            [names,colors,ids]=queryAnnotation(annotS,frameIdx);
        end


        function[numAnnotations]=querySummary(this,signalName,labelNames,indices)
            indices=max(indices,1);
            numAnnotations=querySummary(this.FrameAnnotationStructManager,signalName,labelNames,indices);
...
...
...
...
...
...
...
...
...
...
...
        end


        function T=export2table(this,timeVectors,signalNames)








            if~iscell(timeVectors)
                timeVectors={timeVectors};
            end

            T=export2table(this.FrameAnnotationStructManager,timeVectors,signalNames);
        end

        function[labelData,labelNames]=exportData(this,timeVectors,signalNames)

            dataTables=export2table(this,timeVectors,signalNames);

            mergedTable=timetable;

            for tableId=1:numel(dataTables)
                mergedTable=[mergedTable;dataTables{tableId}];
            end

            sortedTable=sortrows(mergedTable);

            labelNames=string({this.LabelSet.DefinitionStruct.Name});
            numLabels=numel(this.LabelSet.DefinitionStruct);
            labelData=cell(numel(labelNames),1);

            maxTime=sortedTable.Time(end);

            for labelId=1:numLabels
                labelName=labelNames(labelId);

                labelTable=sortedTable(:,labelName);

                uniqueTimes=unique(labelTable.Time);

                tempLabelTable=labelTable;

                tempLabelTable.(labelName)=double(labelTable.(labelName));

                tempLabelTable=retime(tempLabelTable,uniqueTimes,'mean');

                tempLabelTable.(labelName)=logical(tempLabelTable.(labelName));

                labelTable=tempLabelTable;

                time=labelTable.Time;
                data=labelTable.(labelName);

                outputData=seconds([]);

                indices=find(diff([false;data]));

                for i=1:2:numel(indices)
                    firstIdx=indices(i);

                    if i~=numel(indices)
                        secondIdx=indices(i+1);

                        rowVal=[time(firstIdx),time(secondIdx)];
                    else
                        rowVal=[time(firstIdx),maxTime];
                    end

                    outputData=[outputData;rowVal];
                end

                labelData{labelId}=outputData;
            end
        end







        function replace(this,signalName,indices,validFrameLabelNames)

            if nargin>3
                this.ValidFrameLabelNames=validFrameLabelNames;
            end

            replace(this.FrameAnnotationStructManager,signalName,indices)

        end








        function cache(this)

            cache(this.FrameAnnotationStructManager);
        end


        function uncache(this)

            uncache(this.FrameAnnotationStructManager);
        end




        function mergeWithCache(this,signalName,indices)
            validFieldNames=this.ValidFrameLabelNames;
            mergeWithCache(this.FrameAnnotationStructManager,signalName,indices,validFieldNames)
        end

    end





    methods(Access=protected)
        function onLabelAdded(this,~,data)

            added=this.LabelSet.queryLabel(data.Label);




            addLabel(this.FrameAnnotationStructManager,added.Label,false);
        end
    end




    methods(Access=protected)

        function annotationStruct=fixAnnotationStruct(this,tempAnnotationStruct)




            for i=1:numel(tempAnnotationStruct)
                tempAnnotationStruct(i)=structfun(@(x)convertToLogicalScalar(x),tempAnnotationStruct(i),'UniformOutput',false);
            end

            annotationStruct=tempAnnotationStruct;

            function x=convertToLogicalScalar(x)
                if isempty(x)
                    x=false;
                else
                    x=logical(x(1));
                end
            end
        end
    end

    methods(Access=private)

        function numImages=getNumImages(this,signalNames)
            signalNames=cellstr(signalNames);
            N=numel(signalNames);
            numImages=zeros(N,1);
            for i=1:N
                numImages(i)=getNumImages(this.FrameAnnotationStructManager,signalNames{i});
            end
        end
    end

    methods(Hidden)
        function that=saveobj(this)
            that.FrameAnnotationStructManager=this.FrameAnnotationStructManager;
            that.Version=this.Version;
            that.LabelSet=this.LabelSet;
        end
    end

    methods(Static,Hidden)

        function this=loadobj(that)

            is20aOrGreater=isfield(that,'FrameAnnotationStructManager');

            this=lidar.internal.labeler.FrameAnnotationSet(that.LabelSet);

            if is20aOrGreater
                this.FrameAnnotationStructManager=that.FrameAnnotationStructManager;
                this.AnnotationStructManager=this.FrameAnnotationStructManager;
                this.Version=that.Version;
            else
                annotationStruct=that.AnnotationStruct;
                annotationStruct=fixAnnotationStruct(this,annotationStruct);
                this.BackupAnnotationStruct=annotationStruct;
            end
        end
    end

    methods
        function completeLoadObj(this,signalName)
            replaceAnnotationStruct(this.FrameAnnotationStructManager,...
            signalName,this.BackupAnnotationStruct);
            this.BackupAnnotationStruct=[];
        end
    end
end
