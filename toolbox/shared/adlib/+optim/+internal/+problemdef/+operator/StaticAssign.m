classdef StaticAssign<optim.internal.problemdef.Operator




    properties(Hidden,Access=private,Constant)
        Operator=optim.internal.problemdef.operator.StaticAssign();
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        StaticAssignVersion=1;
    end

    properties(Hidden,Constant)
        OperatorStr="=";
    end

    methods(Access=private)

        function op=StaticAssign()
        end
    end

    methods


        function outSize=getOutputSize(~,~,RHSSize,~)
            outSize=RHSSize;
        end


        function RightType=getOutputType(~,~,RightType,~)
        end


        function RightVal=evaluate(~,~,RightVal,~)
        end


        function acceptVisitor(op,visitor,Node)
            visitOperatorStaticAssign(visitor,op,Node);
        end

    end

    methods(Access=protected)

        function ok=checkIsValid(~,~,~)
            ok=true;
        end
    end

    methods(Static)
        function op=getOperator()

            op=optim.internal.problemdef.operator.StaticAssign.Operator;
        end
    end
end

