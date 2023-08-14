classdef ComputeStaticProperties<optim.internal.problemdef.visitor.ComputeType




    properties(Hidden=true,Transient)

        Size={};

        SupportsAD=logical.empty;

        Variables=struct;
    end

    properties(Hidden,Transient)

        NodeSize={};
        NodeSupportsAD=logical.empty;
    end

    methods

        function[type,vars]=getOutputs(visitor,StmtWrapper)

            type=optim.internal.problemdef.ImplType.typeSubsasgn(visitor.NodeType);

            canAD=all(visitor.NodeSupportsAD);


            vars=getVariables(StmtWrapper);


            lhsExprList=StmtWrapper.LHSImplList;
            nExpr=numel(lhsExprList);
            for n=1:nExpr
                LHS=lhsExprList{n};
                LHS.SupportsAD=canAD;
            end






















        end

        function pushValue(visitor,value)
            pushValue@optim.internal.problemdef.visitor.ComputeType(visitor,value);
            sz=size(value);
            canAD=true;
            pushProperties(visitor,sz,canAD);
        end

    end

    methods



        function pushProperties(visitor,sz,canAD)


            head=visitor.Head;
            visitor.Size{head}=sz;
            visitor.SupportsAD(head)=canAD;
        end

        function[type,value,sz,canAD]=popChild(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            type=visitor.Type(childHead);
            value=visitor.Value{childHead};
            sz=visitor.Size{childHead};
            canAD=visitor.SupportsAD(childHead);
        end

        function[sz,canAD]=popChildPties(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            sz=visitor.Size{childHead};
            canAD=visitor.SupportsAD(childHead);
        end

        function pushNodePties(visitor,Node,sz,canAD)
            nodeIdx=Node.VisitorIndex;
            visitor.NodeSize{nodeIdx}=sz;
            visitor.NodeSupportsAD(nodeIdx)=canAD;
        end

        function[type,value,sz,canAD]=popNode(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            type=visitor.NodeType(nodeIdx);
            value=visitor.NodeValue{nodeIdx};
            sz=visitor.NodeSize{nodeIdx};
            canAD=visitor.NodeSupportsAD(nodeIdx);
        end

        function[sz,canAD]=popNodePties(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            sz=visitor.NodeSize{nodeIdx};
            canAD=visitor.NodeSupportsAD(nodeIdx);
        end

        function initializeNode(visitor,Node)
            initializeNode@optim.internal.problemdef.visitor.ComputeType(visitor,Node);
            visitor.NodeSize{Node.VisitorIndex}=[];
            visitor.NodeSupportsAD(Node.VisitorIndex)=true;
        end



        function visitDefault(visitor,Node)
            sz=Node.Size;
            canAD=Node.SupportsAD;
            pushProperties(visitor,sz,canAD);
        end

        function visitZeroExpressionImpl(visitor,Node)
            visitZeroExpressionImpl@optim.internal.problemdef.visitor.ComputeType(visitor,Node);
            visitDefault(visitor,Node);
        end

        function visitNumericExpressionImpl(visitor,Node)
            visitNumericExpressionImpl@optim.internal.problemdef.visitor.ComputeType(visitor,Node);
            visitDefault(visitor,Node);
        end

        function visitVariableExpressionImpl(visitor,Node)
            type=optim.internal.problemdef.ImplType.Linear;



            val=zeros(Node.Size);
            push(visitor,type,val);
            visitDefault(visitor,Node);
        end

        function visitNonlinearExpressionImpl(visitor,Node)
            visitNonlinearExpressionImpl@optim.internal.problemdef.visitor.ComputeType(visitor,Node);
            head=visitor.Head;
            type=visitor.Type(head);
            if type>optim.internal.problemdef.ImplType.Numeric






                error('shared_adlib:static:NonNumericBlackBox',...
                'Call to a black-box function with non-numeric inputs');
            else

                canAD=true;
            end
            sz=Node.Size;
            pushProperties(visitor,sz,canAD);
        end

        function visitLHSExpressionImpl(visitor,Node)

            [type,val,sz,canAD]=popNode(visitor,Node);


            push(visitor,type,val);
            pushProperties(visitor,sz,canAD);
        end



        function visitForLoopWrapper(evalVisitor,LoopWrapper)

            loopVar=LoopWrapper.LoopVar;
            loopValues=getValue(LoopWrapper.LoopRange,evalVisitor);
            loopBody=LoopWrapper.LoopBody;


            numLoopIter=0;
            for k=loopValues
                if numLoopIter>0

                    pushLoopVarValue(evalVisitor,loopVar,k);
                    acceptVisitor(loopBody,evalVisitor);


                    evalVisitor.IsVisited(loopBody.VisitorIndex:end)=false;
                end
                numLoopIter=numLoopIter+1;
            end
            setMaxNumIter(LoopWrapper,numLoopIter);
        end

        function pushLoopVarValue(visitor,loopVar,val)
            pushLoopVarValue@optim.internal.problemdef.visitor.ComputeType(visitor,loopVar,val);

            sz=size(val);
            canAD=true;


            pushNodePties(visitor,loopVar,sz,canAD);



            loopVar.Size=sz;
        end

        function visitColonExpressionImpl(visitor,Node)
            visitColonExpressionImpl@optim.internal.problemdef.visitor.ComputeType(visitor,Node);
            head=visitor.Head;
            val=visitor.Value{head};

            if isempty(Node.Size)



                Node.Size=size(val);
            elseif~isequal(Node.Size,size(val))



                error('shared_adlib:static:SizeChangeDetected',...
                'The size of the colon vector must not change');
            end
            visitDefault(visitor,Node);
        end

        function visitOperator(visitor,Op,Node)

            [rightSz,rightCanAD]=popChildPties(visitor,2);
            [leftSz,leftCanAD]=popChildPties(visitor,1);

            visitOperator@optim.internal.problemdef.visitor.ComputeType(visitor,Op,Node);


            canAD=supportsAD(Op,visitor)&&leftCanAD&&rightCanAD;


            sz=getOutputSize(Op,leftSz,rightSz,visitor);


            pushProperties(visitor,sz,canAD);


            if~isequal(Node.Size,sz)
                error('shared_adlib:static:SizeChangeDetected',...
                'The size of an expression has changed');
            end

        end

        function visitUnaryOperator(visitor,Op,Node)

            [leftSz,leftCanAD]=popChildPties(visitor,1);

            visitUnaryOperator@optim.internal.problemdef.visitor.ComputeType(visitor,Op,Node);


            canAD=supportsAD(Op,visitor)&&leftCanAD;


            sz=getOutputSize(Op,leftSz,[],visitor);


            pushProperties(visitor,sz,canAD);


            if~isequal(Node.Size,sz)
                error('shared_adlib:static:SizeChangeDetected',...
                'The size of an expression has changed');
            end

        end

        visitIndexingNode(visitor,visitTreeFun,...
        forestSize,nTrees,treeList,forestIndexList,treeIndexList);

        storeIndexingData(visitor,forestSize,nTrees,forestIndexList,...
        treeIndexList,types,vals,canAD);

        visitOperatorStaticAssign(visitor,Op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

    end

end
