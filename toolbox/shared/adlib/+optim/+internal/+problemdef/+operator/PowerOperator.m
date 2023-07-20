classdef PowerOperator<optim.internal.problemdef.Operator




    properties(Hidden)

Exponent

        ExponentIsOptimExpr=false;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)

        PowerOperatorVersion=2;
    end

    methods(Access=public)

        function op=PowerOperator(obj,b)

            checkIsValid(op,obj,b);

            exponentIsOptimExpr=isa(b,'optim.problemdef.OptimizationExpression');
            if~exponentIsOptimExpr
                op.Exponent=b;
            else

                op.Exponent=forest2tree(getExprImpl(b));
                op.ExponentIsOptimExpr=true;
            end
        end

        function isint=integerExponent(op)
            if op.ExponentIsOptimExpr


                isint=false;
            else
                exponent=op.Exponent;
                isint=exponent==floor(exponent);
            end
        end



        function op=simplify(op,op2)

            op.Exponent=op.Exponent*op2.Exponent;
        end


        function outType=getOutputType(op,LeftType,~,evalVisitor)
            if nargin<4


                evalVisitor=optim.internal.problemdef.visitor.StaticEvaluate;
            end

            exponent=getExponent(op,evalVisitor);

            if exponent==0
                outType=optim.internal.problemdef.ImplType.Numeric;
            elseif exponent==1
                outType=LeftType;
            elseif exponent==2
                outType=optim.internal.problemdef.ImplType.typeTimes(LeftType,LeftType);
            elseif LeftType==optim.internal.problemdef.ImplType.Numeric
                outType=optim.internal.problemdef.ImplType.Numeric;
            else
                outType=optim.internal.problemdef.ImplType.Nonlinear;
            end
        end


        function numParens=getOutputParens(op)
            if integerExponent(op)


                numParens=0;
            else


                numParens=1;
            end
        end

        function[funStr,leftParens]=buildNonlinearStr(op,visitor,...
            leftVarName,~,leftParens,~)
            exponent=op.Exponent;
            if op.ExponentIsOptimExpr
                addParens=0;
                [exponentName,leftParens]=visitNumericExpression(visitor,exponent,addParens);
            elseif integerExponent(op)||visitor.ForDisplay


                exponentName=exponent;
            else


                inputIdx=pushExtraParam(visitor,exponent);
                exponentName=visitor.ExtraParamsName+"{"+inputIdx+"}";
                leftParens=leftParens+1;
            end
            funStr=leftVarName+op.OperatorStr+exponentName;
        end

    end

    methods

        function exponent=getExponent(op,evalVisitor)
            if~op.ExponentIsOptimExpr
                exponent=op.Exponent;
                return;
            end


            acceptVisitor(op.Exponent,evalVisitor);
            exponent=getValue(evalVisitor);
        end
    end

    methods(Access=protected)



        function ok=checkIsValid(~,~,b)
            isNumericOrLogical=isnumeric(b)||islogical(b);
            exponentIsOptimExpr=isa(b,'optim.problemdef.OptimizationExpression');
            if~(isNumericOrLogical||exponentIsOptimExpr)...
                ||(isNumericOrLogical&&(~isscalar(b)||~isreal(b)||isnan(b)||~isfinite(b)))...
                ||(exponentIsOptimExpr&&~isNumeric(b))
                throwAsCaller(MException(message('shared_adlib:operators:InvalidPower')));
            end
            ok=true;
        end
    end

end
