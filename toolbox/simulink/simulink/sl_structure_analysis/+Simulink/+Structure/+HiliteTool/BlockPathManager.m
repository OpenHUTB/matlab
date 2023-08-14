classdef BlockPathManager<handle



    properties
        BlockPathStack={};
    end

    methods
        function pushToStack(this,bp)


            this.BlockPathStack=[this.BlockPathStack,{bp}];
        end

        function topBlockPath=popFromStack(this)


            if this.isStackEmpty

            elseif this.getStackSize==1
                this.BlockPathStack={};
            elseif this.getStackSize==2
                this.BlockPathStack=this.BlockPathStack(1);
            else
                this.BlockPathStack=this.BlockPathStack(1:end-1);
            end

            topBlockPath=this.getTopFromStack;
        end

        function topBlockPath=getTopFromStack(this)


            if this.isStackEmpty
                topBlockPath=[];
            else
                topBlockPath=this.BlockPathStack{end};
            end
        end

        function tf=isStackEmpty(this)


            tf=numel(this.BlockPathStack)==0;
        end

        function len=getStackSize(this)


            len=numel(this.BlockPathStack);
        end
    end
end

