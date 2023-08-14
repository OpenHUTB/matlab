classdef Sech<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Sech();
    end

    properties(Hidden,Constant)
        OperatorStr="sech";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        SechVersion=1;
    end

    methods(Access=private)

        function op=Sech()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=sech(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*(-sech("+leftVarName+"(:)).*tanh("+leftVarName+"(:)))";
            numParens=5;
        end
    end

    methods(Static)
        function op=getSechOperator(~,~)
            op=optim.internal.problemdef.operator.Sech.Operator;
        end
    end

end
