classdef EndIndexExpressionImpl<optim.internal.problemdef.ExpressionImpl




    properties(Hidden,Access=private,Constant)
        EndIndexImpl=optim.internal.problemdef.EndIndexExpressionImpl();
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        EndIndexExpressionImplVersion=1;
    end

    properties(Hidden)
        SupportsAD=true;
    end

    methods(Access=private)

        function obj=EndIndexExpressionImpl()
            obj=obj@optim.internal.problemdef.ExpressionImpl();
            obj.Size=[1,1];
        end

    end

    methods(Hidden)
        function acceptVisitor(Node,visitor)
            visitEndIndexExpressionImpl(visitor,Node);
        end
    end

    methods(Static)

        function op=getEndIndex()
            op=optim.internal.problemdef.EndIndexExpressionImpl.EndIndexImpl;
        end

    end

end
