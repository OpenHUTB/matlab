classdef Acot<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Acot();
    end

    properties(Hidden,Constant)
        OperatorStr="acot";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AcotVersion=1;
    end

    methods(Access=private)

        function op=Acot()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=acot(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(-("+leftVarName+"(:).^2 + 1))";
            numParens=3;
        end

    end

    methods(Static)
        function op=getAcotOperator(~,~)
            op=optim.internal.problemdef.operator.Acot.Operator;
        end
    end

end
