classdef Sec<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Sec();
    end

    properties(Hidden,Constant)
        OperatorStr="sec";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        SecVersion=1;
    end

    methods(Access=private)

        function op=Sec()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=sec(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*(sec("+leftVarName+"(:)).*tan("+leftVarName+"(:)))";
            numParens=5;
        end
    end

    methods(Static)
        function op=getSecOperator(~,~)
            op=optim.internal.problemdef.operator.Sec.Operator;
        end
    end

end
