classdef(HandleCompatible)OptimizationExpression<matlab.mixin.CustomDisplay

























    properties
        IndexNames={{},{}};
    end

    properties(Dependent=true)


Variables
    end

    properties(Hidden,Access=protected)




        IndexNamesStore={{},{}}

    end

    properties(Hidden,SetAccess=protected)

OptimExprImpl
    end

    properties(Hidden,Dependent=true)

ExprType


Size



SupportsAD
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        OptimizationExpressionVersion=2;
    end

    methods(Hidden)






        function obj=OptimizationExpression(sz,idxnames)


















            if nargin==1
                if isa(sz,'optim.problemdef.OptimizationExpression')


                    obj.IndexNamesStore=sz.IndexNames;
                    obj.OptimExprImpl=sz.OptimExprImpl;
                    return;
                elseif isempty(sz)


                    obj.OptimExprImpl=optim.internal.problemdef.ExpressionForest;
                    return;
                end
            end

            if nargin==0



                sz=[1,1];
                idxnames={{},{}};
            end


            obj.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(idxnames,sz);


            obj.OptimExprImpl=optim.internal.problemdef.ExpressionForest;
            createZeros(obj.OptimExprImpl,sz);
        end

    end

    methods




        function val=get.Size(obj)
            val=size(obj.OptimExprImpl);
        end



        function val=get.IndexNames(obj)
            val=getIndexNames(obj);
        end

        function vars=get.Variables(obj)
            vars=obj.OptimExprImpl.Variables;
        end

        function obj=set.IndexNames(obj,indexNames)


            obj=setIndexNames(obj,indexNames);
        end

        function val=get.ExprType(obj)
            val=obj.OptimExprImpl.Type;
        end

        function val=get.SupportsAD(obj)
            val=obj.OptimExprImpl.SupportsAD;
        end





        varargout=size(obj,varargin);

        function len=length(obj)





            len=length(obj.OptimExprImpl);
        end


        function out=numel(obj)



            out=numel(obj.OptimExprImpl);
        end

        function out=isempty(obj)




            out=any(~getSize(obj));
        end

        function val=isscalar(obj)



            val=isscalar(obj.OptimExprImpl);
        end




        function eout=plus(obj,expr)





            [obj,expr]=wrapNumeric(obj,expr);


            Op=optim.internal.problemdef.Plus.getPlusOperator(obj,expr);
            eout=createBinary(obj,expr,Op);
        end


        function eout=minus(obj,expr)





            [obj,expr]=wrapNumeric(obj,expr);


            Op=optim.internal.problemdef.Minus.getMinusOperator(obj,expr);
            eout=createBinary(obj,expr,Op);
        end


        function eout=uplus(obj)






            eout=createUplus(obj);
        end


        function eout=uminus(obj)





            Op=optim.internal.problemdef.Uminus.getUminusOperator();
            eout=createUnaryWithCancellation(obj,Op);
        end


        function eout=ldivide(expr,obj)





            [obj,expr]=wrapNumeric(obj,expr);


            Op=optim.internal.problemdef.Ldivide.getLdivideOperator(expr,obj);
            eout=createBinary(expr,obj,Op);
        end


        function eout=rdivide(obj,expr)





            [obj,expr]=wrapNumeric(obj,expr);


            Op=optim.internal.problemdef.Rdivide.getRdivideOperator(obj,expr);
            eout=createBinary(obj,expr,Op);
        end






        function eout=times(obj,expr)





            [obj,expr]=wrapNumeric(obj,expr);

            Op=optim.internal.problemdef.Times.getTimesOperator(obj,expr);

            eout=createBinary(obj,expr,Op);
        end


        function eout=mldivide(expr,obj)








            [obj,expr]=wrapNumeric(obj,expr);

            Op=optim.internal.problemdef.Ldivide.getLdivideOperator(expr,obj);


            if~isscalar(expr)
                error(message('shared_adlib:operators:NonScalarDivision'));
            end

            eout=createBinary(expr,obj,Op);
        end


        function eout=mrdivide(obj,expr)








            [obj,expr]=wrapNumeric(obj,expr);

            Op=optim.internal.problemdef.Rdivide.getRdivideOperator(obj,expr);


            if~isscalar(expr)
                error(message('shared_adlib:operators:NonScalarDivision'));
            end

            eout=createBinary(obj,expr,Op);
        end


        function eout=mtimes(obj,expr)




            if isscalar(obj)||isscalar(expr)
                eout=times(obj,expr);
            else

                [obj,expr]=wrapNumeric(obj,expr);
                Op=optim.internal.problemdef.Mtimes(obj,expr);
                eout=createBinary(obj,expr,Op);
            end
        end


        function eout=sum(obj,dim)





            if nargin==1
                Op=optim.internal.problemdef.SumOperator(obj);
            else
                Op=optim.internal.problemdef.SumOperator(obj,dim);
            end

            eout=createUnary(obj,Op);
        end


        eout=prod(obj,varargin);


        eout=reshape(obj,varargin);


        function eout=transpose(obj)




            Op=optim.internal.problemdef.Transpose(obj);
            eout=createUnaryWithCancellation(obj,Op);
        end


        function eout=ctranspose(obj)




            eout=transpose(obj);
        end


        eout=cumprod(obj,varargin);


        eout=cumsum(obj,varargin);


        eout=diag(obj,k);


        eout=diff(obj,N,dim);


        eout=cat(dim,varargin);


        eout=power(obj,b);


        eout=mpower(obj,b);


        eout=mean(obj,dim);


        eout=dot(obj1,obj2,dim);


        function out=horzcat(obj,varargin)




            out=cat(2,obj,varargin{:});
        end


        function out=vertcat(obj,varargin)




            out=cat(1,obj,varargin{:});
        end




        eout=atanh(obj);


        eout=tanh(obj);


        eout=atan(obj);


        eout=tan(obj);


        eout=acosh(obj);


        eout=cosh(obj);


        eout=asinh(obj);


        eout=sinh(obj);


        eout=acos(obj);


        eout=cos(obj);


        eout=asin(obj);


        eout=sin(obj);


        eout=cot(obj);


        eout=acot(obj);


        eout=coth(obj);


        eout=acoth(obj);


        eout=csc(obj);


        eout=acsc(obj);


        eout=csch(obj);


        eout=acsch(obj);


        eout=sec(obj);


        eout=asec(obj);


        eout=sech(obj);


        eout=asech(obj);


        eout=exp(obj);


        eout=log(obj);


        eout=sqrt(obj);


        eout=norm(obj,normType);


        eout=colon(first,step,last);




        function constr=lt(~,~)%#ok








            throwAsCaller(MException(...
            message('shared_adlib:OptimizationExpression:LtNotSupported','<','<=')));
        end


        function constr=gt(~,~)%#ok








            throwAsCaller(MException(...
            message('shared_adlib:OptimizationExpression:GtNotSupported','>','>=')));
        end


        function ineq=le(a,b)












            [a,b]=wrapNumeric(a,b);

            optim.internal.problemdef.checkDimensionMatch(a,b);
            ineq=optim.problemdef.OptimizationInequality(a,'<=',b);
        end


        function ineq=ge(a,b)












            [a,b]=wrapNumeric(a,b);

            optim.internal.problemdef.checkDimensionMatch(a,b);
            ineq=optim.problemdef.OptimizationInequality(a,'>=',b);
        end


        function equ=eq(a,b)












            [a,b]=wrapNumeric(a,b);

            optim.internal.problemdef.checkDimensionMatch(a,b);
            equ=optim.problemdef.OptimizationEquality(a,'==',b);
        end



        value=evaluate(expr,varVal);



        show(obj);
        write(obj,varargin);

    end



    methods(Hidden,Access=public)



        showexpr(obj);
        writeexpr(obj,varargin);


        function obj=conj(obj)






        end




        function val=isnumeric(~)
            val=false;
        end




        varargout=subsref(obj,sub);


        obj=subsasgn(obj,sub,expr);

        function ind=end(obj,k,n)








            szd=size(obj);
            if k<n
                ind=szd(k);
            else
                ind=prod(szd(k:end));
            end
        end


        [exprStr,nzIdx,hasHTML]=expand2str(obj,varargin);
        [outStr,extraParamsStr,displayEntrywise,nzIdx]=expandNonlinearStr(expr,showExtraParamsLink);
        eout=permute(obj,order);


        nlfunStruct=compileNonlinearFunction(expr,varargin);



        [nlfunStruct,jacStruct]=compileForwardAD(expr,varargin);


        [nlfunStruct,jacStruct]=compileReverseAD(expr,varargin);


        [nlfunStruct,jacStruct,hessStruct]=compileHessianFunction(expr,varargin);


        function val=getSize(obj)
            val=size(obj.OptimExprImpl);
        end

        function val=getVariables(obj)
            val=obj.Variables;
        end

        function val=getExprType(obj)
            val=obj.ExprType;
        end

        function val=getSupportsAD(obj)
            val=obj.SupportsAD;
        end

        function val=getType(obj)
            val=obj.ExprType;
        end

        function val=getExprImpl(obj)
            val=obj.OptimExprImpl;
        end

        function idxnames=getIndexNames(obj)

            idxnames=obj.IndexNamesStore;
        end

        function obj=setIndexNames(obj,val)


            obj.IndexNamesStore=optim.internal.problemdef.validateIndexNames(val,getSize(obj));
        end




        [A,b]=extractLinearCoefficients(obj,TotalVar);
        [H,A,b]=extractQuadraticCoefficients(obj,TotalVar);



        n=numArgumentsFromSubscript(obj,sub,indexingContext);











        function[code,msg]=variableEditorSetDataCode(~,varname,row,column,newValue)
            if row==1&&column==1&&contains(varname,"(")

                code=varname+" = "+newValue+";";
            else
                code=varname+"("+row+","+column+") = "+newValue+";";
            end
            code=char(code);
            msg='';
        end



        value=evaluateNoCheck(expr,varVal);



        function str=getDimensionAsString(expr)
            str=string(matlab.mixin.CustomDisplay.convertDimensionsToString(expr));
        end


        [fh,extraParams]=optimexpr2fcn(expr,filename,inMemory,useParallel,ADType,DerivativeType,DerivativeOnly);


        function islin=isLinear(expr)
            islin=expr.ExprType<optim.internal.problemdef.ImplType.Quadratic;
        end


        function isnum=isNumeric(expr)
            isnum=expr.ExprType==optim.internal.problemdef.ImplType.Numeric;
        end


        function isquad=isQuadratic(expr)
            isquad=expr.ExprType==optim.internal.problemdef.ImplType.Quadratic;
        end


        function isnonlin=isNonlinear(expr)
            isnonlin=expr.ExprType>optim.internal.problemdef.ImplType.Quadratic;
        end


        iss=isSumSquares(expr);

    end

    methods(Hidden)

        eout=createFunction(expr,optimFunc,vars,depth,outSize,type,index);



        [iss,eout,c,idx]=createExprIfSumSquares(expr);



        [isqrt,eout,const,fac]=createExprIfSqrt(expr);


        eout=createForLoop(loopVariable,loopRange,loopBody,loopLevel,PtiesVisitor);




        isinit=isInitialized(expr);
    end

    methods(Hidden,Access=protected)




        displayScalarObject(obj);



        displayNonScalarObject(obj);



        displayEmptyObject(obj);


        groups=getPropertyGroups(obj);


        footer=getFooter(expr);
    end

    methods(Hidden,Access=?optim.problemdef.OptimizationConstraint)


        eout=createSubsasgn(expr,sub,exprRHS);
        eout=createSubsasgnDelete(expr,sub);


        eout=createSubsref(obj,sub);
    end

    methods(Hidden,Access=protected)
        obj=reloadv1tov2(obj,ein);

        eout=createUnary(expr,Op,varargin);
        eout=createBinary(expr1,expr2,Op);
        eout=createUnaryWithCancellation(expr,Op);
        eout=createUnaryWithSimplification(expr,Op);
        eout=createUplus(expr);
    end

    methods(Hidden)
        eout=createStaticAssign(eout,ein,ptiesVisitor);
        eout=createStaticSubsref(ExprLeft,index);
        eout=createStaticSubsasgn(eout,index,ein,ptiesVisitor);
        eout=createStaticAssignment(ExprLeft,ExprRight,Op,ptiesVisitor);
        eout=createStaticExpression(lhsExpr,stmtWrapper,type,vars);
    end

    methods(Hidden,Static)
        eout=loadobj(ein);
        eout=empty(varargin);

        nlfunStruct=createNLfunStruct(inputs);

        [eout,LHSExprImpl]=createLHSExpr(LHSName,ptiesVisitor);

        eout=createEndIndex();

        eout=wrapData(data);



        function list=getPublicPropertiesAndSupportedHiddenMethods()
            list={'IndexNames','Variables','showexpr','writeexpr'};
        end

        function eout=wrapNumeric(val)
            try
                if~isa(val,'optim.problemdef.OptimizationExpression')
                    eout=optim.problemdef.OptimizationNumeric(val);
                else
                    eout=val;
                end
            catch E
                throwAsCaller(E)
            end
        end

    end

    methods(Hidden,Access=private)


        writeDisplay2File(expr,defaultFilename,varargin)

    end


end

function[a,b]=wrapNumeric(a,b)



    try
        if~isa(b,'optim.problemdef.OptimizationExpression')
            b=optim.problemdef.OptimizationNumeric(b);
        elseif~isa(a,'optim.problemdef.OptimizationExpression')
            a=optim.problemdef.OptimizationNumeric(a);
        end
    catch E
        throwAsCaller(E)
    end
end
