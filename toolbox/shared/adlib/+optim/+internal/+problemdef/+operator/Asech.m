classdef Asech<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Asech();
    end

    properties(Hidden,Constant)
        OperatorStr="asech";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AsechVersion=1;
    end

    methods(Access=private)

        function op=Asech()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=asech(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(-"+leftVarName+"(:).*sqrt(1 - "+leftVarName+"(:).^2))";
            numParens=4;
        end
    end

    methods(Static)
        function op=getAsechOperator(~,~)
            op=optim.internal.problemdef.operator.Asech.Operator;
        end
    end

end
