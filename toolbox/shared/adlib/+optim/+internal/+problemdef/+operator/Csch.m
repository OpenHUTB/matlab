classdef Csch<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Csch();
    end

    properties(Hidden,Constant)
        OperatorStr="csch";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        CschVersion=1;
    end

    methods(Access=private)

        function op=Csch()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=csch(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*(-csch("+leftVarName+"(:)).*coth("+leftVarName+"(:)))";
            numParens=5;
        end
    end

    methods(Static)
        function op=getCschOperator(~,~)
            op=optim.internal.problemdef.operator.Csch.Operator;
        end
    end

end
