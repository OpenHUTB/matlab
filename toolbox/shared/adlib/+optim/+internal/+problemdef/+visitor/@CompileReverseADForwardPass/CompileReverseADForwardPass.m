classdef CompileReverseADForwardPass<optim.internal.problemdef.visitor.CompileNonlinearFunction






    properties(Hidden,Transient)






        IsFixedVar=logical.empty;


        DependsOnLoopVariable=logical.empty;
    end


    properties(Hidden,Transient)


        Tape={};


        WriteToArgTape=logical.empty;

        IsNodeLHS=logical.empty;
    end

    properties(Hidden,Transient)

        ForLoopTape={};
        ForLoopWriteToArgTape=logical.empty;
        ArgTapeTotalElem=0;


        AddTapeArg=false;
        ArgTapeName=[];
        ArgTapeHeadName=[];
    end

    methods

        function obj=CompileReverseADForwardPass(inputs)
            obj=obj@optim.internal.problemdef.visitor.CompileNonlinearFunction(inputs);



            obj.Reset=false;
        end

        function nlfunStruct=getOutputs(visitor)
            if visitor.AddTapeArg
                visitor.ExprBody=visitor.ArgTapeName+" = cell("+visitor.ArgTapeTotalElem+", 1);"...
                +newline+visitor.ArgTapeHeadName+" = 0;"+newline+visitor.ExprBody;
            end
            nlfunStruct=getOutputs@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor);
        end

    end

    methods(Access=private)



        function isFixedVar=isFixedVar(visitor,idx)
            isFixedVar=visitor.IsFixedVar(idx);
        end



        function isFixedVar=childIsFixedVar(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            isFixedVar=visitor.IsFixedVar(childHead);
        end



        function tf=dependsOnLoopVar(visitor,idx)
            tf=visitor.DependsOnLoopVariable(idx);
        end



        function tf=childDependsOnLoopVar(visitor,childIdx)
            childHead=visitor.ChildrenHead(childIdx);
            tf=visitor.DependsOnLoopVariable(childHead);
        end


        function storeForwardMemoryRAD(visitor,str,fixedVar)
            nArg=numel(visitor.Tape)+1;
            visitor.Tape{nArg}=str;
            visitor.WriteToArgTape(nArg)=~fixedVar;
        end




        function storeChildName(visitor,childIdx)

            childVarName=declareChildArgumentName(visitor,childIdx);
            childFixedVar=childIsFixedVar(visitor,childIdx);

            storeForwardMemoryRAD(visitor,childVarName,childFixedVar);
        end




        function storeChildMemory(visitor,childIdx)
            if isChildAllZero(visitor,childIdx)

                isFixedVar=true;
                storeForwardMemoryRAD(visitor,"",isFixedVar);
            else

                storeChildName(visitor,childIdx);
            end
        end

    end


    methods

        function push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine)
            push@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
            head=visitor.Head;


            visitor.IsFixedVar(head)=false;
            visitor.DependsOnLoopVariable(head)=true;
        end



        function pushFixedVar(visitor,fixedVar)
            head=visitor.Head;
            visitor.IsFixedVar(head)=fixedVar;
        end



        function pushDependsOnLoopVar(visitor,dependsOnLoopVar)
            head=visitor.Head;
            visitor.DependsOnLoopVariable(head)=dependsOnLoopVar;
        end

        function pushAllZeroNode(visitor,sz)


            pushAllZeroNode@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,sz);
            pushFixedVar(visitor,true);
            pushDependsOnLoopVar(visitor,false);
        end

        function argName=declareChildArgumentName(visitor,childIdx)
            if childDependsOnLoopVar(visitor,childIdx)&&~childIsFixedVar(visitor,childIdx)


                [varName,numParens,~,isAllZero,singleLine]=popChild(visitor,childIdx);




                isArgOrVar=false;
                addParens=Inf;
                [argName,numParens,varBody,isArgOrVar]=addParensToArg(visitor,...
                varName,numParens,isArgOrVar,singleLine,addParens);
                addToExprBody(visitor,varBody);
            else


                addParens=Inf;
                [argName,numParens,isArgOrVar,isAllZero]=getChildArgumentName(visitor,childIdx,addParens);
            end

            childHead=visitor.ChildrenHead(childIdx);
            visitor.FunStr{childHead}=argName;
            visitor.NumParens(childHead)=numParens;
            visitor.IsArgOrVar(childHead)=isArgOrVar;
            visitor.IsAllZero(childHead)=isAllZero;
            visitor.SingleLine(childHead)=true;
        end



        function[varName,numParens,isArgOrVar,isAllZero]=getChildArgumentName(visitor,childIdx,addParens)
            if childDependsOnLoopVar(visitor,childIdx)
                [varName,numParens,isArgOrVar,isAllZero]=...
                getChildArgumentName@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,childIdx,addParens);
            else

                [varName,numParens,isArgOrVar,isAllZero,singleLine]=popChild(visitor,childIdx);


                [varName,numParens,varBody,isArgOrVar]=addParensToArg(visitor,...
                varName,numParens,isArgOrVar,singleLine,addParens);
                addToPreLoopBody(visitor,varBody);
            end
        end



        function[indexingStr,indexingParens]=compileIndexingString(visitor,idx)


            [indexingStr,indexingParens]=...
            compileIndexingString@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
            visitor,idx);


            isFixedVar=true;
            storeForwardMemoryRAD(visitor,indexingParens,isFixedVar);
            storeForwardMemoryRAD(visitor,indexingStr,isFixedVar);
        end

        visitStatementWrapper(visitor,StmtWrapper);

        visitForLoopWrapper(visitor,LoopWrapper);



        function initializeLHS(visitor,LHS)
            notInitialized=isempty(LHS.VisitorIndex);
            initializeLHS@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,LHS);
            if notInitialized

                visitor.IsNodeLHS(LHS.VisitorIndex)=true;
            end
        end

        function visitLHSExpressionImpl(visitor,LHS)

            [lhsVarName,lhsNumParens]=popNode(visitor,LHS);





            lhsIsAllZero=false;
            lhsSingleLine=true;
            lhsIsArgOrVar=true;



            if visitor.IsNodeLHS(LHS.VisitorIndex)

                push(visitor,lhsVarName,lhsNumParens,lhsIsArgOrVar,lhsIsAllZero,lhsSingleLine);
                pushFixedVar(visitor,false);
                pushDependsOnLoopVar(visitor,true);
            else

                push(visitor,lhsVarName,lhsNumParens,lhsIsArgOrVar,lhsIsAllZero,lhsSingleLine);
                pushFixedVar(visitor,true);
                pushDependsOnLoopVar(visitor,true);
            end
        end

        function visitVariableExpressionImpl(visitor,Node)
            visitVariableExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Node);


            pushFixedVar(visitor,true);
            pushDependsOnLoopVar(visitor,false);
        end

        function visitNumericExpressionImpl(visitor,Node)
            visitNumericExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Node);


            pushFixedVar(visitor,true);
            pushDependsOnLoopVar(visitor,false);
        end

        function visitIndexingVector(visitor,val)
            visitIndexingVector@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,val);


            pushFixedVar(visitor,true);
            pushDependsOnLoopVar(visitor,false);
        end

        function visitNonlinearExpressionImpl(visitor,Node)




            prevTape=visitor.Tape;
            prevWriteToArgTape=visitor.WriteToArgTape;
            visitNonlinearExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Node);
            visitor.Tape=prevTape;
            visitor.WriteToArgTape=prevWriteToArgTape;
        end

        function visitColonExpressionImpl(visitor,Node)


            args=Node.Arguments;
            optimArg=Node.OptimArg;
            Nargs=numel(args);

            argStr=strings(Nargs,1);

            argNumParens=1;


            colIsFixedVar=true;
            colDependsOnLoopVar=false;
            head=visitor.Head;
            for i=1:Nargs
                arg=args{i};
                if optimArg(i)

                    acceptVisitor(arg,visitor);


                    [argStr(i),thisParens]=getArgumentName(visitor,argNumParens);
                    colIsFixedVar=colIsFixedVar&&isFixedVar(visitor,head+1);
                    colDependsOnLoopVar=colDependsOnLoopVar||dependsOnLoopVar(visitor,head+1);
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
            pushFixedVar(visitor,colIsFixedVar);
            pushDependsOnLoopVar(visitor,colDependsOnLoopVar);
        end

        function visitEndIndexExpressionImpl(visitor,Node)
            visitEndIndexExpressionImpl@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Node);
            pushFixedVar(visitor,true);
        end

    end


    methods

        visitUnaryOperatorWithStorage(visitor,op,Node);

        visitNonlinearUnarySingleton(visitor,op,Node);

        visitOperatorCumfcn(visitor,op,LeftExpr);

        visitOperatorDiag(visitor,op,LeftExpr);

        visitOperatorDiff(visitor,op,LeftExpr);

        visitOperatorLdivide(visitor,op,LeftExpr,RightExpr);

        visitOperatorMpower(visitor,op,LeftExpr);

        visitOperatorMtimes(visitor,op,LeftExpr,RightExpr);

        visitOperatorPower(visitor,op,LeftExpr);

        visitOperatorProd(visitor,op,LeftExpr);

        visitOperatorRdivide(visitor,op,LeftExpr,RightExpr);

        visitOperatorTimes(visitor,op,LeftExpr,RightExpr);

        [indexingStr,indexingNumParens,indexIsArgOrVar,indexFixedVar,indexDependsOnLoopVar]=...
        compileStaticIndexingString(visitor,Op,addParens);

        [indexingStr,indexingParens,indexDependsOnLoopVar]=visitStaticIndexingString(visitor,Op,addParens);

        [funStr,numParens,isArgOrVar]=visitNumericExpression(visitor,expression,addParens);

        visitOperatorStaticAssign(visitor,Op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

        visitOperatorStaticSubsref(visitor,Op,Node);

    end


end
