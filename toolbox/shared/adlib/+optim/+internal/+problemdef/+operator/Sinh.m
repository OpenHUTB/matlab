classdef Sinh<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Sinh();
    end

    properties(Hidden,Constant)
        OperatorStr="sinh";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        SinhVersion=1;
    end

    methods(Access=private)

        function op=Sinh()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=sinh(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*cosh("+leftVarName+"(:))";
            numParens=2;
        end
    end

    methods(Static)
        function op=getSinhOperator(~,~)
            op=optim.internal.problemdef.operator.Sinh.Operator;
        end
    end

end
