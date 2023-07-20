classdef Minus<optim.internal.problemdef.ElementwiseOperator






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.Minus();
    end

    properties(Hidden,Constant)
        OperatorStr="-";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        MinusVersion=1;
    end

    methods(Access=private)

        function op=Minus()
        end
    end

    methods(Access=public)

        function acceptVisitor(Op,visitor,Node)
            visitOperatorMinus(visitor,Op,Node);
        end


        function val=evaluate(~,Left,Right,~)
            val=Left-Right;
        end


        function outType=getOutputType(~,LeftType,RightType,~)
            outType=optim.internal.problemdef.ImplType.typePlusMinus(LeftType,RightType);
        end
    end

    methods(Static)

        function op=getMinusOperator(Left,Right)
            optim.internal.problemdef.ElementwiseOperator.checkIsValid(Left,Right);
            op=optim.internal.problemdef.Minus.Operator;
        end

        function op=getMinusOperatorNoCheck()
            op=optim.internal.problemdef.Minus.Operator;
        end

    end

end
