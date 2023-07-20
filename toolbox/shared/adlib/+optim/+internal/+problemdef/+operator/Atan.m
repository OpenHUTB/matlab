classdef Atan<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Atan();
    end

    properties(Hidden,Constant)
        OperatorStr="atan";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AtanVersion=1;
    end

    methods(Access=private)

        function op=Atan()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=atan(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(1+"+leftVarName+"(:).^2)";
            numParens=2;
        end
    end

    methods(Static)
        function op=getAtanOperator(~,~)
            op=optim.internal.problemdef.operator.Atan.Operator;
        end
    end

end
