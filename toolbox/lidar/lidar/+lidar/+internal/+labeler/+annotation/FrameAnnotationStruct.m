classdef FrameAnnotationStruct<vision.internal.labeler.annotation.AnnotationStruct


    properties(Access=private)
LabelSet
MergeCacheFlag
    end

    methods
        function this=FrameAnnotationStruct(varargin)

            if nargin<3
                that=varargin{1};
                signalName=that.SignalName;
                numImages=that.NumImages;
                labelSet=varargin{2};
            else
                signalName=varargin{1};
                numImages=varargin{2};
                labelSet=varargin{3};
            end
            this=this@vision.internal.labeler.annotation.AnnotationStruct(signalName,numImages);
            this.LabelSet=labelSet;
            createDefaultAnnotationStruct(this);

            if nargin<3
                this.AnnotationStruct_=that.AnnotationStruct_;
            end
        end

        function repeatHasAnnotationField(~,~)

        end


        function numAnnotations=querySummary(this,labelNames,indices)
            numLabels=numel(labelNames);

            numAnnotations=struct();

            for n=1:numLabels
                label=labelNames{n};
                numAnnotations.(label)=[this.AnnotationStruct_(indices).(label)];
            end
        end

        function replace(this,indices)


            fieldNames=fieldnames(this.AnnotationStruct_);
            fieldVals=repmat({false},size(fieldNames));
            annStruct=cell2struct(fieldVals,fieldNames,1);



            this.AnnotationStruct_(indices)=repmat(annStruct,size(indices));

        end


        function cache(this)

            cache@vision.internal.labeler.annotation.AnnotationStruct(this);
            this.MergeCacheFlag=false(1,this.NumImages);
        end





        function mergeWithCache(this,indices,validFieldNames)


            newAnnotationsInterval=this.AnnotationStruct_(indices);


            uncache(this);






            if isempty(validFieldNames)


                return;
            end

            for idx=1:numel(indices)

                if this.MergeCacheFlag(indices(idx))
                    oldAnnotations=this.AnnotationStruct_(indices(idx));
                    newAnnotations=newAnnotationsInterval(idx);

                    for n=1:numel(validFieldNames)
                        fName=validFieldNames{n};
                        oldAnnotations.(fName)=newAnnotations.(fName);
                    end
                    this.AnnotationStruct_(indices(idx))=oldAnnotations;
                end
            end
            this.MergeCacheFlag=[];
        end


        function removeAllAnnotations(this,indices)
            this.AnnotationStruct_(indices)=[];
            if isempty(this.AnnotationStruct_)
                this.AnnotationStruct_=struct();
            end
            this.NumImages=this.NumImages-numel(indices);
        end
    end

    methods(Access=protected)

        function initialize(this,numImages)



            labelSet=this.LabelSet;


            this.AnnotationStruct_=struct();

            for n=1:labelSet.NumLabels
                labelName=labelSet.labelIDToName(n);
                this.AnnotationStruct_(end).(labelName)=false;
            end

            if nargin>1
                this.NumImages=numImages;
                this.AnnotationStruct_=repmat(this.AnnotationStruct_,numImages,1);
            else
                this.NumImages=0;
            end
        end

    end

    methods(Access=private)
        function createDefaultAnnotationStruct(this)

            labelSet=this.LabelSet;
            for n=1:labelSet.NumLabels
                labelName=labelSet.labelIDToName(n);
                this.AnnotationStruct_(end).(labelName)=false;
            end

            this.AnnotationStruct_=repmat(this.AnnotationStruct_,this.NumImages,1);
        end
    end

    methods

        function[names,colors,ids]=queryAnnotation(this,frameIdx)




            assert(isscalar(frameIdx),'Expected time index to be a scalar');

            labelSet=this.LabelSet;

            frameIdx=max(frameIdx,1);
            s=getAnnotationStructPerFrame(this,frameIdx);

            allLabels=fieldnames(s);

            names={};
            colors={};
            ids=[];

            if isempty(s)
                return;
            end

            for n=1:numel(allLabels)
                label=allLabels{n};
                if s.(label)
                    names{end+1}=label;%#ok<AGROW>

                    labelID=labelSet.labelNameToID(label);
                    colors{end+1}=labelSet.queryLabelColor(labelID);%#ok<AGROW>
                    ids(end+1)=labelID;%#ok<AGROW>
                end
            end

        end

        function addAnnotation(this,index,labelNames,varargin)



            s=this.AnnotationStruct_(index);


            if nargin==3
                for n=1:numel(labelNames)
                    [s.(labelNames{n})]=deal(true);
                end
            else
                labelVals=varargin{1};
                for n=1:numel(labelNames)
                    [s.(labelNames{n})]=deal(labelVals{n});
                end
            end


            this.AnnotationStruct_(index)=s;

            if~isempty(this.MergeCacheFlag)
                this.MergeCacheFlag(index)=true;
            end
        end

        function removeAnnotation(this,index,labelNames)



            s=this.AnnotationStruct_(index);


            for n=1:numel(labelNames)
                [s.(labelNames{n})]=deal(false);
            end


            this.AnnotationStruct_(index)=s;

            if~isempty(this.MergeCacheFlag)
                this.MergeCacheFlag(index)=true;
            end
        end


        function changeLabel(this,oldLabelName,newLabelName)

            numImages=this.NumImages;

            for i=1:numImages

                this.AnnotationStruct_(i).(newLabelName)=this.AnnotationStruct_(i).(oldLabelName);
            end


            this.AnnotationStruct_=rmfield(this.AnnotationStruct_,oldLabelName);
        end


    end
end