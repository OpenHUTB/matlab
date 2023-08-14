classdef Uminus<optim.internal.problemdef.UnaryOperator







    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.Uminus();
    end

    properties(Hidden,Constant)
        OperatorStr="-";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        UminusVersion=1;
    end

    methods(Access=private)

        function op=Uminus()
        end
    end

    methods(Access=public)


        function val=evaluate(~,Left,~,~)
            val=-Left;
        end


        function numParens=getOutputParens(~)


            numParens=1;
        end

        function[funStr,numParens]=...
            buildNonlinearStr(~,~,varName,~,numParens,~)
            funStr="(-"+varName+")";
            numParens=numParens+1;
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorUminus(visitor,op,Node);
        end
    end

    methods(Static)

        function op=getUminusOperator(~,~)

            op=optim.internal.problemdef.Uminus.Operator;
        end

    end

end
