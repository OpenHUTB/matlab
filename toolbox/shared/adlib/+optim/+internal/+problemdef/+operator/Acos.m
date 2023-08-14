classdef Acos<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Acos();
    end

    properties(Hidden,Constant)
        OperatorStr="acos";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AcosVersion=1;
    end

    methods(Access=private)

        function op=Acos()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=acos(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(-sqrt(1-"+leftVarName+"(:).^2))";
            numParens=3;
        end
    end

    methods(Static)
        function op=getAcosOperator(~,~)
            op=optim.internal.problemdef.operator.Acos.Operator;
        end
    end

end
