classdef History<handle&matlab.mixin.SetGet




    events




HistoryUpdated

    end

    properties(Hidden,Transient)

        MemoryLimit(1,1)double{mustBeNonnegative(MemoryLimit)}=Inf;

        Prior;

    end


    properties(Access=private,Hidden,Transient)

        UndoAvailableInternal(1,1)logical=false;
        RedoAvailableInternal(1,1)logical=false;

        Stack table
        Offset double

        CurrentIndex(1,1)double{mustBeNonnegative(CurrentIndex)}=0;

        MemoryInternal double{mustBeNonnegative(MemoryInternal)}=0;

        Limit double=[];

TemporaryStack
TemporaryIndex
TemporaryDimension

    end

    properties(Access=protected)
        HistoryStackVariableNames=["Label","Index","SliceDirection","IsVolumeBasedAutomationResult"];
        HistoryStackVariableTypes=["cell","double","medical.internal.app.labeler.enums.SliceDirection","logical"];
    end

    methods

        function self=History()

            self.Stack=table('Size',[0,length(self.HistoryStackVariableNames)],...
            'VariableNames',self.HistoryStackVariableNames,...
            'VariableTypes',self.HistoryStackVariableTypes);

        end


        function add(self,oldLabel,label,idx,dim)







            self.CurrentIndex=self.CurrentIndex+1;




            if islogical(label)&&ismatrix(label)



                xGrid=sum(label,1);
                yGrid=sum(label,2);

                xIndex=find(xGrid);
                yIndex=find(yGrid);




                if isempty(xIndex)
                    xIndex=1;
                end

                if isempty(yIndex)
                    yIndex=1;
                end

                oldLabelSlice=oldLabel.getSlice(idx,dim);

                sublabel=oldLabelSlice(min(yIndex):max(yIndex),min(xIndex):max(xIndex));
                location=[min(yIndex),min(xIndex)];

            else




                sublabel=zeros(size(label),class(label));
                location=[1,1];

                for i=1:size(label,3)
                    sublabel(:,:,i)=oldLabel.getSlice(idx+i-1,dim);
                end

            end



            if isscalar(sublabel)




                sublabel={sublabel};
            end

            isVolumeBasedAutomationResult=false;
            newEntry={sublabel,idx,dim,isVolumeBasedAutomationResult};
            newEntry=cell2table(newEntry,'VariableNames',self.HistoryStackVariableNames);
            self.Stack(self.CurrentIndex,:)=newEntry;
            self.Offset(self.CurrentIndex,:)=location;

            newEntrySize=numel(sublabel);
            self.pruneStackIfNeeded(newEntrySize);

            self.checkCurrentState();

        end


        function undo(self,labels)






            if self.CurrentIndex>0

                getLabelFromStack(self,self.CurrentIndex,labels);


                self.CurrentIndex=self.CurrentIndex-1;

            else





            end

            self.checkCurrentState();

        end


        function redo(self,labels)






            if self.CurrentIndex<height(self.Stack)

                getLabelFromStack(self,self.CurrentIndex+1,labels);


                self.CurrentIndex=self.CurrentIndex+1;

            else





            end

            self.checkCurrentState();

        end


        function addVolumeBasedAutomationResults(self,labelData)


            self.CurrentIndex=self.CurrentIndex+1;


            isVolumeAutomationResult=true;
            newEntry={labelData,1,1,isVolumeAutomationResult};
            newEntry=cell2table(newEntry,'VariableNames',self.HistoryStackVariableNames);
            self.Stack(self.CurrentIndex,:)=newEntry;
            self.Offset(self.CurrentIndex,:)=[1,1];

            newEntrySize=numel(labelData);
            self.pruneStackIfNeeded(newEntrySize);

            self.checkCurrentState();

        end


        function addToTemporaryStack(self,label,idx,dim)








            if isempty(self.TemporaryStack)

                self.TemporaryStack=label;
                self.TemporaryIndex=idx;
                self.TemporaryDimension=dim;

            else

                if idx>self.TemporaryIndex
                    self.TemporaryStack=cat(3,self.TemporaryStack,label);
                else
                    self.TemporaryIndex=idx;
                    self.TemporaryStack=cat(3,label,self.TemporaryStack);
                end

            end

        end


        function applyTemporaryStack(self)



            if~isempty(self.TemporaryStack)


                self.CurrentIndex=self.CurrentIndex+1;

                isVolumeBasedAutomationResult=false;
                newEntry={self.TemporaryStack,self.TemporaryIndex,self.TemporaryDimension,isVolumeBasedAutomationResult};
                newEntry=cell2table(newEntry,'VariableNames',self.HistoryStackVariableNames);


                self.Stack(self.CurrentIndex,:)=newEntry;
                self.Offset(self.CurrentIndex,:)=[1,1];
                self.MemoryInternal(self.CurrentIndex)=numel(self.TemporaryStack);




                if self.CurrentIndex<height(self.Stack)
                    self.Stack(self.CurrentIndex+1:end,:)=[];
                    self.Offset(self.CurrentIndex+1:end,:)=[];
                    self.MemoryInternal(self.CurrentIndex+1:end)=[];
                end

                self.checkCurrentState();

            end

            self.TemporaryStack=[];
            self.TemporaryIndex=[];
            self.TemporaryDimension=[];

        end


        function updatePrior(self,slice,exclusionMask)








            if isempty(exclusionMask)
                return;
            end

            slice(exclusionMask)=0;

            self.Prior=slice;

        end


        function setLength(self,n)






            self.Limit=round(double(n));

        end


        function clear(self)



            self.Stack(:,:)=[];
            self.Offset=[];
            self.MemoryInternal=0;
            self.CurrentIndex=0;
            self.Prior=uint8.empty;

            self.checkCurrentState();

        end

    end

    methods(Access=protected)


        function getLabelFromStack(self,idx,labels)


            sublabel=self.Stack.Label{idx};
            sliceDir=self.Stack.SliceDirection(idx);
            startIdx=self.Stack.Index(idx);
            isVolumeBasedAutomationResult=self.Stack.IsVolumeBasedAutomationResult(idx);
            location=self.Offset(idx,:);

            if isVolumeBasedAutomationResult
                currLabel=labels.RawData;
                labels.RawData=sublabel;
                self.Stack.Label{idx}=currLabel;
            else

                [m,n]=size(sublabel,[1,2]);





                newSublabel=zeros(size(sublabel),class(sublabel));
                for i=1:size(sublabel,3)

                    slice=labels.getSlice(startIdx+i-1,sliceDir);
                    newSublabel(:,:,i)=slice(location(1):location(1)+m-1,location(2):location(2)+n-1);


                    slice(location(1):location(1)+m-1,location(2):location(2)+n-1)=sublabel(:,:,i);
                    labels.setSlice(slice,startIdx+i-1,sliceDir)
                end

                self.Stack.Label{idx}=newSublabel;

            end

        end


        function pruneStackIfNeeded(self,newEntrySize)




            self.MemoryInternal(self.CurrentIndex)=newEntrySize;




            if self.CurrentIndex<height(self.Stack)
                self.Stack(self.CurrentIndex+1:end,:)=[];
                self.Offset(self.CurrentIndex+1:end,:)=[];
                self.MemoryInternal(self.CurrentIndex+1:end)=[];
            end

            if~isempty(self.Limit)




                if self.CurrentIndex>self.Limit

                    self.Stack(1:self.CurrentIndex-self.Limit,:)=[];
                    self.Offset(1:self.CurrentIndex-self.Limit,:)=[];
                    self.MemoryInternal(1:self.CurrentIndex-self.Limit)=[];

                    self.CurrentIndex=self.Limit;

                end

            else






                if sum(self.MemoryInternal)>self.MemoryLimit

                    idx=find(cumsum(self.MemoryInternal,'reverse')>self.MemoryLimit,1,'last');

                    if~isempty(idx)&&idx<self.CurrentIndex

                        self.Stack(1:idx,:)=[];
                        self.Offset(1:idx,:)=[];
                        self.MemoryInternal(1:idx)=[];

                        self.CurrentIndex=self.CurrentIndex-idx;

                    end

                end

            end

        end


        function checkCurrentState(self)

            if isempty(self.Stack)

                setUndoState(self,false,false);
            else

                if self.CurrentIndex==0

                    setUndoState(self,false,true);
                elseif self.CurrentIndex==height(self.Stack)

                    setUndoState(self,true,false);
                else

                    setUndoState(self,true,true);
                end
            end

        end


        function setUndoState(self,undo,redo)

            self.UndoAvailableInternal=undo;
            self.RedoAvailableInternal=redo;

            update(self);

        end


        function update(self)

            notify(self,'HistoryUpdated',images.internal.app.segmenter.volume.events.HistoryUpdatedEventData(...
            self.UndoAvailableInternal,self.RedoAvailableInternal));
        end

    end


end