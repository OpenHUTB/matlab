classdef Cumprod<optim.internal.problemdef.operator.Cumfcn






    properties(Hidden,Constant)
        OperatorStr="cumprod";
        FileNameJacobian="CumprodJacobian";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        CumprodVersion=1;
    end

    methods(Access=public)

        function op=Cumprod(inSz,varargin)
            op=op@optim.internal.problemdef.operator.Cumfcn(inSz,varargin{:});
        end


        function outType=getOutputType(op,LeftType,~,~)


            if LeftType==optim.internal.problemdef.ImplType.Numeric||...
                prod(op.InputSize)==0
                outType=optim.internal.problemdef.ImplType.Numeric;
            else
                outType=optim.internal.problemdef.ImplType.Nonlinear;
            end
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorCumprod(visitor,op,Node);
        end


        function val=evaluate(op,Left,~,~)
            val=cumprod(Left,op.Dim,op.Direction);
        end

    end
end
