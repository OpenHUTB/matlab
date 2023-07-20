classdef Asin<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Asin();
    end

    properties(Hidden,Constant)
        OperatorStr="asin";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AsinVersion=1;
    end

    methods(Access=private)

        function op=Asin()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=asin(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./sqrt(1-"+leftVarName+"(:).^2)";
            numParens=2;
        end
    end

    methods(Static)
        function op=getAsinOperator(~,~)
            op=optim.internal.problemdef.operator.Asin.Operator;
        end
    end

end
