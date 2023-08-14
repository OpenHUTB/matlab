classdef Asec<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Asec();
    end

    properties(Hidden,Constant)
        OperatorStr="asec";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AsecVersion=1;
    end

    methods(Access=private)

        function op=Asec()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=asec(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(abs("+leftVarName+"(:)).*sqrt("+leftVarName+"(:).^2 - 1))";
            numParens=5;
        end
    end

    methods(Static)
        function op=getAsecOperator(~,~)
            op=optim.internal.problemdef.operator.Asec.Operator;
        end
    end

end
