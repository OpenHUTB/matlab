classdef Sqrt<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Sqrt();
    end

    properties(Hidden,Constant)
        OperatorStr="sqrt";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        SqrtVersion=1;
    end

    methods(Access=private)

        function op=Sqrt()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=sqrt(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)


            gradStr=".*0.5./sqrt("+leftVarName+"(:))";
            numParens=2;
        end
    end

    methods(Static)

        function op=getSqrtOperator(~,~)

            op=optim.internal.problemdef.operator.Sqrt.Operator;
        end

    end

end
