classdef CompileNonlinearFunction<optim.internal.problemdef.visitor.Visitor




    properties(Hidden=true,Transient)



        FunStr=cell.empty;

        NumParens=[];

        SingleLine=logical.empty;

        IsArgOrVar=logical.empty;

        IsAllZero=logical.empty;
    end

    properties(Hidden,Transient)


        ExprBody="";
TreeStr
        ExtraParams={};


        NumExtraParams=0;
        PkgDepends=string.empty;
        Subfun=struct;
    end

    properties(Hidden=true,Transient)

        TotalVar=0;
        NumExpr=0;
        ForDisplay=false;
        Reset=true;
        InMemory=false;
        InMemFolder=string.empty;
        ExtraParamsName="extraParams";
        Variables=struct;
    end

    properties(Hidden,Transient)


        ForestName=[];

        ForestIsAllZero=true;


        PreLoopBody="";
    end

    properties(Hidden,Transient)

        NodeStr={};

        NodeParens=[];
    end

    properties(Constant)


        MaxParensPerLine=15;
    end

    methods

        function obj=CompileNonlinearFunction(inputs)

            for i=1:2:numel(inputs)

                ptyName=inputs{i};

                obj.(ptyName)=inputs{i+1};
            end
            obj.NumExtraParams=numel(obj.ExtraParams);
        end

        function nlfunStruct=getOutputs(visitor)
            head=visitor.Head;
            nlfunStruct.funh=visitor.FunStr{head};
            nlfunStruct.NumParens=visitor.NumParens(head);
            nlfunStruct.singleLine=visitor.SingleLine(head);
            prependToExprBody(visitor,visitor.PreLoopBody);
            nlfunStruct.fcnBody=visitor.ExprBody;
            nlfunStruct.treeStr=visitor.TreeStr;
            nlfunStruct.subfun=visitor.Subfun;
            nlfunStruct.extraParams=visitor.ExtraParams;
            nlfunStruct.pkgDepends=visitor.PkgDepends;

            if visitor.Reset

                visitor.getNumArgs('reset');
            end
        end
    end

    methods


        function push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine)
            head=visitor.Head+1;


            visitor.FunStr{head}=funStr;
            visitor.NumParens(head)=numParens;
            visitor.IsArgOrVar(head)=isArgOrVar;
            visitor.IsAllZero(head)=isAllZero;
            visitor.SingleLine(head)=singleLine;
            visitor.Head=head;
        end

        function paramIdx=pushExtraParam(visitor,ex)
            paramIdx=visitor.NumExtraParams+1;
            visitor.ExtraParams{paramIdx}=ex;
            visitor.NumExtraParams=paramIdx;
        end

        function[varName,numParens,isArgOrVar,isAllZero,singleLine]=...
            pop(visitor)
            head=visitor.Head;
            varName=visitor.FunStr{head};
            numParens=visitor.NumParens(head);
            isArgOrVar=visitor.IsArgOrVar(head);
            isAllZero=visitor.IsAllZero(head);
            singleLine=visitor.SingleLine(head);
        end

        function[varName,numParens,isArgOrVar,isAllZero,singleLine]=...
            popChild(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            varName=visitor.FunStr{childHead};
            numParens=visitor.NumParens(childHead);
            isArgOrVar=visitor.IsArgOrVar(childHead);
            isAllZero=visitor.IsAllZero(childHead);
            singleLine=visitor.SingleLine(childHead);
        end

        function[varName,numParens,isArgOrVar,isAllZero,singleLine]=...
            popParent(visitor)
            parentHead=visitor.ParentHead;
            varName=visitor.FunStr{parentHead};
            numParens=visitor.NumParens(parentHead);
            isArgOrVar=visitor.IsArgOrVar(parentHead);
            isAllZero=visitor.IsAllZero(parentHead);
            singleLine=visitor.SingleLine(parentHead);
        end

        function isAllZero=isChildAllZero(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            isAllZero=visitor.IsAllZero(childHead);
        end

        function pushNode(visitor,Node,jacStr,numParens)
            nodeIdx=Node.VisitorIndex;
            visitor.NodeStr{nodeIdx}=jacStr;
            visitor.NodeParens(nodeIdx)=numParens;
        end

        function[jacStr,jacNumParens]=popNode(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            jacStr=visitor.NodeStr{nodeIdx};
            jacNumParens=visitor.NodeParens(nodeIdx);
        end

        function addToExprBody(visitor,newLines)
            visitor.ExprBody=visitor.ExprBody+newLines;
        end

        function prependToExprBody(visitor,newLines)
            visitor.ExprBody=newLines+visitor.ExprBody;
        end


        function addToPreLoopBody(visitor,exprBody)
            visitor.PreLoopBody=visitor.PreLoopBody+exprBody;
        end

        function[varName,numParens,isArgOrVar,isAllZero]=getArgumentName(visitor,addParens)


            [varName,numParens,isArgOrVar,isAllZero,singleLine]=pop(visitor);


            [varName,numParens,varBody,isArgOrVar]=addParensToArg(visitor,...
            varName,numParens,isArgOrVar,singleLine,addParens);
            addToExprBody(visitor,varBody);
        end

        function[varName,numParens,isArgOrVar,isAllZero]=getChildArgumentName(visitor,childIdx,addParens)


            [varName,numParens,isArgOrVar,isAllZero,singleLine]=popChild(visitor,childIdx);


            [varName,numParens,varBody,isArgOrVar]=addParensToArg(visitor,...
            varName,numParens,isArgOrVar,singleLine,addParens);
            addToExprBody(visitor,varBody);
        end

        function pushAllZeroNode(visitor,sz)


            pushAllZeros(visitor,sz);
        end

        function argName=declareChildArgumentName(visitor,childIdx)


            addParens=Inf;
            [argName,numParens,isArgOrVar,isAllZero]=getChildArgumentName(visitor,childIdx,addParens);

            childHead=visitor.ChildrenHead(childIdx);
            visitor.FunStr{childHead}=argName;
            visitor.NumParens(childHead)=numParens;
            visitor.IsArgOrVar(childHead)=isArgOrVar;
            visitor.IsAllZero(childHead)=isAllZero;
            visitor.SingleLine(childHead)=true;
        end

        function visitTree(visitor,tree)
            visitTree@optim.internal.problemdef.visitor.Visitor(visitor,tree);

            stack=tree.Stack;
            head=visitor.Head;
            if visitor.ForDisplay


                if numel(stack)==1&&isa(stack{1},'optim.internal.problemdef.NumericExpressionImpl')


                    val=stack{1}.Value;
                    if isnumeric(val)

                        val=full(val(:));
                        treeStr=string(val);

                        treeStr(val==0)="";
                        visitor.TreeStr=treeStr;
                    else


                        visitor.TreeStr={};
                    end
                elseif all(tree.Size==1)&&strlength(visitor.ExprBody)==0...
                    &&visitor.SingleLine(head)&&visitor.NumExtraParams==0




                    visitor.TreeStr=string(visitor.FunStr{head});
                else

                    visitor.TreeStr={};
                end
            end
        end

    end

    methods(Access=private)

        function pushAllZeros(visitor,sz)



            [funStr,numParens]=...
            optim.internal.problemdef.ZeroExpressionImpl.getNonlinearStr(sz);
            isArgOrVar=false;
            isAllZero=true;
            singleLine=true;
            push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
        end

    end

    methods

        function visitZeroExpressionImpl(visitor,Node)

            sz=Node.Size;
            pushAllZeroNode(visitor,sz);
        end

        function visitNumericExpressionImpl(visitor,Node)

            val=Node.Value;
            numericVal=isnumeric(val);
            if numericVal&&isscalar(val)&&(val==floor(val)||visitor.ForDisplay)




                val=full(val);
                if val>=0
                    funStr=string(val);
                    numParens=0;
                else

                    funStr="("+val+")";
                    numParens=1;
                end
            else



                inputIdx=pushExtraParam(visitor,val);
                funStr=visitor.ExtraParamsName+"{"+inputIdx+"}";
                numParens=1;
            end
            isArgOrVar=false;
            isAllZero=numericVal&&~any(val,'all');
            singleLine=true;


            push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
        end

        function visitIndexingVector(visitor,idx)


            idx=full(idx);
            contiguous=[];
            keepOrientation=false;
            expandNonCompact=false;
            [funStr,numParens,compact]=...
            optim.internal.problemdef.compile.getVectorString(idx,contiguous,keepOrientation,expandNonCompact);


            if~compact
                inputIdx=pushExtraParam(visitor,idx);
                funStr=visitor.ExtraParamsName+"{"+inputIdx+"}";
                numParens=1;
            end
            isAllZero=false;
            isArgOrVar=false;
            singleLine=true;


            push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
        end


        function[indexingStr,indexingParens]=compileIndexingString(visitor,idx)


            contiguous=[];
            respectOrientation=false;

            expandNonCompact=numel(idx)<=20;
            [indexingStr,indexingParens,compact]=...
            optim.internal.problemdef.compile.getVectorString(idx,contiguous,respectOrientation,expandNonCompact);

            if~expandNonCompact&&~compact


                paramIdx=pushExtraParam(visitor,idx);
                indexingStr=visitor.ExtraParamsName+"{"+paramIdx+"}";
                indexingParens=1;
            end
        end

        function visitColonExpressionImpl(visitor,Node)


            args=Node.Arguments;
            optimArg=Node.OptimArg;
            Nargs=numel(args);

            argStr=strings(Nargs,1);

            argNumParens=1;
            head=visitor.Head;
            for i=1:Nargs
                arg=args{i};
                if optimArg(i)

                    acceptVisitor(arg,visitor);


                    [argStr(i),thisParens]=getArgumentName(visitor,argNumParens);
                    visitor.Head=head;
                    argNumParens=argNumParens+thisParens;
                else

                    argStr(i)=string(arg);
                end
            end


            funStr="("+strjoin(argStr,':')+")";
            numParens=argNumParens;
            isArgOrVar=false;
            isAllZero=false;
            singleLine=true;


            push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
        end

        function visitVariableExpressionImpl(visitor,Node)

            funStr=string(Node.Name);
            numParens=0;
            isArgOrVar=true;
            isAllZero=false;
            singleLine=true;
            push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
        end

        function visitSubsasgnExpressionImpl(visitor,Node)


            visitor.TreeStr=[];

            visitSubsasgnExpressionImpl@optim.internal.problemdef.visitor.Visitor(visitor,Node);
        end

        visitIndexingNode(visitor,visitTreeFun,forestSize,...
        nTrees,treeList,forestIndexList,treeIndexList);

        storeWithSubsasgn(visitor,forestSize);

        storeNoSubsasgn(visitor,forestSize);

        compileNoSubsasgn(visitor,treei,treeHead,~,treeIndex);

        compileWithSubsasgn(visitor,treei,treeHead,forestIndex,treeIndex);

        compileNoSubasgnNoSubsref(visitor,treeHead);

        compileNoSubsasgnWithSubsref(visitor,treeHead,treeIdxStr);

        compileWithSubasgnNoSubsref(visitor,treeHead,forestIdxStr);

        compileWithSubsasgnWithSubsref(visitor,treei,treeHead,forestIdxStr,treeIdxStr);

        function visitNonlinearExpressionImpl(visitor,Node)
            [funStr,numParens]=visitFunctionWrapper(visitor,Node.FunctionImpl);


            [funStr,singleLine]=buildLHSString(Node,funStr);


            isArgOrVar=false;
            isAllZero=false;
            push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);

            function[funStr,singleLine]=buildLHSString(Node,funStr)

                FunStrLhsEnd="] = ";

                if Node.OutputIndex>1

                    funStrLhs="[~"+strjoin(repmat(",~",1,Node.OutputIndex-2),"")+",%s";
                    singleLine=false;
                else
                    if Node.FunctionImpl.NumArgOut>1
                        funStrLhs="[%s";
                        singleLine=false;
                    else
                        singleLine=true;
                        return;
                    end
                end



                if Node.FunctionImpl.NumArgOut>Node.OutputIndex
                    NumExtraOutputs=Node.FunctionImpl.NumArgOut-Node.OutputIndex;
                    funStrLhs=funStrLhs+strjoin(repmat(",~",1,NumExtraOutputs-1),"")+",~";
                end


                funStrLhs=funStrLhs+FunStrLhsEnd;


                funStr=funStrLhs+funStr+";";
            end
        end

        [funh,numParens]=visitFunctionWrapper(visitor,fcnWrapper);

        funh=compileNonlinearFunctionAtInputs(visitor,fcnWrapper,inputStr);

        compileRepeatedSubfunction(visitor,fcnWrapper,funName);

        function initializeLHS(visitor,LHS)

            if~isempty(LHS.VisitorIndex)

                return;
            end

            initializeLHS@optim.internal.problemdef.visitor.Visitor(visitor,LHS);


            lhsVarName="arg"+visitor.getNumArgs();
            lhsNumParens=0;


            pushNode(visitor,LHS,lhsVarName,lhsNumParens);
        end

        function visitLHSExpressionImpl(visitor,LHS)

            [lhsVarName,lhsNumParens]=popNode(visitor,LHS);





            lhsIsArgOrVar=true;
            lhsIsAllZero=false;
            lhsSingleLine=true;


            push(visitor,lhsVarName,lhsNumParens,lhsIsArgOrVar,lhsIsAllZero,lhsSingleLine);
        end

        function visitEndIndexExpressionImpl(visitor,~)
            funStr=popParent(visitor);
            numParens=0;
            lhsIsArgOrVar=false;
            lhsIsAllZero=false;
            lhsSingleLine=true;


            push(visitor,funStr,numParens,lhsIsArgOrVar,lhsIsAllZero,lhsSingleLine);
        end

        visitForLoopWrapper(visitor,LoopWrapper);



        compileOperator(visitor,op,Node);

        compileUnaryOperator(visitor,op,Node);

        compileUnaryOperatorZeroHandling(visitor,op,Node);

        compileScalarExpansion(visitor,childIdx,thisNode,otherNode);

        [indexingStr,indexingParens]=compileStaticIndexingString(visitor,Op,addParens);

        [linIdxStr,linIdxParens,linIdxBody]=compileStaticLinIdxString(visitor,Op,addParens);

        visitUnaryOperator(visitor,op,LeftExpr);

        visitNonlinearUnarySingleton(visitor,op,LeftExpr);

        visitOperatorCumfcn(visitor,op,Node);

        visitOperatorDiff(visitor,op,Node);

        visitOperatorDiag(visitor,op,Node);

        visitOperatorLdivide(visitor,op,LeftExpr);

        visitOperatorMinus(visitor,op,LeftExpr);

        visitOperatorMpower(visitor,op,Node);

        visitOperatorMtimes(visitor,op,LeftExpr,RightExpr);

        visitOperatorPlus(visitor,op,LeftExpr);

        visitOperatorPower(visitor,op,Node);

        visitOperatorProd(visitor,op,Node);

        visitOperatorRdivide(visitor,op,LeftExpr);

        visitOperatorStaticAssign(visitor,Op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

        visitOperatorStaticSubsref(visitor,Op,Node);

        visitOperatorSum(visitor,op,Node);

        visitOperatorTimes(visitor,op,LeftExpr);

        [indexingStr,indexingParens]=visitStaticIndexingString(visitor,Op,addParens);

        visitOperatorTranspose(visitor,op,Node);

        [funStr,numParens,isArgOrVar]=visitNumericExpression(visitor,expression,addParens);

        [funStr,numParens,isArgOrVar]=compileNumericExpression(visitor,expression,addParens);

    end

    methods

        function[varName,numParens,argBody,isArgOrVar]=addParensToArg(visitor,...
            argStr,numParens,isArgOrVar,singleLine,addParens)


            if~singleLine

                varName="arg"+visitor.getNumArgs();
                numParens=0;
                isArgOrVar=true;
                argBody=sprintf(argStr,varName)+newline;
            elseif numParens+addParens<visitor.MaxParensPerLine

                varName=argStr;
                argBody="";
            elseif isArgOrVar&&isinf(addParens)


                varName=argStr;
                argBody="";
            else

                varName="arg"+visitor.getNumArgs();
                numParens=0;
                isArgOrVar=true;
                argBody=varName+" = "+argStr+";"+newline;
            end
        end

    end

    methods(Static)

        function out=getNumArgs(~)
            persistent numArgs
            if nargin>0
                numArgs=0;
            elseif isempty(numArgs)
                numArgs=1;
            else
                numArgs=numArgs+1;
            end
            out=numArgs;
        end

        [outputStr,numParens,isArgOrVar,singleLine,forestBody]=reshapeInputStr(...
        outputName,outputSize,outputStr,numParens,isArgOrVar);

        doS=doSubsasgn(numTrees,forestIndexList,forestSize);

        doS=doSubsref(treeIndex,treeSize);

    end

end
