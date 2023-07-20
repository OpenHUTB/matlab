classdef(Sealed)LHSExpressionImpl<optim.internal.problemdef.ExpressionImpl





    properties(Hidden,Access=public)
SupportsAD


        Name="";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        LHSExpressionImplVersion=1;
    end

    methods

        function obj=LHSExpressionImpl(lhsName)


            obj=obj@optim.internal.problemdef.ExpressionImpl();


            obj.Name=lhsName;
            obj.Size=[0,0];
            obj.SupportsAD=true;
        end

    end

    methods(Hidden)


        function acceptVisitor(Node,visitor)
            visitLHSExpressionImpl(visitor,Node);
        end

    end

end
