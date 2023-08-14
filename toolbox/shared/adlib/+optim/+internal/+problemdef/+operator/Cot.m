classdef Cot<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Cot();
    end

    properties(Hidden,Constant)
        OperatorStr="cot";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        CotVersion=1;
    end

    methods(Access=private)

        function op=Cot()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=cot(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*(-csc("+leftVarName+"(:)).^2)";
            numParens=3;
        end
    end

    methods(Static)
        function op=getCotOperator(~,~)
            op=optim.internal.problemdef.operator.Cot.Operator;
        end
    end

end
