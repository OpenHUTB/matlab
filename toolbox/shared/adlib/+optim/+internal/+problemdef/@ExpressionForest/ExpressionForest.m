classdef ExpressionForest<handle















































    properties(Hidden,Access={?optim.internal.problemdef.visitor.Visitor})

TreeList


ForestIndexList

TreeIndexList

NumTrees

Size


SingleTreeSpansAllIndices
    end

    properties(Hidden)


        Variables=struct;
    end

    properties(Hidden=true,Dependent)


Type


SupportsAD
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExpressionForestVersion=1;
    end

    methods


        function obj=ExpressionForest()
        end


        function copy(obj,LHS)
            obj.TreeList=LHS.TreeList;
            obj.ForestIndexList=LHS.ForestIndexList;
            obj.TreeIndexList=LHS.TreeIndexList;
            obj.NumTrees=LHS.NumTrees;
            obj.Size=LHS.Size;
            obj.SingleTreeSpansAllIndices=LHS.SingleTreeSpansAllIndices;
            obj.Variables=LHS.Variables;
        end

        function acceptVisitor(obj,visitor)
            visitForest(visitor,obj);
        end




        function sz=size(obj)
            sz=obj.Size;
        end


        function len=length(obj)
            len=max(obj.Size);
        end


        function val=isscalar(obj)
            val=all(obj.Size==1);
        end


        function out=numel(obj)
            out=prod(obj.Size);
        end



        function set.Size(obj,val)

            nout=numel(val);
            for i=nout:-1:2
                if(val(i)~=1)
                    break;
                end
            end

            val(i+1:end)=[];

            obj.Size=val;
        end

        function type=get.Type(obj)
            if obj.NumTrees==0
                type=optim.internal.problemdef.ImplType.Numeric;
                return;
            end
            treeList=obj.TreeList;
            nTrees=obj.NumTrees;

            treei=treeList{1};

            type=treei.Type;
            if nTrees>1
                typeList=optim.internal.problemdef.ImplType(zeros(nTrees,1));
                typeList(1)=type;

                for i=2:nTrees

                    treei=treeList{i};

                    typeList(i)=treei.Type;
                end

                type=optim.internal.problemdef.ImplType.typeSubsasgn(typeList);
            end
        end

        function supportsAD=get.SupportsAD(obj)
            if obj.NumTrees==0
                supportsAD=true;
                return;
            end
            treeList=obj.TreeList;
            supportsAD=all(cellfun(@(x)x.SupportsAD,treeList));
        end



        tree=forest2tree(obj);



        tree2forest(obj,tree);



        function vars=computeVariables(obj)
            nTrees=obj.NumTrees;
            if nTrees==0

                vars=struct;
            else

                treeList=obj.TreeList;
                treei=treeList{1};
                vars=treei.Variables;
                if nTrees>1
                    varsList=cell(nTrees,1);
                    varsList{1}=vars;

                    for i=2:nTrees

                        treei=treeList{i};
                        varsList{i}=treei.Variables;
                    end

                    vars=optim.internal.problemdef.HashMapFunctions.arrayunion(varsList,'OptimizationExpression');
                end
            end
        end



        function linIdx=getVarIdx(obj)
            if obj.SingleTreeSpansAllIndices

                linIdx=1:numel(obj);
            else
                if obj.NumTrees




                    linIdx=obj.TreeIndexList{1};
                else

                    linIdx=[];
                end
            end
        end


        function depth=getDepth(obj)

            treeList=obj.TreeList;

            nTrees=obj.NumTrees;
            if nTrees==0

                depth=0;
            else

                treei=treeList{1};

                depth=treei.Depth;

                for i=2:nTrees

                    treei=treeList{i};

                    depth=max(depth,treei.Depth);
                end
            end
        end




        initializeVariableMemory(obj,TotalVar);


        [A,b]=extractLinearCoefficients(obj,TotalVar);


        [H,A,b]=extractQuadraticCoefficients(obj,TotalVar);


        value=evaluate(obj,varVal);


        nlfunStruct=compileNonlinearFunction(obj,inputs);


        [nlfunStruct,jacStruct]=compileForwardAD(obj,inputs);


        [nlfunStruct,jacStruct]=compileReverseAD(obj,inputs);


        [nlfunStruct,jacStruct,hessStruct]=compileHessianFunction(obj,nlfunStruct,jacStruct,hessStruct);




        createBinary(obj,Op,ExprLeft,ExprRight);


        createEndIndex(obj);


        createUnary(obj,Op,ExprLeft);


        createNumeric(obj,Value);


        createZeros(obj,sz);


        createVariable(obj,VariableImpl,varHandle);


        createSubsref(obj,expr,linIdx,outSize);


        createSubsasgn(obj,exprLHS,linIdx,exprRHS,sz);


        createSubsasgnDelete(obj,exprLHS,linIdx,sz);


        createConcat(obj,ExprList,dim,outSize);


        createReshape(obj,expr,outSize);


        createFunction(obj,func,vars,depth,sz,type,idx);


        createForLoop(obj,loopVariable,loopRange,loopBody,loopLevel,PtiesVisitor);


        createColon(obj,first,step,last);


        LHSExprImpl=createLHSExpression(obj,lhsName);


        createStaticAssignment(obj,Op,ExprLeft,ExprRight,PtiesVisitor);


        createStaticExpression(obj,lhsForest,stmtWrapper,type,vars);



        createUnaryWithCancellation(obj,Op,ExprLeft);



        createUnaryWithSimplification(obj,Op,ExprLeft);



        [iss,c,idx]=createExprIfSumSquares(obj,expr);



        [isqrt,c,a]=createExprIfSqrt(obj,expr);




        SubsasgnDeleteIdx(obj,linIdx,checkTrees);


        isinit=isInitialized(obj);


        iss=isSumSquares(obj);



        updateVarStructOnVarLoadv1tov2(obj,newvar);

    end


end
