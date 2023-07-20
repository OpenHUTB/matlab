classdef Rdivide<optim.internal.problemdef.ElementwiseOperator






    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.Rdivide();
    end

    properties(Hidden,Constant)
        OperatorStr="./";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        RdivideVersion=1;
    end

    methods(Access=private)

        function op=Rdivide()
        end
    end

    methods(Access=public)


        function val=evaluate(~,Left,Right,~)
            val=Left./Right;
        end


        function outType=getOutputType(~,LeftType,RightType,~)
            outType=optim.internal.problemdef.ImplType.typeDivide(LeftType,RightType);
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorRdivide(visitor,op,Node);
        end

    end


    methods(Access=protected,Static)


        function ok=checkIsValid(Left,Right)

            if(getExprType(Right)==optim.internal.problemdef.ImplType.Numeric)
                evalVisitor=optim.internal.problemdef.visitor.StaticEvaluate;
                acceptVisitor(getExprImpl(Right),evalVisitor);
                RightVal=getValue(evalVisitor);
                if any(~RightVal(:))
                    throwAsCaller(MException(message('shared_adlib:operators:DivideByZero')));
                end
            end

            ok=checkIsValid@optim.internal.problemdef.ElementwiseOperator(Left,Right);
        end
    end

    methods(Static)

        function op=getRdivideOperator(Left,Right)
            optim.internal.problemdef.Rdivide.checkIsValid(Left,Right);
            op=optim.internal.problemdef.Rdivide.Operator;
        end

    end

end
