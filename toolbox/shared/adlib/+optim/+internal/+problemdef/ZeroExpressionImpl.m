classdef(Sealed)ZeroExpressionImpl<optim.internal.problemdef.ExpressionImpl









    properties(Hidden,SetAccess=private,GetAccess=public)
        ZeroExpressionImplVersion=1;
    end

    properties(Hidden)
        SupportsAD=true;
    end

    methods

        function obj=ZeroExpressionImpl(sz)

            obj=obj@optim.internal.problemdef.ExpressionImpl();
            obj.Size=sz;
        end


    end

    methods(Hidden)
        function acceptVisitor(Node,visitor)
            visitZeroExpressionImpl(visitor,Node);
        end
    end

    methods(Static)
        function[funStr,numParens]=getNonlinearStr(sz)
            if all(sz==1)
                funStr="0";
                numParens=0;
            else
                funStr="zeros("+strjoin(string(sz),', ')+")";
                numParens=2;
            end
        end
        function[funStr,numParens]=getNonlinearSparseStr(sz)
            funStr="sparse("+strjoin(string(sz),', ')+")";
            numParens=1;
        end
    end
end
