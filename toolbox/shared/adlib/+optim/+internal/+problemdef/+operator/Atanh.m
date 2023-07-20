classdef Atanh<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Atanh();
    end

    properties(Hidden,Constant)
        OperatorStr="atanh";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AtanhVersion=1;
    end

    methods(Access=private)

        function op=Atanh()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=atanh(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(1-"+leftVarName+"(:).^2)";
            numParens=2;
        end
    end

    methods(Static)
        function op=getAtanhOperator(~,~)
            op=optim.internal.problemdef.operator.Atanh.Operator;
        end
    end

end
