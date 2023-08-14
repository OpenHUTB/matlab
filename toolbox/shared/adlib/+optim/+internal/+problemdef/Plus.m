classdef Plus<optim.internal.problemdef.ElementwiseOperator






    properties(Hidden,Constant)
        OperatorStr="+";
    end

    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.Plus();
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        PlusVersion=1;
    end

    methods(Access=private)

        function op=Plus()
        end
    end

    methods(Access=public)

        function acceptVisitor(Op,visitor,Node)
            visitOperatorPlus(visitor,Op,Node);
        end


        function val=evaluate(~,Left,Right,~)
            val=Left+Right;
        end


        function outType=getOutputType(~,LeftType,RightType,~)
            outType=optim.internal.problemdef.ImplType.typePlusMinus(LeftType,RightType);
        end
    end

    methods(Static)

        function op=getPlusOperator(Left,Right)
            optim.internal.problemdef.ElementwiseOperator.checkIsValid(Left,Right);
            op=optim.internal.problemdef.Plus.Operator;
        end

        function op=getPlusOperatorNoCheck()
            op=optim.internal.problemdef.Plus.Operator;
        end

    end

end
