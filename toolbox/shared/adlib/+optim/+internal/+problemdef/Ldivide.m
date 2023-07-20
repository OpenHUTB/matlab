classdef Ldivide<optim.internal.problemdef.ElementwiseOperator






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.Ldivide();
    end

    properties(Hidden,Constant)
        OperatorStr=".\";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        LdivideVersion=1;
    end

    methods(Access=private)

        function op=Ldivide()
        end
    end

    methods(Access=public)

        function val=evaluate(~,Left,Right,~)
            val=Left.\Right;
        end


        function outType=getOutputType(~,LeftType,RightType,~)
            outType=optim.internal.problemdef.ImplType.typeDivide(RightType,LeftType);
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorLdivide(visitor,op,Node);
        end

    end

    methods(Access=protected,Static)


        function ok=checkIsValid(Left,Right)

            if getExprType(Left)==optim.internal.problemdef.ImplType.Numeric
                evalVisitor=optim.internal.problemdef.visitor.StaticEvaluate;
                acceptVisitor(getExprImpl(Left),evalVisitor);
                LeftVal=getValue(evalVisitor);
                if any(~LeftVal(:))
                    throwAsCaller(MException(message('shared_adlib:operators:DivideByZero')));
                end
            end

            ok=checkIsValid@optim.internal.problemdef.ElementwiseOperator(Left,Right);
        end
    end

    methods(Static)

        function op=getLdivideOperator(Left,Right)
            optim.internal.problemdef.Ldivide.checkIsValid(Left,Right);
            op=optim.internal.problemdef.Ldivide.Operator;
        end

    end

end
