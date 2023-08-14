classdef Acsch<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Acsch();
    end

    properties(Hidden,Constant)
        OperatorStr="acsch";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AcschVersion=1;
    end

    methods(Access=private)

        function op=Acsch()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=acsch(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(-abs("+leftVarName+"(:)).*sqrt("+leftVarName+"(:).^2 + 1))";
            numParens=5;
        end
    end

    methods(Static)
        function op=getAcschOperator(~,~)
            op=optim.internal.problemdef.operator.Acsch.Operator;
        end
    end

end
