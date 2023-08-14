classdef ExtractLinearCoefficients<optim.internal.problemdef.visitor.Visitor




    properties(Hidden=true,Transient)

        A={};

        b={};


        NodeStackIndex=zeros(1,20);
    end

    properties(Hidden)



TotalVar

NumElem
    end

    properties(Hidden,Transient)

        NodeA={};
        Nodeb={};
    end

    methods

        function obj=ExtractLinearCoefficients(vars,totalVar,nElem)
            varnames=string(fieldnames(vars));
            nVars=numel(varnames);
            if nVars>0
                varA=cell(1,nVars);
                varb=cell(1,nVars);
                curVarImpls=cell(1,nVars);
                numNodes=obj.NumNodes;
                for i=1:nVars

                    curVar=vars.(varnames{i});
                    curVarImpl=getVariableImpl(curVar);
                    curVarImpls{i}=curVarImpl;

                    nVarA=numel(curVar);
                    varIdxA=1:nVarA;
                    idx=getOffset(curVar)+varIdxA-1;
                    varA{i}=sparse(idx,varIdxA,ones(1,nVarA),totalVar,nVarA);
                    varb{i}=zeros(nVarA,1);

                    curVarImpl.VisitorIndex=i;
                end

                obj.Nodes=curVarImpls;
                obj.NumNodes=numNodes+nVars;
                obj.VisitorIndexMap=true(nVars,1);

                obj.NodeA=varA;
                obj.Nodeb=varb;
            end
            obj.TotalVar=totalVar;
            obj.NumElem=nElem;
        end

        function[Aval,bval]=getOutputs(visitor)
            head=visitor.Head;
            [bval,Aval]=pop(visitor,head);


            if isempty(Aval)
                Aval=sparse(visitor.TotalVar,visitor.NumElem);
            end
        end

        function value=getValue(visitor)
            head=visitor.Head;
            value=pop(visitor,head);
            visitor.Head=visitor.Head-1;
        end

        function pushValue(visitor,bval)
            push(visitor,[],bval);
        end

    end

    methods

        function push(visitor,Aval,bval)

            head=visitor.Head+1;
            visitor.A{head}=Aval;
            visitor.b{head}=bval;
            visitor.NodeStackIndex(head)=0;
            visitor.Head=head;
        end

        function pushNodeToStack(visitor,Node)

            head=visitor.Head+1;
            visitor.NodeStackIndex(head)=Node.VisitorIndex;
            visitor.Head=head;
        end

        function[bval,Aval]=popChild(visitor,childIdx)

            childHead=visitor.ChildrenHead(childIdx);
            [bval,Aval]=pop(visitor,childHead);
        end

        function[bval,Aval]=popParent(visitor)

            parentHead=visitor.ParentHead;
            [bval,Aval]=pop(visitor,parentHead);
        end

        function[bval,Aval]=pop(visitor,idx)

            nodeStackIndex=visitor.NodeStackIndex(idx);
            if nodeStackIndex==0

                bval=visitor.b{idx};
                Aval=visitor.A{idx};
            else

                bval=visitor.Nodeb{nodeStackIndex};
                Aval=visitor.NodeA{nodeStackIndex};
            end
        end

        function pushNode(visitor,Node,Aval,bval)

            nodeIdx=Node.VisitorIndex;
            visitor.NodeA{nodeIdx}=Aval;
            visitor.Nodeb{nodeIdx}=bval;
        end

        function[bval,Aval]=popNode(visitor,Node)
            nodeIdx=Node.VisitorIndex;
            Aval=visitor.NodeA{nodeIdx};
            bval=visitor.Nodeb{nodeIdx};
        end

        function visitZeroExpressionImpl(visitor,Node)
            nElem=prod(Node.Size);
            Aval=[];
            bval=zeros(nElem,1);
            push(visitor,Aval,bval);
        end

        function visitNumericExpressionImpl(visitor,Node)
            Aval=[];
            bval=Node.Value(:);
            push(visitor,Aval,bval);
        end

        function visitVariableExpressionImpl(visitor,Var)

            pushNodeToStack(visitor,Var);
        end

        visitIndexingNode(visitor,visitTreeFun,forestSize,...
        nTrees,treeList,forestIndexList,treeIndexList);

        function visitNonlinearExpressionImpl(visitor,Node)


            outputVals=visitFunctionWrapper(visitor,Node.FunctionImpl);
            val=outputVals{Node.OutputIndex};
            push(visitor,[],val);
        end

        function outputVals=visitFunctionWrapper(visitor,fcnWrapper)



            outputVals=cell(1,fcnWrapper.NumArgOut);

            inputs=fcnWrapper.Inputs;
            nInputs=numel(inputs);
            inputVals=cell(1,nInputs);
            for i=1:nInputs
                inputi=inputs{i};

                visitForest(visitor,inputi);

                inputVals{i}=getValue(visitor);
            end

            [outputVals{:}]=feval(fcnWrapper.Func,inputVals{:});

        end

        function visitLHSExpressionImpl(visitor,LHS)

            pushNodeToStack(visitor,LHS);
        end

        function pushLoopVarValue(visitor,loopVar,val)

            pushNode(visitor,loopVar,[],val);
        end

        function visitColonExpressionImpl(visitor,Node)
            Aval=[];

            val=getValue(Node,visitor);
            bval=val(:);
            push(visitor,Aval,bval);
        end

        function visitEndIndexExpressionImpl(visitor,~)
            endVal=popParent(visitor);
            pushValue(visitor,endVal);
        end



        visitUnaryOperator(visitor,op,Node);

        visitElementwiseOperator(visitor,op,Node);

        visitNonlinearUnarySingleton(visitor,op,Node);

        visitOperatorCumprod(visitor,op,Node);

        visitOperatorCumsum(visitor,op,Node);

        visitOperatorDiag(visitor,op,Node);

        [Aout,bout,idx]=visitOperatorDiagMatrixInput(visitor,ALeft,bLeft,inputSz,outputSz,diagK);

        [Aout,bout,idx]=visitOperatorDiagVectorInput(visitor,ALeft,bLeft,inputSz,outputSz,diagK);

        visitOperatorDiff(visitor,op,Node);

        visitOperatorLdivide(visitor,op,Node);

        visitOperatorMpower(visitor,op,Node);

        visitOperatorMtimes(visitor,op,Node);

        [Aout,bout]=visitOperatorMtimesZeroALeft(visitor,op,bLeft,ARight,bRight);

        [Aout,bout]=visitOperatorMtimesZeroARight(visitor,op,ALeft,bLeft,bRight);

        visitOperatorPower(visitor,op,Node);

        visitOperatorProd(visitor,op,Node);

        visitOperatorRdivide(visitor,op,Node);

        visitOperatorSum(visitor,op,Node);

        visitOperatorTimes(visitor,op,Node);

        visitOperatorTranspose(visitor,op,Node);

        [Aout,bout]=visitOperatorTransposeWithIndex(visitor,ALeft,bLeft,NewIdxOrder);




        visitOperatorStaticAssign(visitor,op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

    end

    methods(Static)




        [Aout,bout]=extractLinearCoefficientsForSubsasgn(Aout,bout,Aright,bRight,linIdx,nVar);

    end

end
