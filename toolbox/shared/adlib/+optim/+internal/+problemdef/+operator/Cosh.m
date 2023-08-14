classdef Cosh<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Cosh();
    end

    properties(Hidden,Constant)
        OperatorStr="cosh";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        CoshVersion=1;
    end

    methods(Access=private)

        function op=Cosh()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=cosh(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*sinh("+leftVarName+"(:))";
            numParens=2;
        end
    end

    methods(Static)
        function op=getCoshOperator(~,~)
            op=optim.internal.problemdef.operator.Cosh.Operator;
        end
    end

end
