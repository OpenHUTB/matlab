classdef NonlinearUnarySingleton<optim.internal.problemdef.Operator










    methods(Abstract)

        [gradStr,numParens]=getGradientString(op,leftVarName);
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        NonlinearUnarySingletonVersion=1;
    end

    methods


        function op=NonlinearUnarySingleton()
        end


        function outType=getOutputType(~,LeftType,~,~)


            if LeftType==optim.internal.problemdef.ImplType.Numeric
                outType=LeftType;
            else
                outType=optim.internal.problemdef.ImplType.Nonlinear;
            end
        end


        function numParens=getOutputParens(~)
            numParens=1;
        end

        function[funStr,numParens]=buildNonlinearStr(op,~,...
            leftVarName,~,leftParens,~)

            funStr=op.OperatorStr+"("+leftVarName+")";
            numParens=leftParens+1;
        end

        function acceptVisitor(op,visitor,Node)
            visitNonlinearUnarySingleton(visitor,op,Node);
        end

    end

    methods(Access=protected,Static)

        function ok=checkIsValid(~,~)

            ok=true;
        end
    end

end
