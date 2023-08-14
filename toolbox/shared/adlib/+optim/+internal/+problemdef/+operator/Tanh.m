classdef Tanh<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Tanh();
    end

    properties(Hidden,Constant)
        OperatorStr="tanh";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        TanhVersion=1;
    end

    methods(Access=private)

        function op=Tanh()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=tanh(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*(sech("+leftVarName+"(:)).^2)";
            numParens=3;
        end
    end

    methods(Static)
        function op=getTanhOperator(~,~)
            op=optim.internal.problemdef.operator.Tanh.Operator;
        end
    end

end
