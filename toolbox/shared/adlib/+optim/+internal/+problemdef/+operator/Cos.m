classdef Cos<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Cos();
    end

    properties(Hidden,Constant)
        OperatorStr="cos";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        CosVersion=1;
    end

    methods(Access=private)

        function op=Cos()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=cos(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*sin(-"+leftVarName+"(:))";
            numParens=2;
        end
    end

    methods(Static)
        function op=getCosOperator(~,~)
            op=optim.internal.problemdef.operator.Cos.Operator;
        end
    end

end
