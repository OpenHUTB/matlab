classdef Evaluate<optim.internal.problemdef.visitor.Visitor




    properties(Hidden=true,Transient)

        Value={};
    end

    properties(Hidden,Transient)

        NodeValue={};
    end

    methods

        function visitor=Evaluate(varVal,vars)
            varnames=fieldnames(vars);
            nVar=numel(varnames);
            for i=1:nVar
                thisVarname=varnames{i};
                thisVarImpl=getVariableImpl(vars.(thisVarname));

                initializeNode(visitor,thisVarImpl);

                pushNode(visitor,thisVarImpl,varVal.(thisVarname));
            end
        end

        function value=getOutputs(visitor)
            head=visitor.Head;
            value=visitor.Value{head};
        end

        function value=getValue(visitor)
            head=visitor.Head;
            value=visitor.Value{head};
            visitor.Head=head-1;
        end

        function pushValue(visitor,val)
            push(visitor,val);
        end

    end

    methods

        function push(visitor,val)
            head=visitor.Head+1;
            visitor.Value{head}=val;
            visitor.Head=head;
        end

        function val=popChild(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            val=visitor.Value{childHead};
        end

        function val=popParent(visitor)
            parentHead=visitor.ParentHead;
            val=visitor.Value{parentHead};
        end

        function pushNode(visitor,Node,val)
            nodeIdx=Node.VisitorIndex;
            visitor.NodeValue{nodeIdx}=val;
        end

        function val=popNode(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            val=visitor.NodeValue{nodeIdx};
        end

        function visitZeroExpressionImpl(visitor,Node)
            val=zeros(Node.Size);
            push(visitor,val);
        end

        function visitNumericExpressionImpl(visitor,Node)
            val=Node.Value;
            push(visitor,val);
        end

        function visitVariableExpressionImpl(visitor,Node)
            val=popNode(visitor,Node);
            push(visitor,val);
        end


        function visitOperator(visitor,Op,~)

            leftVal=popChild(visitor,1);
            rightVal=popChild(visitor,2);
            val=evaluate(Op,leftVal,rightVal,visitor);
            push(visitor,val);
        end

        function visitUnaryOperator(visitor,Op,~)

            leftVal=popChild(visitor,1);
            val=evaluate(Op,leftVal,[],visitor);
            push(visitor,val);
        end

        visitIndexingNode(visitor,visitTreeFun,forestSize,...
        nTrees,treeList,forestIndexList,treeIndexList);

        function visitNonlinearExpressionImpl(visitor,Node)
            outputVals=visitFunctionWrapper(visitor,Node.FunctionImpl);
            val=outputVals{Node.OutputIndex};
            push(visitor,val);
        end

        val=visitFunctionWrapper(visitor,fcnWrapper);

        function visitLHSExpressionImpl(visitor,LHS)

            val=popNode(visitor,LHS);


            push(visitor,val);
        end

        function pushLoopVarValue(visitor,loopVar,val)

            pushNode(visitor,loopVar,val);
        end

        function visitColonExpressionImpl(visitor,Node)

            val=getValue(Node,visitor);
            push(visitor,val);
        end

        function visitEndIndexExpressionImpl(visitor,~)
            endVal=popParent(visitor);
            pushValue(visitor,endVal);
        end

        visitOperatorStaticAssign(visitor,Op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

    end

end
