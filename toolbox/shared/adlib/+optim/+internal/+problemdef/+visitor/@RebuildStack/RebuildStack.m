classdef RebuildStack<optim.internal.problemdef.visitor.Visitor




    properties(Transient)



        Stack={};

        NewStack={}

        CurPos=0;
    end

    methods

        function visitor=RebuildStack(stackLength)

            visitor.NewStack=cell(1,stackLength);
        end

        function newStack=getOutputs(visitor)

            RootPos=visitor.CurPos;
            Root=visitor.NewStack{RootPos};
            removeSubsrefPassThrough(visitor,Root,RootPos);
            newStack=visitor.NewStack;


            numBadNodes=visitor.Head-1;
            if numBadNodes


                badNodes=visitor.Stack(1:numBadNodes);

                badStackIdx=cellfun(@(badNode)findBadStack(badNode,newStack),badNodes,...
                'UniformOutput',false);
                badStackIdx=[badStackIdx{:}];
                newStack(badStackIdx)=[];
            end



            function badStackIdx=findBadStack(badNode,newStack)
                badNodeIdx=find(cellfun(@(node)isequal(badNode,node),newStack));
                badStackIdx=(badNodeIdx-badNode.StackLength+1):badNodeIdx;
            end
        end
    end

    methods


        function push(visitor,Node)

            head=visitor.Head+1;
            visitor.Stack{head}=Node;
            visitor.Head=head;

            curPos=visitor.CurPos+1;
            visitor.NewStack{curPos}=Node;
            visitor.CurPos=curPos;
        end

        function Node=pop(visitor,NodesChildrenList)
            head=visitor.Head;
            Node=visitor.Stack{head};
            head=head-1;





            while~any(cellfun(@(child)isequal(Node,child),NodesChildrenList))&&head>0

                badNode=Node;
                Node=visitor.Stack{head};
                head=head-1;


                badNodeIdx=find(cellfun(@(child)isequal(badNode,child),visitor.NewStack));
                badNodeStackLength=badNode.StackLength;
                visitor.NewStack(badNodeIdx-badNodeStackLength+1:badNodeIdx)=[];
                visitor.CurPos=visitor.CurPos-badNodeStackLength;
            end
            visitor.Head=head;
        end

    end

    methods

        function visitForest(~,~)

        end

        function visitLeaf(visitor,Node)

            push(visitor,Node);
        end

        function visitZeroExpressionImpl(visitor,Node)

            visitLeaf(visitor,Node);
        end

        function visitNumericExpressionImpl(visitor,Node)
            visitLeaf(visitor,Node);
        end

        function visitVariableExpressionImpl(visitor,Node)
            visitLeaf(visitor,Node);
        end

        function visitNonlinearExpressionImpl(visitor,Node)
            visitLeaf(visitor,Node);
        end

        function visitLHSExpressionImpl(visitor,Node)




            head=visitor.Head;
            if head>0&&isa(visitor.Stack{head},'optim.internal.problemdef.StatementWrapper')


                Node.StackLength=2;
                visitor.Head=head-1;
            else
                Node.StackLength=1;
            end
            visitLeaf(visitor,Node);
        end

        function visitForLoopWrapper(visitor,Node)
            visitLeaf(visitor,Node);
        end

        function visitStatementWrapper(visitor,Node)
            visitLeaf(visitor,Node);
        end

        function visitColonExpressionImpl(visitor,Node)
            visitLeaf(visitor,Node);
        end

        function visitEndIndexExpressionImpl(visitor,Node)
            visitLeaf(visitor,Node);
        end

        function visitBinaryExpressionImpl(visitor,Node)

            ExprLeft=Node.ExprLeft;
            ExprRight=Node.ExprRight;



            if isa(Node.Operator,'optim.internal.problemdef.operator.StaticAssign')||...
                isa(Node.Operator,'optim.internal.problemdef.operator.StaticSubsasgn')

                pop(visitor,{ExprRight});

                push(visitor,Node);
                return;
            end


            SecondChild=pop(visitor,{ExprLeft,ExprRight});
            if~isequal(ExprLeft,ExprRight)
                FirstChild=pop(visitor,{ExprLeft,ExprRight});



                if~isequal(FirstChild,Node.ExprLeft)


                    childrenOrder=[2,1];
                else


                    childrenOrder=[1,2];
                end
            else


                FirstChild=SecondChild;

                childrenOrder=1;
            end



            secondPos=visitor.CurPos;
            [issub,subNode]=removeSubsrefPassThrough(visitor,SecondChild,secondPos);
            if issub


                if isequal(SecondChild,ExprRight)
                    Node.ExprRight=subNode;
                else
                    Node.ExprLeft=subNode;
                end
                SecondChild=subNode;
            end


            if~isequal(childrenOrder,1)

                firstPos=visitor.CurPos-SecondChild.StackLength;
                [issub,subNode]=removeSubsrefPassThrough(visitor,FirstChild,firstPos);
                if issub


                    if isequal(FirstChild,Node.ExprRight)
                        Node.ExprRight=subNode;
                    else
                        Node.ExprLeft=subNode;
                    end
                    FirstChild=subNode;
                end
            end


            [Node.ChildrenPosition,Node.StackLength]=computeChildrenPosAndStackLength(...
            visitor,FirstChild,SecondChild,childrenOrder);


            push(visitor,Node);
        end

        function visitUnaryExpressionImpl(visitor,Node)

            Child=pop(visitor,{Node.ExprLeft});



            childPos=visitor.CurPos;
            [issub,subNode]=removeSubsrefPassThrough(visitor,Child,childPos);
            if issub

                Node.ExprLeft=subNode;
                Child=subNode;
            end


            childStackLength=Child.StackLength;
            Node.ChildrenPosition=childStackLength;
            Node.StackLength=childStackLength+1;


            push(visitor,Node);
        end

        function visitSubsasgnExpressionImpl(visitor,Node)
            nTrees=Node.NumTrees;

            if nTrees==2




                updateStackForOldSubsasgnOp(visitor,Node);
            else


                rootList=Node.RootList;
                childrenPos=zeros(1,nTrees);
                sumPrevChildStackLength=0;
                for i=1:nTrees
                    Child=pop(visitor,rootList);
                    sumPrevChildStackLength=sumPrevChildStackLength+Child.StackLength;
                    childrenPos(i)=sumPrevChildStackLength;
                end


                Node.ChildrenPosition=childrenPos;
                Node.StackLength=sumPrevChildStackLength+1;
            end


            push(visitor,Node);
        end

    end


    methods

        function[childrenPos,stackLength]=...
            computeChildrenPosAndStackLength(~,LeftChild,RightChild,childrenOrder)


            leftStackLength=LeftChild.StackLength;

            if isscalar(childrenOrder)


                childrenPos=[leftStackLength,leftStackLength];
                stackLength=leftStackLength+1;
            else


                rightStackLength=RightChild.StackLength;



                childrenPos(childrenOrder)=[leftStackLength,leftStackLength+rightStackLength];
                stackLength=rightStackLength+leftStackLength+1;
            end
        end

        function[issub,subNode]=removeSubsrefPassThrough(visitor,Node,NodePos)






            issub=false;
            subNode=Node;
            if isa(Node,'optim.internal.problemdef.SubsasgnExpressionImpl')...
                &&numel(Node.NumTrees)==1
                subNode=Node.RootList{1};
                forestIndexList=Node.ForestIndexList{1};
                treeIndexList=Node.TreeIndexList{1};
                childIndex=1:numel(Node);
                if isequal(size(subNode),size(Node))&&...
                    isequal(forestIndexList(:)',childIndex)&&...
                    isequal(treeIndexList(:)',childIndex)


                    issub=true;
                    visitor.NewStack(NodePos)=[];
                    visitor.CurPos=visitor.CurPos-1;
                end
            end
        end

        function updateStackForOldSubsasgnOp(visitor,Node)
















            rootList=Node.RootList;
            RightChild=pop(visitor,rootList);
            LeftChild=pop(visitor,rootList);
            if~isequal(RightChild,rootList{2})



                rootList=flip(Node.RootList);
                Node.RootList=rootList;
                Node.ForestIndexList=flip(Node.ForestIndexList);
                Node.TreeIndexList=flip(Node.TreeIndexList);
            end
            forestIndexList=Node.ForestIndexList;



            if isempty(forestIndexList{2})

                curPos=visitor.CurPos;
                rightStackLength=RightChild.StackLength;
                rightStackBegins=curPos-rightStackLength+1;
                visitor.NewStack(rightStackBegins:curPos)=[];
                curPos=rightStackBegins-1;
                Node.RootList(2)=[];
                Node.ForestIndexList(2)=[];
                Node.TreeIndexList(2)=[];
                Node.NumTrees=1;

                leftStackLength=LeftChild.StackLength;
                Node.ChildrenPosition=leftStackLength;
                Node.StackLength=leftStackLength+1;
                visitor.CurPos=curPos;
            elseif isempty(forestIndexList{1})


                curPos=visitor.CurPos;
                rightStackLength=RightChild.StackLength;
                rightStackBegins=curPos-rightStackLength+1;
                leftStackLength=LeftChild.StackLength;
                leftStackBegins=curPos-rightStackLength-leftStackLength+1;
                visitor.NewStack(leftStackBegins:rightStackBegins-1)=[];
                curPos=curPos-leftStackLength;
                Node.RootList(1)=[];
                Node.ForestIndexList(1)=[];
                Node.TreeIndexList(1)=[];
                Node.NumTrees=1;

                Node.ChildrenPosition=rightStackLength;
                Node.StackLength=rightStackLength+1;
                visitor.CurPos=curPos;
            else


                childrenOrder=[1,2];
                [Node.ChildrenPosition,Node.StackLength]=...
                computeChildrenPosAndStackLength(visitor,LeftChild,RightChild,childrenOrder);
            end
        end
    end

end
