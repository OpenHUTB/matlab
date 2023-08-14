classdef Acsc<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Acsc();
    end

    properties(Hidden,Constant)
        OperatorStr="acsc";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AcscVersion=1;
    end

    methods(Access=private)

        function op=Acsc()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=acsc(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(-abs("+leftVarName+"(:)).*sqrt("+leftVarName+"(:).^2 - 1))";
            numParens=5;
        end
    end

    methods(Static)
        function op=getAcscOperator(~,~)
            op=optim.internal.problemdef.operator.Acsc.Operator;
        end
    end

end
