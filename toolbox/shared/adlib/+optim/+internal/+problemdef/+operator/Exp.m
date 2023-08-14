classdef Exp<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Exp();
    end

    properties(Hidden,Constant)
        OperatorStr="exp";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        ExpVersion=1;
    end

    methods(Access=private)

        function op=Exp()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=exp(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*exp("+leftVarName+"(:))";
            numParens=2;
        end
    end

    methods(Static)

        function op=getExpOperator(~,~)

            op=optim.internal.problemdef.operator.Exp.Operator;
        end

    end

end
