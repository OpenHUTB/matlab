classdef CreateExprIfSumSquares<optim.internal.problemdef.visitor.IsSumSquares


































    properties(Hidden,Transient)

        NewStack={};

NewRootsIdx

        NumMonomials=0;
    end

    properties(Hidden,Transient)

        NewLHS={};
    end

    methods

        function[iss,newStack,c]=getOutputs(visitor)
            iss=visitor.ISS;
            newStack=visitor.NewStack;
            c=visitor.Constant;
        end

    end

    methods

        function visitForest(~,~)

        end

        function visitTree(visitor,tree)


            visitTree@optim.internal.problemdef.visitor.IsSumSquares(visitor,tree);

            if~visitor.ISS


                return;
            end


            nMonomials=visitor.NumMonomials;
            if nMonomials>1


                rootNodes=cell(1,nMonomials);

                forestIndexList=cell(nMonomials,1);

                treeIndexList=cell(nMonomials,1);

                childrenPos=zeros(1,nMonomials);

                sz=0;

                newStack=visitor.NewStack;
                newRootsIdx=visitor.NewRootsIdx;


                for i=1:nMonomials

                    rootNodei=newStack{newRootsIdx(i)};
                    rootNodes{i}=rootNodei;

                    monomialSize=numel(rootNodei);

                    treeIndexList{i}=1:monomialSize;

                    forestIndexList{i}=sz+treeIndexList{i};

                    sz=sz+monomialSize;

                    childrenPos(i)=rootNodei.StackLength;
                end


                concatNode=optim.internal.problemdef.SubsasgnExpressionImpl([sz,1],forestIndexList,rootNodes,treeIndexList);
                concatNode.ChildrenPosition=cumsum(childrenPos);
                newStack=[newStack,{concatNode}];
                concatNode.StackLength=numel(newStack);
                visitor.NewStack=newStack;
            end
        end

        visitOperatorPower(visitor,Op,Node);

    end


    methods

        function createMonomial(visitor,innerRootIdx,exponenti,factori)




            monomialRootNode=visitor.Stack{innerRootIdx};
            newRoot=monomialRootNode;


            newNodes={};


            if exponenti>1

                powerNode=optim.internal.problemdef.UnaryExpressionImpl(...
                optim.internal.problemdef.Power(monomialRootNode,exponenti),monomialRootNode);

                leftChildStackLength=monomialRootNode.StackLength;
                powerNode.StackLength=leftChildStackLength+1;

                powerNode.ChildrenPosition=leftChildStackLength;
                newNodes={powerNode};
                newRoot=powerNode;
            end


            if factori~=1

                factorNode=optim.internal.problemdef.NumericExpressionImpl(factori);
                timesNode=optim.internal.problemdef.BinaryExpressionImpl(...
                optim.internal.problemdef.Times.getTimesOperatorNoCheck,newRoot,factorNode);

                childStackLength=newRoot.StackLength;
                timesNode.StackLength=childStackLength+2;

                timesNode.ChildrenPosition=[childStackLength,childStackLength+1];
                newNodes=[newNodes,{factorNode,timesNode}];
            end


            innerExprStackIdx=getSubExprStackIdx(visitor,innerRootIdx);
            visitor.NewStack=[visitor.NewStack,visitor.Stack(innerExprStackIdx),newNodes];
            visitor.NumMonomials=visitor.NumMonomials+1;
            visitor.NewRootsIdx(end+1)=numel(visitor.NewStack);
        end

        function stackIdx=getSubExprStackIdx(visitor,subExprRootIdx)




            subExprRootNode=visitor.Stack{subExprRootIdx};


            stackIdx=subExprRootIdx-(subExprRootNode.StackLength-1:-1:0);

        end
    end

end
