classdef ExtractQuadraticCoefficients<optim.internal.problemdef.visitor.ExtractLinearCoefficients




    properties(Hidden=true,Transient)

        H={};
    end

    properties(Hidden,Transient)

        NodeH={};
    end

    methods

        function obj=ExtractQuadraticCoefficients(vars,totalVar,nElem)
            obj=obj@optim.internal.problemdef.visitor.ExtractLinearCoefficients(vars,totalVar,nElem);
            varnames=string(fieldnames(vars));
            nVars=numel(varnames);
            varH=cell(1,nVars);
            obj.NodeH=varH;
        end

        function[Hval,Aval,bval]=getOutputs(visitor)
            [Aval,bval]=getOutputs@optim.internal.problemdef.visitor.ExtractLinearCoefficients(visitor);
            head=visitor.Head;
            Hval=popH(visitor,head);
        end

        function pushValue(visitor,bval)
            pushValue@optim.internal.problemdef.visitor.ExtractLinearCoefficients(visitor,bval);
            Hval=[];
            pushH(visitor,Hval);
        end

    end

    methods

        function[bval,Aval,Hval]=popChild(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            nodeStackIndex=visitor.NodeStackIndex(childHead);
            if nodeStackIndex==0

                bval=visitor.b{childHead};
                Aval=visitor.A{childHead};
                Hval=visitor.H{childHead};
            else

                bval=visitor.Nodeb{nodeStackIndex};
                Aval=visitor.NodeA{nodeStackIndex};
                Hval=visitor.NodeH{nodeStackIndex};
            end
        end

        function[bval,Aval,Hval]=popQuadNode(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            Hval=visitor.NodeH{nodeIdx};
            Aval=visitor.NodeA{nodeIdx};
            bval=visitor.Nodeb{nodeIdx};
        end

        function Hval=popHNode(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            Hval=visitor.NodeH{nodeIdx};
        end

        function Hval=popH(visitor,idx)

            nodeStackIndex=visitor.NodeStackIndex(idx);
            if nodeStackIndex==0

                Hval=visitor.H{idx};
            else

                Hval=visitor.NodeH{nodeStackIndex};
            end
        end

        function pushH(visitor,Hval)
            head=visitor.Head;
            visitor.H{head}=Hval;
        end

        function pushQuadNode(visitor,Node,Hval,Aval,bval)
            nodeIdx=Node.VisitorIndex;
            visitor.NodeH{nodeIdx}=Hval;
            visitor.NodeA{nodeIdx}=Aval;
            visitor.Nodeb{nodeIdx}=bval;
        end

        function pushHNode(visitor,Node,Hval)
            nodeIdx=Node.VisitorIndex;
            visitor.NodeH{nodeIdx}=Hval;
        end

        function visitZeroExpressionImpl(visitor,Node)
            visitZeroExpressionImpl@optim.internal.problemdef.visitor.ExtractLinearCoefficients(visitor,Node);
            Hval=[];
            pushH(visitor,Hval);
        end

        function visitNumericExpressionImpl(visitor,Node)
            visitNumericExpressionImpl@optim.internal.problemdef.visitor.ExtractLinearCoefficients(visitor,Node);
            Hval=[];
            pushH(visitor,Hval);
        end

        function visitVariableExpressionImpl(visitor,Node)
            visitVariableExpressionImpl@optim.internal.problemdef.visitor.ExtractLinearCoefficients(visitor,Node);
            Hval=[];
            pushH(visitor,Hval);
        end

        visitIndexingNode(visitor,visitTreeFun,forestSize,...
        nTrees,treeList,forestIndexList,treeIndexList);

        function visitLHSExpressionImpl(visitor,LHS)
            visitLHSExpressionImpl@optim.internal.problemdef.visitor.ExtractLinearCoefficients(visitor,LHS);

            Hval=popHNode(visitor,LHS);

            pushH(visitor,Hval);
        end

        function pushLoopVarValue(visitor,loopVar,val)

            pushQuadNode(visitor,loopVar,[],[],val);
        end

        function visitColonExpressionImpl(visitor,Node)
            visitColonExpressionImpl@optim.internal.problemdef.visitor.ExtractLinearCoefficients(visitor,Node);
            Hval=[];
            pushH(visitor,Hval);
        end



        visitUnaryOperator(visitor,op,Node);

        visitElementwiseOperator(visitor,op,Node);

        visitNonlinearUnarySingleton(visitor,op,Node);

        visitOperatorCumprod(visitor,op,Node);

        visitOperatorCumsum(visitor,op,Node);

        visitOperatorDiag(visitor,op,Node);

        visitOperatorDiff(visitor,op,Node);

        visitOperatorLdivide(visitor,op,Node);

        visitOperatorMpower(visitor,op,Node);

        visitOperatorMtimes(visitor,op,Node);

        visitOperatorPower(visitor,op,Node);

        visitOperatorProd(visitor,op,Node);

        visitOperatorRdivide(visitor,op,Node);

        visitOperatorSum(visitor,op,Node);

        visitOperatorTimes(visitor,op,Node);

        visitOperatorTranspose(visitor,op,Node);




        visitOperatorStaticAssign(visitor,op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

    end

end
