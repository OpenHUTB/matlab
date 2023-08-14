classdef NonlinearExpressionImpl<optim.internal.problemdef.ExpressionImpl




    properties(Hidden=true)

FunctionImpl

OutputIndex
    end

    properties(Hidden)
        SupportsAD=false;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        NonlinearExpressionImplVersion=1;
    end

    methods


        function obj=NonlinearExpressionImpl(func,sz,idx)

            obj=obj@optim.internal.problemdef.ExpressionImpl();
            obj.FunctionImpl=func;
            obj.OutputIndex=idx;
            obj.Size=sz;
        end

    end

    methods(Hidden)
        function acceptVisitor(Node,visitor)
            visitNonlinearExpressionImpl(visitor,Node);
        end
    end

end
