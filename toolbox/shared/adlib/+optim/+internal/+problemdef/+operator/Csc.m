classdef Csc<optim.internal.problemdef.operator.NonlinearUnarySingleton






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.Csc();
    end

    properties(Hidden,Constant)
        OperatorStr="csc";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        CscVersion=1;
    end

    methods(Access=private)

        function op=Csc()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,~,~)
            val=csc(Left);
        end
    end

    methods

        function[gradStr,numParens]=getGradientString(~,leftVarName)
            gradStr=".*(-csc("+leftVarName+"(:)).*cot("+leftVarName+"(:)))";
            numParens=5;
        end
    end

    methods(Static)
        function op=getCscOperator(~,~)
            op=optim.internal.problemdef.operator.Csc.Operator;
        end
    end

end
