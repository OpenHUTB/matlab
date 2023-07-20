classdef Acoth<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Acoth();
    end

    properties(Hidden,Constant)
        OperatorStr="acoth";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        AcothVersion=1;
    end

    methods(Access=private)

        function op=Acoth()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=acoth(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr="./(1 - "+leftVarName+"(:).^2)";
            numParens=2;
        end
    end

    methods(Static)
        function op=getAcothOperator(~,~)
            op=optim.internal.problemdef.operator.Acoth.Operator;
        end
    end

end
