classdef UnaryExpressionImpl<optim.internal.problemdef.ExpressionImpl




    properties



Operator

        SupportsAD;
    end

    properties

ExprLeft
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        UnaryExpressionImplVersion=3;
    end

    methods


        function obj=UnaryExpressionImpl(operator,obj1)


            obj.Operator=operator;
            obj.ExprLeft=obj1;



            obj.SupportsAD=supportsAD(operator)&&obj1.SupportsAD;


            obj.Size=getOutputSize(operator,size(obj1),[]);

        end

    end

    methods(Hidden)
        function acceptVisitor(Node,visitor)
            visitUnaryExpressionImpl(visitor,Node);
        end
    end

    methods(Static)

        function obj=loadobj(obj)


            if obj.UnaryExpressionImplVersion<2
                [obj,isSubsasgn]=reloadv1tov2(obj);




                if isSubsasgn
                    return
                end
            end


            if obj.UnaryExpressionImplVersion<3
                obj=reloadv2tov3(obj);
            end


            obj.UnaryExpressionImplVersion=3;

        end

    end

    methods(Hidden)
        [newNode,isSubsasgn]=reloadv1tov2(obj);
        newNode=reloadv2tov3(obj);
    end

end
