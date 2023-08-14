classdef IsSumSquares<optim.internal.problemdef.visitor.Visitor




    properties(Hidden=true,Transient)

        ISS=true;

        Constant=0;

CurrentNodeIdx

CurrentFactor

        Stack={}
    end

    methods

        function iss=getOutputs(visitor)
            iss=visitor.ISS;
        end

    end

    methods

        function visitForest(visitor,forest)


            if forest.SingleTreeSpansAllIndices

                tree=forest.TreeList{1};


                if numel(tree)>1
                    visitor.ISS=false;
                    return;
                end

                visitTree(visitor,tree);
            else


                nTrees=forest.NumTrees;
                treeList=forest.TreeList;


                for i=1:nTrees

                    treei=treeList{i};



                    if numel(treei)>1
                        visitor.ISS=false;
                        return;
                    end


                    visitTree(visitor,treei);

                    if~visitor.ISS

                        return;
                    end
                end
            end
        end

        function visitTree(visitor,tree)


            [visitor.Constant,isMonomialRoot,monomialFactor]=markMonomialTerms(tree);


            iss=all(monomialFactor(isMonomialRoot)>0);

            if~iss


                visitor.ISS=false;
                return;
            end

            visitor.Stack=tree.Stack;



            outerRootIdx=find(isMonomialRoot);
            monomialFactor=monomialFactor(isMonomialRoot);
            nMonomials=numel(outerRootIdx);


            stack=tree.Stack;
            for curMonomial=1:nMonomials



                currentNodeIdx=outerRootIdx(curMonomial);
                visitor.CurrentNodeIdx=currentNodeIdx;
                visitor.CurrentFactor=sqrt(monomialFactor(curMonomial));
                Node=stack{currentNodeIdx};
                acceptVisitor(Node,visitor);

                if~visitor.ISS


                    return;
                end
            end
        end

        function visitDefault(visitor)

            visitor.ISS=false;
        end

        function visitZeroExpressionImpl(visitor,~)
            visitDefault(visitor);
        end

        function visitNumericExpressionImpl(visitor,~)
            visitDefault(visitor);
        end

        function visitVariableExpressionImpl(visitor,~)
            visitDefault(visitor);
        end

        function visitBinaryExpressionImpl(visitor,Node)
            acceptVisitor(Node.Operator,visitor,Node);
        end

        function visitUnaryExpressionImpl(visitor,Node)
            acceptVisitor(Node.Operator,visitor,Node);
        end

        function visitSubsasgnExpressionImpl(visitor,~)

            visitDefault(visitor);
        end

        function visitNonlinearExpressionImpl(visitor,~)
            visitDefault(visitor);
        end

        function visitForLoopWrapper(~,~)


            visitDefault(visitor);
        end

        function visitLHSExpressionImpl(visitor,~)


            visitDefault(visitor);
        end

        function visitColonExpressionImpl(visitor,~)
            visitDefault(visitor);
        end

        function visitEndIndexExpressionImpl(visitor,~)
            visitDefault(visitor);
        end



        visitOperator(visitor,op,Node);

        visitOperatorPower(visitor,op,Node);

        visitOperatorSum(visitor,op,Node);

        visitOperatorTimes(visitor,op,Node);

    end

end
