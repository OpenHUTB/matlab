classdef Coth<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Coth();
    end

    properties(Hidden,Constant)
        OperatorStr="coth";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        CothVersion=1;
    end

    methods(Access=private)

        function op=Coth()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=coth(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*(-csch("+leftVarName+"(:)).^2)";
            numParens=3;
        end
    end

    methods(Static)
        function op=getCothOperator(~,~)
            op=optim.internal.problemdef.operator.Coth.Operator;
        end
    end

end
