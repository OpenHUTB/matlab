classdef MarkMonomialRoots<optim.internal.problemdef.visitor.Visitor












    properties(Hidden=true,Transient)

        Constant=0;


IsMonomialRoot


MonomialFactor

CurNodeIdx
    end

    methods

        function[c,isMonomialRoot,monomialFactor]=getOutputs(visitor)
            c=visitor.Constant;
            isMonomialRoot=visitor.IsMonomialRoot;
            monomialFactor=visitor.MonomialFactor;
        end

    end

    methods

        function visitForest(~,~)

        end

        function visitTree(visitor,tree)

            stack=tree.Stack;

            nNodes=numel(stack);


            visitor.IsMonomialRoot=false(nNodes,1);
            visitor.MonomialFactor=NaN(nNodes,1);



            visitor.IsMonomialRoot(end)=true;
            visitor.MonomialFactor(end)=1;

            for curNodeIdx=nNodes:-1:1


                visitor.CurNodeIdx=curNodeIdx;
                if visitor.IsMonomialRoot(curNodeIdx)




                    Node=stack{curNodeIdx};
                    acceptVisitor(Node,visitor);
                end
            end
        end

        function visitZeroExpressionImpl(visitor,~)


            curNodeIdx=visitor.CurNodeIdx;
            visitor.IsMonomialRoot(curNodeIdx)=false;
            visitor.MonomialFactor(curNodeIdx)=NaN;
        end

        function visitNumericExpressionImpl(visitor,Node)

            curNodeIdx=visitor.CurNodeIdx;
            fac=visitor.MonomialFactor(curNodeIdx);
            visitor.Constant=visitor.Constant+fac.*Node.Value;


            visitor.IsMonomialRoot(curNodeIdx)=false;
            visitor.MonomialFactor(curNodeIdx)=NaN;
        end

        function visitVariableExpressionImpl(~,~)

        end

        function visitBinaryExpressionImpl(visitor,Node)
            acceptVisitor(Node.Operator,visitor,Node);
        end

        function visitUnaryExpressionImpl(visitor,Node)
            acceptVisitor(Node.Operator,visitor,Node);
        end

        function visitSubsasgnExpressionImpl(~,~)


        end

        function visitNonlinearExpressionImpl(~,~)

        end

        function visitForLoopWrapper(~,~)


        end

        function visitLHSExpressionImpl(~,~)


        end

        function visitColonExpressionImpl(~,~)

        end

        function visitEndIndexExpressionImpl(~,~)


        end



        visitOperator(visitor,op,Node);

        visitOperatorMinus(visitor,op,Node);

        visitOperatorPlus(visitor,op,Node);

        visitOperatorSum(visitor,op,Node);

        visitOperatorTimes(visitor,op,Node);

        visitOperatorTranspose(visitor,op,Node);

        visitOperatorUminus(visitor,op,Node);

        visitOperatorUplus(visitor,op,Node);

    end

end
