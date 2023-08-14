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

        Stack cell
        Offset double

        CurrentIndex(1,1)double{mustBeNonnegative(CurrentIndex)}=0;

        MemoryInternal double{mustBeNonnegative(MemoryInternal)}=0;

        Limit double=[];

TemporaryStack
TemporaryIndex
TemporaryDimension

    end


    methods




        function label=undo(self,labels)






            if self.CurrentIndex>0

                label=getLabelFromStack(self,self.CurrentIndex,labels);


                self.CurrentIndex=self.CurrentIndex-1;

            else




                label=categorical.empty;
            end

            checkCurrentState(self);

        end




        function label=redo(self,labels)






            if self.CurrentIndex<numel(self.Stack)

                label=getLabelFromStack(self,self.CurrentIndex+1,labels);


                self.CurrentIndex=self.CurrentIndex+1;

            else




                label=categorical.empty;
            end

            checkCurrentState(self);

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

                minZ=idx;
                maxZ=idx;

                switch dim
                case 1
                    oldLabel=oldLabel(minZ:maxZ,min(xIndex):max(xIndex),min(yIndex):max(yIndex));
                    location=[idx,min(xIndex),min(yIndex)];
                case 2
                    oldLabel=oldLabel(min(yIndex):max(yIndex),minZ:maxZ,min(xIndex):max(xIndex));
                    location=[min(yIndex),idx,min(xIndex)];
                case 3
                    oldLabel=oldLabel(min(yIndex):max(yIndex),min(xIndex):max(xIndex),minZ:maxZ);
                    location=[min(yIndex),min(xIndex),idx];
                end


            else



                [m,n,p]=size(label);





                switch dim
                case 1
                    oldLabel=oldLabel(idx:idx+m-1,1:n,1:p);
                    location=[idx,1,1];
                case 2
                    oldLabel=oldLabel(1:m,idx:idx+n-1,1:p);
                    location=[1,idx,1];
                case 3
                    oldLabel=oldLabel(1:m,1:n,idx:idx+p-1);
                    location=[1,1,idx];
                end

            end


            self.Stack{self.CurrentIndex}=oldLabel;
            self.Offset(self.CurrentIndex,:)=location;




            self.MemoryInternal(self.CurrentIndex)=numel(oldLabel);




            if self.CurrentIndex<numel(self.Stack)
                self.Stack(self.CurrentIndex+1:end)=[];
                self.Offset(self.CurrentIndex+1:end,:)=[];
                self.MemoryInternal(self.CurrentIndex+1:end)=[];
            end

            if~isempty(self.Limit)




                if self.CurrentIndex>self.Limit

                    self.Stack(1:self.CurrentIndex-self.Limit)=[];
                    self.Offset(1:self.CurrentIndex-self.Limit,:)=[];
                    self.MemoryInternal(1:self.CurrentIndex-self.Limit)=[];

                    self.CurrentIndex=self.Limit;

                end

            else






                if sum(self.MemoryInternal)>self.MemoryLimit

                    idx=find(cumsum(self.MemoryInternal,'reverse')>self.MemoryLimit,1,'last');

                    if~isempty(idx)&&idx<self.CurrentIndex

                        self.Stack(1:idx)=[];
                        self.Offset(1:idx,:)=[];
                        self.MemoryInternal(1:idx)=[];

                        self.CurrentIndex=self.CurrentIndex-idx;

                    end

                end

            end

            checkCurrentState(self);

        end




        function addToTemporaryStack(self,label,idx,dim)








            switch dim
            case 1
                label=permute(label,[3,2,1]);
            case 2
                label=permute(label,[1,3,2]);
            end

            if isempty(self.TemporaryStack)

                self.TemporaryStack=label;
                self.TemporaryIndex=idx;
                self.TemporaryDimension=dim;

            else

                if idx>self.TemporaryIndex
                    self.TemporaryStack=cat(dim,self.TemporaryStack,label);
                else
                    self.TemporaryIndex=idx;
                    self.TemporaryStack=cat(dim,label,self.TemporaryStack);
                end

            end

        end




        function applyTemporaryStack(self)



            if~isempty(self.TemporaryStack)


                self.CurrentIndex=self.CurrentIndex+1;

                switch self.TemporaryDimension
                case 1
                    location=[self.TemporaryIndex,1,1];
                case 2
                    location=[1,self.TemporaryIndex,1];
                case 3
                    location=[1,1,self.TemporaryIndex];
                end


                self.Stack{self.CurrentIndex}=self.TemporaryStack;
                self.Offset(self.CurrentIndex,:)=location;
                self.MemoryInternal(self.CurrentIndex)=numel(self.TemporaryStack);




                if self.CurrentIndex<numel(self.Stack)
                    self.Stack(self.CurrentIndex+1:end)=[];
                    self.Offset(self.CurrentIndex+1:end,:)=[];
                    self.MemoryInternal(self.CurrentIndex+1:end)=[];
                end

                checkCurrentState(self);

            end

            self.TemporaryStack=[];
            self.TemporaryIndex=[];
            self.TemporaryDimension=[];

        end




        function clear(self)



            self.Stack={};
            self.Offset=[];
            self.MemoryInternal=0;
            self.CurrentIndex=0;
            self.Prior=uint8.empty;

            checkCurrentState(self);

        end




        function updatePrior(self,slice,exclusionMask)








            if isempty(exclusionMask)
                return;
            end

            if iscategorical(slice)
                slice(exclusionMask)=missing;
            else
                slice(exclusionMask)=0;
            end

            self.Prior=slice;

        end




        function setLength(self,n)






            self.Limit=round(double(n));

        end

    end


    methods(Access=private)


        function labels=getLabelFromStack(self,idx,labels)


            sublabel=self.Stack{idx};
            location=self.Offset(idx,:);
            [m,n,p]=size(sublabel);




            self.Stack{idx}=labels(location(1):location(1)+m-1,location(2):location(2)+n-1,location(3):location(3)+p-1);


            labels(location(1):location(1)+m-1,location(2):location(2)+n-1,location(3):location(3)+p-1)=sublabel;

        end


        function checkCurrentState(self)

            if isempty(self.Stack)

                setUndoState(self,false,false);
            else

                if self.CurrentIndex==0

                    setUndoState(self,false,true);
                elseif self.CurrentIndex==numel(self.Stack)

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