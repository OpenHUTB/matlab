classdef Tan<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Tan();
    end

    properties(Hidden,Constant)
        OperatorStr="tan";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        TanVersion=1;
    end

    methods(Access=private)

        function op=Tan()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=tan(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*sec("+leftVarName+"(:)).^2";
            numParens=2;
        end
    end

    methods(Static)
        function op=getTanOperator(~,~)
            op=optim.internal.problemdef.operator.Tan.Operator;
        end
    end

end
