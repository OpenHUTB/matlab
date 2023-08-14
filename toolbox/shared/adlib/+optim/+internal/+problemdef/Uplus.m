classdef Uplus<optim.internal.problemdef.UnaryOperator







    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.Uplus();
    end

    properties(Hidden,Constant)
        OperatorStr="+";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        UplusVersion=1;
    end

    methods(Access=private)

        function op=Uplus()
        end
    end

    methods(Access=public)


        function Left=evaluate(~,Left,~,~)

        end


        function numParens=getOutputParens(~)
            numParens=0;
        end

        function[funStr,numParens]=...
            buildNonlinearStr(~,~,varName,~,numParens,~)
            funStr=varName;
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorUplus(visitor,op,Node);
        end
    end

    methods(Static)

        function op=getUplusOperator(~,~)

            op=optim.internal.problemdef.Uplus.Operator;
        end

    end

end
