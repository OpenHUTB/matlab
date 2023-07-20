classdef Asinh<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Asinh();
    end

    properties(Hidden,Constant)
        OperatorStr="asinh";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AsinhVersion=1;
    end

    methods(Access=private)

        function op=Asinh()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=asinh(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./sqrt("+leftVarName+"(:).^2 + 1)";
            numParens=2;
        end
    end

    methods(Static)
        function op=getAsinhOperator(~,~)
            op=optim.internal.problemdef.operator.Asinh.Operator;
        end
    end

end
