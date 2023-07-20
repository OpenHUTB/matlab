classdef Times<optim.internal.problemdef.ElementwiseOperator







    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.Times();
    end

    properties(Hidden,Constant)
        OperatorStr=".*";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        TimesVersion=1;
    end

    methods(Access=private)

        function op=Times()
        end
    end

    methods(Access=public)


        function val=evaluate(~,Left,Right,~)
            val=Left.*Right;
        end


        function outType=getOutputType(~,LeftType,RightType,~)
            outType=optim.internal.problemdef.ImplType.typeTimes(LeftType,RightType);
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorTimes(visitor,op,Node);
        end






















































































































































    end


    methods(Access=protected,Static)


        function ok=checkIsValid(Left,Right)

            ok=checkIsValid@optim.internal.problemdef.ElementwiseOperator(Left,Right);
        end
    end

    methods(Static)

        function op=getTimesOperator(Left,Right)
            optim.internal.problemdef.Times.checkIsValid(Left,Right);
            op=optim.internal.problemdef.Times.Operator;
        end

        function op=getTimesOperatorNoCheck()
            op=optim.internal.problemdef.Times.Operator;
        end

    end
end
