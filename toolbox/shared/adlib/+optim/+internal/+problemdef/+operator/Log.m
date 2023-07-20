classdef Log<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Log();
    end

    properties(Hidden,Constant)
        OperatorStr="log";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        LogVersion=1;
    end

    methods(Access=private)

        function op=Log()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=log(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./"+leftVarName+"(:)";
            numParens=1;
        end
    end

    methods(Static)

        function op=getLogOperator(~,~)

            op=optim.internal.problemdef.operator.Log.Operator;
        end

    end

end
