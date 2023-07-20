classdef(Abstract)Visitor<handle




    properties(Hidden,Transient)

        Head=0;
    end

    properties(Hidden,Transient)




        ParentHead=0;



        ChildrenHead=0;




        NumNodes=0;


        Nodes={};


        VisitorIndexMap=[];



        IsVisited=[];
    end


    methods


        function delete(visitor)

            numNodes=visitor.NumNodes;
            nodes=visitor.Nodes;
            for i=1:numNodes
                resetNode(visitor,nodes{i});
            end
        end


        function initializeNode(visitor,Node)
            Node.VisitorIndex=getVisitorIndex(visitor);
            numNodes=visitor.NumNodes+1;
            visitor.Nodes{numNodes}=Node;
            visitor.NumNodes=numNodes;
        end


        function resetNode(~,Node)


            Node.VisitorIndex=[];
        end


        function initializeLHS(visitor,Node)
            if isempty(Node.VisitorIndex)
                initializeNode(visitor,Node);
            end
        end




        function visitForest(visitor,forest)

            if forest.SingleTreeSpansAllIndices

                visitTree(visitor,forest.TreeList{1});
            else



                nTrees=forest.NumTrees;
                treeList=forest.TreeList;
                forestIndexList=forest.ForestIndexList;
                treeIndexList=forest.TreeIndexList;
                forestSize=forest.Size;
                visitor.ChildrenHead=[];


                visitor.visitIndexingNode(@visitTreeFun,...
                forestSize,nTrees,treeList,forestIndexList,treeIndexList);
            end
        end



        function treeIdx=visitTreeFun(visitor,tree,~)

            visitTree(visitor,tree);

            treeHead=visitor.Head;
            visitor.ChildrenHead=treeHead;
            treeIdx=1;

            visitor.Head=treeHead-1;
        end


        function visitTree(visitor,tree)





            stack=tree.Stack;
            for i=1:numel(stack)

                Node=stack{i};




                acceptVisitor(Node,visitor);
            end



        end


        function visitSubsasgnExpressionImpl(visitor,Node)


            nTrees=Node.NumTrees;
            rootList=Node.RootList;
            forestIndexList=Node.ForestIndexList;
            treeIndexList=Node.TreeIndexList;
            forestSize=Node.Size;


            head=visitor.Head;
            newHead=head-nTrees;
            visitor.ChildrenHead=(newHead+1):head;
            visitor.Head=newHead;


            visitor.visitIndexingNode(@(~,~,rootIdx)rootIdx,...
            forestSize,nTrees,rootList,forestIndexList,treeIndexList);
        end


        function visitBinaryExpressionImpl(visitor,Node)


            pos=Node.ChildrenPosition;
            head=visitor.Head;
            if pos(1)==pos(2)
                visitor.ChildrenHead=[head,head];
            elseif pos(1)<pos(2)
                visitor.ChildrenHead=[head-1,head];
                head=head-1;
            else
                visitor.ChildrenHead=[head,head-1];
                head=head-1;
            end
            visitor.Head=head-1;


            acceptVisitor(Node.Operator,visitor,Node);
        end


        function visitUnaryExpressionImpl(visitor,Node)


            head=visitor.Head;
            visitor.ChildrenHead=head;
            visitor.Head=head-1;


            acceptVisitor(Node.Operator,visitor,Node);
        end


        function visitStatementWrapper(visitor,StmtWrapper)

            if isempty(StmtWrapper.VisitorIndex)

                initializeNode(visitor,StmtWrapper);
                visitor.IsVisited(StmtWrapper.VisitorIndex)=false;


                lhsImplList=StmtWrapper.LHSImplList;
                numLHS=numel(lhsImplList);
                for n=1:numLHS
                    thisLHS=lhsImplList{n};
                    initializeLHS(visitor,thisLHS);
                end
            end

            stmtIndex=StmtWrapper.VisitorIndex;
            if visitor.IsVisited(stmtIndex)


                return;
            end

            nStmt=StmtWrapper.NumStatements;
            stmtList=StmtWrapper.StatementList;
            for n=1:nStmt

                acceptVisitor(stmtList{n},visitor);
            end


            visitor.IsVisited(stmtIndex)=true;
        end




        function visitForLoopWrapper(evalVisitor,LoopWrapper)

            loopVar=LoopWrapper.LoopVar;
            loopValues=getValue(LoopWrapper.LoopRange,evalVisitor);
            loopBody=LoopWrapper.LoopBody;
            initializeLHS(evalVisitor,loopVar);


            for k=loopValues

                pushLoopVarValue(evalVisitor,loopVar,k);
                acceptVisitor(loopBody,evalVisitor);


                evalVisitor.IsVisited(loopBody.VisitorIndex:end)=false;
            end
        end



        function pushLoopVarValue(~,~,~)
        end

    end


    methods(Abstract)

        visitZeroExpressionImpl(visitor,node);

        visitNumericExpressionImpl(visitor,node);

        visitVariableExpressionImpl(visitor,node);

        visitNonlinearExpressionImpl(visitor,node);

        visitLHSExpressionImpl(visistor,node);

        visitColonExpressionImpl(visitor,Node);

        visitEndIndexExpressionImpl(visitor,Node);

    end



    methods


        function visitOperatorCumprod(visitor,op,Node)
            visitOperatorCumfcn(visitor,op,Node);
        end

        function visitOperatorCumsum(visitor,op,Node)
            visitOperatorCumfcn(visitor,op,Node);
        end


        function visitOperatorUminus(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end

        function visitOperatorUplus(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end


        function visitOperatorLdivide(visitor,op,Node)
            visitElementwiseOperator(visitor,op,Node);
        end

        function visitOperatorMinus(visitor,op,Node)
            visitElementwiseOperator(visitor,op,Node);
        end

        function visitOperatorPlus(visitor,op,Node)
            visitElementwiseOperator(visitor,op,Node);
        end

        function visitOperatorRdivide(visitor,op,Node)
            visitElementwiseOperator(visitor,op,Node);
        end

        function visitOperatorTimes(visitor,op,Node)
            visitElementwiseOperator(visitor,op,Node);
        end


        function visitNonlinearUnarySingleton(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end

        function visitOperatorCumfcn(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end

        function visitOperatorDiag(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end

        function visitOperatorDiff(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end

        function visitPowerOperator(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end

        function visitOperatorMpower(visitor,op,Node)
            visitPowerOperator(visitor,op,Node);
        end

        function visitOperatorPower(visitor,op,Node)
            visitPowerOperator(visitor,op,Node);
        end

        function visitOperatorProd(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end

        function visitOperatorSum(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end

        function visitOperatorTranspose(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end


        function visitOperatorStaticAssign(visitor,op,Node)
            visitOperator(visitor,op,Node);
        end

        function visitOperatorStaticSubsasgn(visitor,op,Node)
            visitOperatorStaticAssign(visitor,op,Node);
        end

        function visitOperatorStaticSubsref(visitor,op,Node)
            visitUnaryOperator(visitor,op,Node);
        end


        function visitElementwiseOperator(visitor,op,Node)
            visitOperator(visitor,op,Node);
        end

        function visitUnaryOperator(visitor,op,Node)
            visitOperator(visitor,op,Node);
        end

        function visitOperatorMtimes(visitor,op,Node)
            visitOperator(visitor,op,Node);
        end

    end


    methods



        function out=getVisitorIndex(visitor)




            visitorIndexMap=visitor.VisitorIndexMap;
            if isempty(visitorIndexMap)


                visitorIndexMap=false(20,1);
            end


            out=find(visitorIndexMap==false,1);
            if isempty(out)


                out=numel(visitorIndexMap)+1;
                visitorIndexMap(end+20)=false;
            end
            visitorIndexMap(out)=true;
            visitor.VisitorIndexMap=visitorIndexMap;
        end

    end

end
