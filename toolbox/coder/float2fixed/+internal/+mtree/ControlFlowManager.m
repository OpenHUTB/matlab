classdef ControlFlowManager<handle





    properties(Access=private)
        CurrentIteration=[];
        CallerCurrentIteration=[];
        IsConditionalBranch=false;

        StreamLoop=false;
        StreamingFactor=[];
    end

    methods
        function addIterationDimension(this)

            this.CurrentIteration=[this.CurrentIteration,0];
        end

        function removeIterationDimension(this)

            this.CurrentIteration(end)=[];
        end

        function incrementIteration(this)


            this.CurrentIteration(end)=this.CurrentIteration(end)+1;
        end

        function setCalleeControlFlowInfo(this,callee)



            assert(isempty(callee.CallerCurrentIteration),'iterations of callee should be empty before analysis');
            callee.CallerCurrentIteration=this.getCompleteIteration;
            assert(isscalar(callee.IsConditionalBranch)&&~callee.IsConditionalBranch,'conditional status should be false before analysis');
            callee.IsConditionalBranch=this.IsConditionalBranch;
        end

        function val=getLocalIteration(this)

            val=this.CurrentIteration;
        end

        function val=getCompleteIteration(this)


            val=[this.CallerCurrentIteration,this.CurrentIteration];
        end

        function clearCallerControlFlowInfo(this)

            this.CallerCurrentIteration=[];
            this.IsConditionalBranch=false;
        end

        function beginConditional(this,alwaysExecuted)
            if nargin<2
                alwaysExecuted=false;
            end

            if alwaysExecuted




                val=this.IsConditionalBranch(end);
            else
                val=true;
            end

            this.IsConditionalBranch(end+1)=val;
        end

        function endConditional(this)
            this.IsConditionalBranch(end)=[];
        end

        function val=isInConditional(this)
            val=this.IsConditionalBranch(end);
        end

        function setLoopStreamingIfNextNodeIsFor(this,node,streamLoop,streamingFactor)


            nextNode=node.Parent.Next;
            while~isnull(nextNode)&&strcmp(nextNode.kind,'COMMENT')
                nextNode=nextNode.Next;
            end

            if~isnull(nextNode)&&strcmp(nextNode.kind,'FOR')
                this.StreamLoop=streamLoop;
                this.StreamingFactor=streamingFactor;
            end
        end

        function[streamLoop,streamingFactor]=getLoopStreaming(this)
            streamLoop=this.StreamLoop;
            streamingFactor=this.StreamingFactor;


            this.StreamLoop=false;
            this.StreamingFactor=[];
        end
    end
end


