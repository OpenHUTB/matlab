classdef Acosh<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Acosh();
    end

    properties(Hidden,Constant)
        OperatorStr="acosh";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AcoshVersion=1;
    end

    methods(Access=private)

        function op=Acosh()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=acosh(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./sqrt("+leftVarName+"(:).^2 - 1)";
            numParens=2;
        end
    end

    methods(Static)
        function op=getAcoshOperator(~,~)
            op=optim.internal.problemdef.operator.Acosh.Operator;
        end
    end

end
