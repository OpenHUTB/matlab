classdef NumericExpressionImpl<optim.internal.problemdef.ExpressionImpl





    properties(Hidden,SetAccess=private,GetAccess=public)
        NumericExpressionImplVersion=1;
    end

    properties(Hidden)
        SupportsAD=true;
    end

    methods

        function obj=NumericExpressionImpl(Value)

            obj=obj@optim.internal.problemdef.ExpressionImpl();

            obj.Value=Value;

            obj.Size=size(Value);
        end

    end


    methods

        function val=getValue(obj,~)
            val=obj.Value;
        end

    end

    methods(Hidden)
        function acceptVisitor(Node,visitor)
            visitNumericExpressionImpl(visitor,Node);
        end
    end

end
