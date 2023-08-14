classdef Cumsum<optim.internal.problemdef.operator.Cumfcn






    properties(Hidden,Constant)
        OperatorStr="cumsum";
        FileNameJacobian="CumsumJacobian";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        CumsumVersion=1;
    end

    methods(Access=public)

        function op=Cumsum(inSz,varargin)
            op=op@optim.internal.problemdef.operator.Cumfcn(inSz,varargin{:});
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorCumsum(visitor,op,Node);
        end


        function val=evaluate(op,Left,~,~)
            val=cumsum(Left,op.Dim,op.Direction);
        end

    end

end
