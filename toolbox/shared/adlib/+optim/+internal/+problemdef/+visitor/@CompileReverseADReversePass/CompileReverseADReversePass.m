classdef CompileReverseADReversePass<optim.internal.problemdef.visitor.CompileNonlinearFunction




    properties(Hidden,Transient)


        Tape={};


        WriteToArgTape=logical.empty;

        IsNodeLHS=logical.empty;
    end

    properties(Hidden,Transient)

        ForLoopTape={};
        ForLoopWriteToArgTape=logical.empty;
        LHSJacName={};
        ArgTapeName=[];
        ArgTapeHeadName=[];
    end

    methods

        function obj=CompileReverseADReversePass(visForwardPass,vars,nelem,inputs)

            obj=obj@optim.internal.problemdef.visitor.CompileNonlinearFunction(inputs);

            obj.Tape=visForwardPass.Tape;
            obj.ExtraParams=visForwardPass.ExtraParams;
            obj.NumExtraParams=visForwardPass.NumExtraParams;
            obj.WriteToArgTape=visForwardPass.WriteToArgTape;
            obj.ArgTapeName=visForwardPass.ArgTapeName;
            obj.ArgTapeHeadName=visForwardPass.ArgTapeHeadName;
            obj.Variables=vars;
            obj.NumExpr=nelem;
            obj.SingleLine=true;

            obj.VisitorIndexMap=visForwardPass.VisitorIndexMap;
            numNodes=visForwardPass.NumNodes;
            obj.NumNodes=numNodes;
            obj.Nodes=visForwardPass.Nodes;
            obj.NodeParens=visForwardPass.NodeParens;
            obj.NodeStr=cellfun(@(str)str+"jac",visForwardPass.NodeStr,'UniformOutput',false);
            obj.IsVisited=false(1,numNodes);
            obj.IsNodeLHS=true(1,numNodes);
            visForwardPass.Nodes=[];
            visForwardPass.NumNodes=0;



            initializeVariables(obj);
        end

        initializeVariables(visitor);

        function jacStruct=getOutputs(visitor)
            combineVariableGradients(visitor);

            jacStruct=getOutputs@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor);
        end

    end

    methods




        function[funStr,writeToArgTape]=getForwardMemory(visitor)
            funStr=visitor.Tape{end};
            writeToArgTape=visitor.WriteToArgTape(end);
            visitor.Tape(end)=[];
            visitor.WriteToArgTape(end)=[];
        end




        function[isAllZero,varName]=getChildMemory(visitor)
            varName=getForwardMemory(visitor);
            isAllZero=strlength(varName)==0;
        end

        function[jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero,jacIsSingleLine]=pop(visitor)
            head=visitor.Head;
            jacStr=visitor.FunStr{head};
            jacNumParens=visitor.NumParens(head);
            jacIsArgOrVar=visitor.IsArgOrVar(head);
            jacIsAllZero=visitor.IsAllZero(head);
            jacIsSingleLine=true;
        end

        function[varName,numParens,isArgOrVar,isAllZero,singleLine]=...
            popChild(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            varName=visitor.FunStr{childHead};
            numParens=visitor.NumParens(childHead);
            isArgOrVar=visitor.IsArgOrVar(childHead);
            isAllZero=visitor.IsAllZero(childHead);
            singleLine=true;
        end

        function push(visitor,jacStr,numParens,isArgOrVar,isAllZero,~)
            head=visitor.Head+1;
            visitor.FunStr{head}=jacStr;
            visitor.NumParens(head)=numParens;
            visitor.IsArgOrVar(head)=isArgOrVar;
            visitor.IsAllZero(head)=isAllZero;
            visitor.Head=head;
        end

        function pushChild(visitor,childIdx,jacStr,numParens,isArgOrVar,isAllZero)
            childrenHead=visitor.ChildrenHead;
            childHead=childrenHead(childIdx);
            head=visitor.Head;
            if(childIdx==2)&&(childrenHead(1)==childrenHead(2))

                [curJacStr,curNumParens,~,curIsAllZero]=popChild(visitor,childIdx);
                if strlength(curJacStr)>0
                    if~isAllZero


                        addParens=curNumParens;
                        singleLine=true;
                        [jacStr,numParens,argBody]=addParensToArg(visitor,...
                        jacStr,numParens,isArgOrVar,singleLine,addParens);
                        visitor.ExprBody=visitor.ExprBody+argBody;
                        jacStr=curJacStr+" + "+jacStr;
                        isArgOrVar=false;
                        isAllZero=curIsAllZero&&isAllZero;
                        numParens=addParens+numParens;
                    else

                        return;
                    end
                end
                head=head-1;
            end
            visitor.FunStr{childHead}=jacStr;
            visitor.NumParens(childHead)=numParens;
            visitor.IsArgOrVar(childHead)=isArgOrVar;
            visitor.IsAllZero(childHead)=isAllZero;
            visitor.Head=head+1;
        end

        function pushAllZeroChild(visitor,childIdx,childNode)
            childrenHead=visitor.ChildrenHead;
            if(childIdx==2)&&(childrenHead(1)==childrenHead(2))

            else
                jacSize=[numel(childNode),visitor.NumExpr];
                [jacStr,numParens]=...
                optim.internal.problemdef.ZeroExpressionImpl.getNonlinearSparseStr(jacSize);
                childHead=childrenHead(childIdx);
                visitor.FunStr{childHead}=jacStr;
                visitor.NumParens(childHead)=numParens;
                visitor.IsArgOrVar(childHead)=false;
                visitor.IsAllZero(childHead)=true;
                visitor.Head=visitor.Head+1;
            end
        end

        function pushJacAllZeros(visitor,nElem)
            jacSize=[nElem,visitor.NumExpr];
            [jacStr,jacNumParens]=...
            optim.internal.problemdef.ZeroExpressionImpl.getNonlinearSparseStr(jacSize);
            jacIsArgOrVar=false;
            iacIsAllZero=true;
            push(visitor,jacStr,jacNumParens,jacIsArgOrVar,iacIsAllZero);
        end

        function pushAdjointString(visitor,jacStr,jacParens,Node,PackageLocation)
            jacIsAllZero=isParentJacAllZero(visitor);
            if jacIsAllZero

                visitor.Head=visitor.Head-1;
                pushJacAllZeros(visitor,numel(Node.ExprLeft));
            else

                addParens=jacParens+1;
                [dirStr,dirParens]=getParentJacArgumentName(visitor,addParens);
                adjStr="("+jacStr+" * "+dirStr+")";
                adjParens=jacParens+dirParens+1;
                adjIsArgOrVar=false;
                adjIsAllZero=false;

                push(visitor,adjStr,adjParens,adjIsArgOrVar,adjIsAllZero);

                visitor.PkgDepends(end+1)=PackageLocation;
            end
        end

        function[jacVarName,jacParens,jacIsArgOrVar,jacIsAllZero]=getParentJacArgumentName(visitor,addParens)


            [jacVarName,jacParens,jacIsArgOrVar,jacIsAllZero]=getArgumentName(visitor,addParens);
            visitor.Head=visitor.Head-1;
            visitor.ExprBody=visitor.ExprBody;
        end

        function jacIsAllZero=isParentJacAllZero(visitor)
            head=visitor.Head;
            jacIsAllZero=visitor.IsAllZero(head);
        end

    end

    methods

        function visitTree(visitor,tree)





            stack=tree.Stack;
            for i=numel(stack):-1:1

                Node=stack{i};




                acceptVisitor(Node,visitor);
            end



        end


        function visitForest(visitor,forest)

            [initJacStr,numParens]=iInitJacStr(forest);
            isArgOrVar=false;
            isAllZero=false;
            push(visitor,initJacStr,numParens,isArgOrVar,isAllZero);

            if forest.SingleTreeSpansAllIndices

                ExprTree=forest.TreeList{1};


                visitTree(visitor,ExprTree);
            else



                nTrees=forest.NumTrees;
                treeList=forest.TreeList;
                forestIndexList=forest.ForestIndexList;
                treeIndexList=forest.TreeIndexList;
                forestSize=forest.Size;


                visitor.visitIndexingNodeReverseAD(@visitTreeFun,...
                forestSize,nTrees,treeList,forestIndexList,treeIndexList);
            end

            function[initJacStr,numParens]=iInitJacStr(forest)

                nObj=prod(forest.Size);
                numParens=0;
                if nObj==1
                    initJacStr="1";
                else
                    initJacStr="speye("+nObj+")";
                end

            end
        end

        function visitTreeFun(visitor,tree,~,treeJacStr,jacNumParens,isArgOrVar,isAllZero)

            push(visitor,treeJacStr,jacNumParens,isArgOrVar,isAllZero);

            visitTree(visitor,tree);
        end

        function visitLeafImpl(visitor,~)

            visitor.Head=visitor.Head-1;
        end

        function visitZeroExpressionImpl(visitor,Node)
            visitLeafImpl(visitor,Node);
        end

        function visitNumericExpressionImpl(visitor,Node)
            visitLeafImpl(visitor,Node);
        end

        function visitColonExpressionImpl(visitor,Node)
            visitLeafImpl(visitor,Node);
        end

        function visitVariableExpressionImpl(visitor,Node)
            jacIsAllZero=isParentJacAllZero(visitor);
            if~jacIsAllZero
                jacStr=pop(visitor);

                jacVarName=Node.JacStr;

                visitor.ExprBody=visitor.ExprBody+...
                jacVarName+" = "+jacVarName+" + "+jacStr+";"+newline;
            end
            visitor.Head=visitor.Head-1;
        end

        function visitBinaryExpressionImpl(visitor,Node)


            head=visitor.Head;
            pos=Node.ChildrenPosition;
            if pos(1)==pos(2)
                visitor.ChildrenHead=[head,head];
            elseif pos(1)<pos(2)
                visitor.ChildrenHead=[head,head+1];
            else
                visitor.ChildrenHead=[head+1,head];
            end

            acceptVisitor(Node.Operator,visitor,Node);
        end

        function visitUnaryExpressionImpl(visitor,Node)
            visitor.ChildrenHead=visitor.Head;
            acceptVisitor(Node.Operator,visitor,Node);
        end

        function visitSubsasgnExpressionImpl(visitor,Node)


            nTrees=Node.NumTrees;
            rootList=Node.RootList;
            forestIndexList=Node.ForestIndexList;
            treeIndexList=Node.TreeIndexList;
            forestSize=Node.Size;


            head=visitor.Head;
            newHead=head+nTrees-1;
            visitor.ChildrenHead=head:newHead;


            visitor.visitIndexingNodeReverseAD(@visitRootReverseAD,...
            forestSize,nTrees,rootList,forestIndexList,treeIndexList);

            function visitRootReverseAD(visitor,~,treeIdx,treeJacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero)
                pushChild(visitor,treeIdx,treeJacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);
            end
        end

        visitIndexingNodeReverseAD(visitor,visitTreeReverseAD,getTreeRoot,...
        forestSize,nTrees,treeList,forestIndexList,treeIndexList);

        function visitNonlinearExpressionImpl(visitor,Node)


            visitLeafImpl(visitor,Node);
        end

        function initializeLHS(visitor,LHS)
            visitor.IsNodeLHS(LHS.VisitorIndex)=true;

            if visitor.IsVisited(LHS.VisitorIndex)

                return;
            end


            lhsJacName=popNode(visitor,LHS);


            jacStr="sparse("+numel(LHS)+", "+visitor.NumExpr+")";
            initCode=lhsJacName+" = "+jacStr+";"+newline;
            visitor.ExprBody=initCode+visitor.ExprBody;


            visitor.IsVisited(LHS.VisitorIndex)=true;
        end

        function visitLHSExpressionImpl(visitor,LHS)
            if~visitor.IsNodeLHS(LHS.VisitorIndex)
                visitLeafImpl(visitor,LHS);
                return;
            end
            jacIsAllZero=isParentJacAllZero(visitor);
            if~jacIsAllZero
                jacStr=pop(visitor);
                lhsJacName=popNode(visitor,LHS);

                visitor.ExprBody=visitor.ExprBody+...
                lhsJacName+" = "+lhsJacName+" + "+jacStr+";"+newline;
            end
            visitor.Head=visitor.Head-1;
        end

        visitStatementWrapper(visitor,StmtWrapper);

        visitForLoopWrapper(visitor,LoopWrapper);



        compileJacScalarExpansion(visitor,childIdx,thisNode,otherNode,...
        jacStr,jacParens,jacIsArgOrVar,jacIsAllZero);

        [leftJac,leftJacParens,rightJac,rightJacParens]=...
        compileOperatorRdivide(visitor,leftVarName,rightVarName);

        visitNonlinearUnarySingleton(visitor,op,LeftExpr);

        visitOperatorCumfcn(visitor,op,LeftExpr);

        visitOperatorDiag(visitor,op,LeftExpr);

        visitOperatorDiff(visitor,op,LeftExpr);

        visitOperatorLdivide(visitor,op,Node);

        visitOperatorMinus(visitor,op,Node);

        visitOperatorMpower(visitor,op,LeftExpr);

        visitOperatorMtimes(visitor,op,LeftExpr,RightExpr);

        visitOperatorPlus(visitor,op,Node);

        visitOperatorPower(visitor,op,LeftExpr);

        visitOperatorProd(visitor,op,LeftExpr);

        visitOperatorRdivide(visitor,op,Node);

        visitOperatorSum(visitor,op,LeftExpr);

        visitOperatorTimes(visitor,op,Node);

        visitOperatorTranspose(visitor,op,LeftExpr);

        visitOperatorUminus(visitor,op,Node);

        visitOperatorUplus(visitor,op,Node);

        visitOperatorStaticAssign(visitor,Op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

        visitOperatorStaticSubsref(visitor,Op,Node);

    end

end
