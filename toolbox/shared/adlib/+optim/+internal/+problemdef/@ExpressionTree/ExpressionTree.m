classdef ExpressionTree<handle






    properties(Hidden=true)


Type


        Variables=struct;
    end

    properties(Hidden=true,Dependent)


Root

Size


SupportsAD
    end

    properties(Hidden=true)


Stack


Depth
    end








    properties(Hidden,SetAccess=protected,GetAccess=?optim.internal.problemdef.ExpressionForest)



RefIdList
RefIdCount
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExpressionTreeVersion=2;
    end

    methods


        function obj=ExpressionTree()
        end


        function copy(obj,tree)
            obj.Depth=tree.Depth;
            obj.Stack=tree.Stack;
            obj.Variables=tree.Variables;
            obj.Type=tree.Type;
        end


        function rt=get.Root(obj)
            rt=obj.Stack{end};
        end

        function acceptVisitor(obj,visitor)
            visitTree(visitor,obj);
        end



        function sz=get.Size(obj)
            sz=obj.Root.Size;
        end

        function sz=size(obj)
            sz=obj.Size;
        end

        function supportsAD=get.SupportsAD(obj)
            supportsAD=obj.Root.SupportsAD;
        end

        function num=numel(obj)
            num=prod(obj.Size);
        end





        [nlfunStruct,jacStruct]=compileHessianForward(obj,nlfunStruct,jacStruct);


        [jacStruct,hessStruct]=compileHessianReverse(obj,jacStruct,hessStruct);




        createBinary(obj,Op,ExprLeft,ExprRight);


        createEndIndex(obj);


        createUnary(obj,Op,ExprLeft);


        createNumeric(obj,Value);


        createZeros(obj,sz);


        createVariable(obj,VariableImpl,varHandle);




        createSubsasgn(obj,sz,linIdxList,exprList,localIdxList,variables);


        createFunction(obj,func,vars,depth,sz,type,idx);


        createForLoop(obj,loopVariable,loopRange,loopBody,loopLevel,PtiesVisitor);


        createColon(obj,first,step,last);


        LHSExprImpl=createLHSExpression(obj,lhsName);


        createStaticAssignment(obj,Op,ExprLeft,ExprRight,PtiesVisitor);


        createStaticExpression(obj,lhsTree,stmtWrapper,type,vars);



        createUnaryWithCancellation(obj,Op,ExprLeft);



        createUnaryWithSimplification(obj,Op,ExprLeft);


        type=computeType(obj);



        [iss,newtree,c]=createExprIfSumSquares(obj);



        [isqrt,newtree,c,a]=createExprIfSqrt(obj);


        prepareForSolve(obj);



        [isqrt,innerNodeIdx]=getInnerSqrtExpression(obj,rootNodeIdx);


        iss=isSumSquares(obj);




        [c,isMonomialRoot,monomialFactor]=markMonomialTerms(obj);

    end

    methods(Static)
        function obj=loadobj(obj)


            visitor=optim.internal.problemdef.visitor.RebuildStack(numel(obj.Stack));
            visitTree(visitor,obj);
            obj.Stack=getOutputs(visitor);
        end
    end

end
