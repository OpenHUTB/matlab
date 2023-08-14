classdef Power<optim.internal.problemdef.operator.PowerOperator






    properties(Hidden,Constant)
        OperatorStr=".^";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)

        PowerVersion=2;
    end

    methods(Access=public)

        function op=Power(obj,b)
            op=op@optim.internal.problemdef.operator.PowerOperator(obj,b);
        end


        function val=evaluate(op,Left,~,evalVisitor)
            val=Left.^getExponent(op,evalVisitor);
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorPower(visitor,op,Node);
        end

    end

end
