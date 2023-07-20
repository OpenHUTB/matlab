classdef Sin<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Sin();
    end

    properties(Hidden,Constant)
        OperatorStr="sin";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        SinVersion=1;
    end

    methods(Access=private)

        function op=Sin()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=sin(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*cos("+leftVarName+"(:))";
            numParens=2;
        end
    end

    methods(Static)
        function op=getSinOperator(~,~)
            op=optim.internal.problemdef.operator.Sin.Operator;
        end
    end

end
