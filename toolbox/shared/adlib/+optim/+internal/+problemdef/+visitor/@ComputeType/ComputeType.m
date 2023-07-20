classdef ComputeType<optim.internal.problemdef.visitor.Visitor




    properties(Hidden=true,Transient)

        Type=optim.internal.problemdef.ImplType.empty;

        Value={};
    end

    properties(Hidden,Transient)

        NodeType=optim.internal.problemdef.ImplType.empty;
        NodeValue={};
    end

    methods

        function type=getOutputs(visitor)
            head=visitor.Head;
            type=visitor.Type(head);
        end

        function value=getValue(visitor)
            head=visitor.Head;
            value=visitor.Value{head};
            visitor.Head=visitor.Head-1;
        end

        function pushValue(visitor,value)
            type=optim.internal.problemdef.ImplType.Numeric;
            push(visitor,type,value);
        end

    end

    methods

        function push(visitor,type,value)
            head=visitor.Head+1;
            visitor.Type(head)=type;
            visitor.Value{head}=value;
            visitor.Head=head;
        end

        function[type,value]=popChild(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            type=visitor.Type(childHead);
            value=visitor.Value{childHead};
        end

        function[type,value]=popParent(visitor)
            parentHead=visitor.ParentHead;
            type=visitor.Type(parentHead);
            value=visitor.Value{parentHead};
        end

        function pushNode(visitor,Node,type,value)
            nodeIdx=Node.VisitorIndex;
            visitor.NodeType(nodeIdx)=type;
            visitor.NodeValue{nodeIdx}=value;
        end

        function[type,value]=popNode(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            type=visitor.NodeType(nodeIdx);
            value=visitor.NodeValue{nodeIdx};
        end

        function visitZeroExpressionImpl(visitor,Node)
            type=optim.internal.problemdef.ImplType.Numeric;
            val=zeros(Node.Size);
            push(visitor,type,val);
        end

        function visitNumericExpressionImpl(visitor,Node)
            type=optim.internal.problemdef.ImplType.Numeric;
            val=Node.Value;
            push(visitor,type,val);
        end

        function visitVariableExpressionImpl(visitor,~)
            type=optim.internal.problemdef.ImplType.Linear;
            val=[];
            push(visitor,type,val);
        end

        function visitColonExpressionImpl(visitor,Node)
            type=optim.internal.problemdef.ImplType.Numeric;

            val=getValue(Node,visitor);
            push(visitor,type,val);
        end


        function visitOperator(visitor,Op,~)

            [leftType,leftVal]=popChild(visitor,1);
            [rightType,rightVal]=popChild(visitor,2);
            type=getOutputType(Op,leftType,rightType,visitor);

            if type==optim.internal.problemdef.ImplType.Numeric
                val=evaluate(Op,leftVal,rightVal,visitor);
            else
                val=[];
            end

            push(visitor,type,val);
        end

        function visitUnaryOperator(visitor,Op,~)


            [leftType,leftVal]=visitor.popChild(1);

            type=getOutputType(Op,leftType,[],visitor);

            if type==optim.internal.problemdef.ImplType.Numeric
                val=evaluate(Op,leftVal,[],visitor);
            else
                val=[];
            end

            push(visitor,type,val);
        end

        function visitNonlinearExpressionImpl(visitor,Node)
            [type,outputVals]=visitFunctionWrapper(visitor,Node.FunctionImpl);
            val=outputVals{Node.OutputIndex};
            push(visitor,type,val);
        end

        function[type,val]=visitFunctionWrapper(visitor,fcnWrapper)

            inputs=fcnWrapper.Inputs;
            nInputs=numel(inputs);
            type=optim.internal.problemdef.ImplType.Numeric;
            val=cell(1,fcnWrapper.NumArgOut);
            inputVals=cell(1,nInputs);
            for i=1:nInputs
                inputi=inputs{i};

                visitForest(visitor,inputi);

                head=visitor.Head;
                inputType=visitor.Type(head);
                inputVals{i}=visitor.Value{head};

                visitor.Head=head-1;

                if inputType>optim.internal.problemdef.ImplType.Numeric
                    type=optim.internal.problemdef.ImplType.Nonlinear;
                    return;
                end
            end


            [val{:}]=feval(fcnWrapper.Func,inputVals{:});
        end

        function visitLHSExpressionImpl(visitor,Node)

            [type,val]=popNode(visitor,Node);


            push(visitor,type,val);
        end

        function pushLoopVarValue(visitor,loopVar,val)

            type=optim.internal.problemdef.ImplType.Numeric;
            pushNode(visitor,loopVar,type,val);
        end

        function visitEndIndexExpressionImpl(visitor,~)
            [~,endVal]=popParent(visitor);
            pushValue(visitor,endVal);
        end

        visitIndexingNode(visitor,visitTreeFun,forestSize,...
        nTrees,treeList,forestIndexList,treeIndexList);

        storeIndexingData(visitor,forestSize,nTrees,forestIndexList,...
        treeIndexList,types,vals);

        visitOperatorStaticAssign(visitor,Op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

    end

end
