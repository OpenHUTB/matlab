classdef CompileForwardAD<optim.internal.problemdef.visitor.CompileNonlinearFunction




    properties(Hidden=true,Transient)



        JacStr=cell.empty;

        JacNumParens=[];

        JacIsArgOrVar=logical.empty;

        JacIsAllZero=logical.empty;
    end

    properties(Hidden,Transient)


        ExprAndJacBody="";
    end

    properties(Hidden,Transient)


        ForestJacName=[];

        ForestJacIsAllZero=true;




ExponentName
    end

    properties(Hidden=true,Transient)


        NodeJacName=cell.empty;

        NodeJacNumParens=[];

        NodeJacIsArgOrVar=logical.empty;

        NodeJacIsAllZero=logical.empty;
    end

    methods

        function obj=CompileForwardAD(vars,inputs)
            obj=obj@optim.internal.problemdef.visitor.CompileNonlinearFunction(inputs);
            obj.Variables=vars;
        end

        function[nlfunStruct,jacStruct]=getOutputs(visitor)
            head=visitor.Head;
            nlfunStruct=getOutputs@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor);
            nlfunStruct.fcnBody=visitor.ExprBody;

            jacStruct.funh=visitor.JacStr{head};
            jacStruct.NumParens=visitor.JacNumParens(head);
            jacStruct.singleLine=true;
            jacStruct.fcnBody=visitor.ExprAndJacBody;
            jacStruct.pkgDepends=[];
            jacStruct.extraParams=visitor.ExtraParams;
        end
    end

    methods



        function pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero)



            head=visitor.Head;
            visitor.JacStr{head}=jacStr;
            visitor.JacNumParens(head)=jacNumParens;
            visitor.JacIsArgOrVar(head)=jacIsArgOrVar;
            visitor.JacIsAllZero(head)=jacIsAllZero;
        end

        function pushTangentString(visitor,jacStr,jacNumParens,Node,PackageLocation)
            leftJacIsAllZero=isChildJacAllZero(visitor,1);
            if leftJacIsAllZero

                pushJacAllZeros(visitor,numel(Node));
            else


                addParens=jacNumParens+1;

                [leftJacVarName,leftJacParens]=getChildJacArgumentName(...
                visitor,1,addParens);
                tanStr="("+leftJacVarName+" * "+jacStr+")";
                tanNumParens=jacNumParens+leftJacParens+1;
                tanIsArgOrVar=false;
                tanIsAllZero=false;

                pushJac(visitor,tanStr,tanNumParens,tanIsArgOrVar,tanIsAllZero);

                visitor.PkgDepends(end+1)=PackageLocation;
            end
        end

        function[jacName,jacParens,jacIsArgOrVar,jacIsAllZero]=popJac(visitor)
            head=visitor.Head;
            jacName=visitor.JacStr{head};
            jacParens=visitor.JacNumParens(head);
            jacIsArgOrVar=visitor.JacIsArgOrVar(head);
            jacIsAllZero=visitor.JacIsAllZero(head);
        end

        function[jacName,jacParens,jacIsArgOrVar,jacIsAllZero]=popChildJac(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            jacName=visitor.JacStr{childHead};
            jacParens=visitor.JacNumParens(childHead);
            jacIsArgOrVar=visitor.JacIsArgOrVar(childHead);
            jacIsAllZero=visitor.JacIsAllZero(childHead);
        end

        function[jacVarName,jacParens,jacIsArgOrVar,jacIsAllZero]=getChildJacArgumentName(visitor,childIdx,addParens)


            [jacVarName,jacParens,jacIsArgOrVar,jacIsAllZero]=popChildJac(visitor,childIdx);


            singleLine=true;
            [jacVarName,jacParens,jacBody,jacIsArgOrVar]=addParensToArg(visitor,...
            jacVarName,jacParens,jacIsArgOrVar,singleLine,addParens);
            visitor.ExprAndJacBody=visitor.ExprAndJacBody+jacBody;
        end

        function jacIsAllZero=isChildJacAllZero(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            jacIsAllZero=visitor.JacIsAllZero(childHead);
        end

        function[jacVarName,jacParens,jacIsArgOrVar,jacIsAllZero]=getJacArgumentName(visitor,addParens)


            [jacVarName,jacParens,jacIsArgOrVar,jacIsAllZero]=popJac(visitor);


            singleLine=true;
            [jacVarName,jacParens,jacBody,jacIsArgOrVar]=addParensToArg(visitor,...
            jacVarName,jacParens,jacIsArgOrVar,singleLine,addParens);
            visitor.ExprAndJacBody=visitor.ExprAndJacBody+jacBody;
        end

        function pushAllZeroNode(visitor,sz)

            pushAllZeroNode@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,sz);
            pushJacAllZeros(visitor,prod(sz));
        end

        function pushJacAllZeros(visitor,nElem)
            jacSize=[visitor.TotalVar,nElem];
            [jacStr,jacNumParens]=...
            optim.internal.problemdef.ZeroExpressionImpl.getNonlinearSparseStr(jacSize);
            jacIsArgOrVar=false;
            jacIsAllZero=true;
            pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);
        end

        function pushNodeJac(visitor,Node,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero)
            nodeIdx=Node.VisitorIndex;
            visitor.NodeJacName{nodeIdx}=jacStr;
            visitor.NodeJacNumParens(nodeIdx)=jacNumParens;
            visitor.NodeJacIsArgOrVar(nodeIdx)=jacIsArgOrVar;
            visitor.NodeJacIsAllZero(nodeIdx)=jacIsAllZero;
        end

        function pushNodeJacIsAllZero(visitor,Node,jacIsAllZero)
            nodeIdx=Node.VisitorIndex;
            visitor.NodeJacIsAllZero(nodeIdx)=jacIsAllZero;
        end

        function[jacStr,jacParens,jacIsArgOrVar,jacIsAllZero]=popNodeJac(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            jacStr=visitor.NodeJacName{nodeIdx};
            jacParens=visitor.NodeJacNumParens(nodeIdx);
            jacIsArgOrVar=visitor.NodeJacIsArgOrVar(nodeIdx);
            jacIsAllZero=visitor.NodeJacIsAllZero(nodeIdx);
        end

        function addToExprBody(visitor,newLines)
            visitor.ExprBody=visitor.ExprBody+newLines;
            visitor.ExprAndJacBody=visitor.ExprAndJacBody+newLines;
        end

        function prependToExprBody(visitor,newLines)
            visitor.ExprBody=newLines+visitor.ExprBody;
            visitor.ExprAndJacBody=newLines+visitor.ExprAndJacBody;
        end

    end

    methods

        function visitEndIndexExpressionImpl(visitor,Node)

            visitEndIndexExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
            visitor,Node);


            pushJacAllZeros(visitor,numel(Node));
        end

        function visitNumericExpressionImpl(visitor,Node)

            visitNumericExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
            visitor,Node);


            pushJacAllZeros(visitor,numel(Node));
        end

        function visitColonExpressionImpl(visitor,Node)

            visitColonExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
            visitor,Node);


            pushJacAllZeros(visitor,numel(Node));
        end

        function visitVariableExpressionImpl(visitor,Node)

            visitVariableExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
            visitor,Node);


            jacStr=string(Node.JacStr);
            jacNumParens=Node.JacNumParens;
            jacIsArgOrVar=true;
            jacIsAllZero=false;
            pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);
        end

        visitIndexingNode(visitor,visitTreeFun,...
        forestSize,nTrees,treeList,forestIndexList,treeIndexList);

        storeWithSubsasgn(visitor,forestSize);

        storeNoSubsasgn(visitor,forestSize);

        compileNoSubasgnNoSubsref(visitor,treeHead);

        compileNoSubsasgnWithSubsref(visitor,treeHead,treeIdxStr);

        compileWithSubasgnNoSubsref(visitor,treeHead,forestIdxStr);

        compileWithSubsasgnWithSubsref(visitor,treeHead,forestIdxStr,treeIdxStr);

        function visitNonlinearExpressionImpl(visitor,Node)



            visitNonlinearExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
            visitor,Node);

            pushJacAllZeros(visitor,numel(Node));
        end

        function initializeLHS(visitor,LHS)

            if~isempty(LHS.VisitorIndex)

                return;
            end

            initializeLHS@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,LHS);


            lhsJacName="arg"+visitor.getNumArgs();
            jacNumParens=0;
            jacIsArgOrVar=true;
            jacIsAllZero=false;


            pushNodeJac(visitor,LHS,lhsJacName,jacNumParens,jacIsArgOrVar,jacIsAllZero);
        end

        function visitLHSExpressionImpl(visitor,LHS)

            visitLHSExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
            visitor,LHS);


            [lhsJacName,jacNumParens,jacIsArgOrVar,jacIsAllZero]=popNodeJac(visitor,LHS);
            pushJac(visitor,lhsJacName,jacNumParens,jacIsArgOrVar,jacIsAllZero);
        end

        visitForLoopWrapper(visitor,LoopWrapper);



        compileJacOperator(visitor,op,Node);

        compileJacScalarExpansion(visitor,childIdx,thisNode,otherNode);

        compileRdivideJacobian(visitor,LeftExpr,leftJacVarName,leftJacParens,jacLeftStr,addLeftParens,...
        RightExpr,rightJacVarName,rightJacParens,jacRightStr,addRightParens);

        visitNonlinearUnarySingleton(visitor,op,Node);

        visitOperatorCumfcn(visitor,op,Node);

        visitOperatorDiag(visitor,op,Node);

        visitOperatorDiff(visitor,op,Node);

        visitOperatorLdivide(visitor,op,Node);

        visitOperatorMinus(visitor,op,Node);

        visitOperatorMpower(visitor,op,Node);

        visitOperatorMtimes(visitor,op,Node);

        visitOperatorPlus(visitor,op,Node);

        visitOperatorPower(visitor,op,Node);

        visitOperatorProd(visitor,op,Node);

        visitOperatorRdivide(visitor,op,Node);

        visitOperatorSum(visitor,op,Node);

        visitOperatorTimes(visitor,op,Node);

        visitOperatorTranspose(visitor,op,Node);

        visitUnaryOperator(visitor,op,Node);

        [indexingStr,indexingParens]=compileStaticIndexingString(visitor,Op,addParens);

        [indexingStr,indexingParens]=visitStaticIndexingString(visitor,Op,addParens);

        [funStr,numParens,isArgOrVar]=compileNumericExpression(visitor,expression,addParens);

        [funStr,numParens,isArgOrVar]=visitNumericExpression(visitor,expression,addParens);

        visitOperatorStaticAssign(visitor,Op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

        visitOperatorStaticSubsref(visitor,Op,Node);

    end

    methods(Static)

        function[jacStr,jacParens]=createProdJacobianString(LeftExpr,leftVarName,dimi)


            dimi=optim.internal.problemdef.operator.Prod.getReduceDim(dimi,size(LeftExpr));
            if strcmp(dimi,'all')



                FileNameGradientAll="ProdGradientAll";
                jacStr=FileNameGradientAll+"("+leftVarName+")";
                jacParens=1;
            else
                contiguous=false;
                [dimStr,jacParens]=optim.internal.problemdef.compile.getVectorString(dimi,contiguous);

                FileNameJacobian="ProdJacobian";
                jacStr=FileNameJacobian+"("+leftVarName+", "+dimStr+")";
                jacParens=jacParens+1;
            end
        end

        function[jacStr,jacParens]=createDiffJacobianString(leftVarName,order,dimi)






            extraParens=0;
            if isempty(dimi)
                dimi="[]";
                extraParens=1;
            end


            FileNameGrad="DiffGrad";
            jacStr=FileNameGrad+"(size("+leftVarName+"), "+...
            order+", "+dimi+")";


            jacParens=2+extraParens;
        end

        function[jacLeftStr,jacRightStr,addLeftParens,addRightParens]=...
            createDivideJacobianStrings(leftVarName,rightVarName)
            FileNameLeftJacobian="DivideLeftJacobian";
            FileNameRightJacobian="DivideRightJacobian";
            jacLeftStr=FileNameLeftJacobian+"("+rightVarName+")";
            jacRightStr=FileNameRightJacobian+"("+leftVarName+", "+rightVarName+")";
            addLeftParens=1;
            addRightParens=1;
        end




        function[SMat,fcnBody]=createSumSMatString(fcnBody,LDims,dimi)

            outDims=LDims;
            outDims(dimi)=1;

            tempProd=prod(outDims(1:dimi));
            if tempProd==1








                Crhs="ones("+LDims(dimi)+", 1);";
            else


                Crhs="repmat(speye("+tempProd+"), "+LDims(dimi)+", 1);";
            end
            C="arg"+optim.internal.problemdef.visitor.CompileNonlinearFunction.getNumArgs();
            fcnBody=fcnBody+C+" = "+Crhs+newline;
            n=prod(outDims(dimi+1:end));
            if n>1
                SMat="arg"+optim.internal.problemdef.visitor.CompileNonlinearFunction.getNumArgs();
                kronStr="kron(speye("+n+"), "+C+");";
                fcnBody=fcnBody+SMat+" = "+kronStr+newline;
            else
                SMat=C;
            end
        end
    end

end
