classdef BinaryExpressionImpl<optim.internal.problemdef.ExpressionImpl




    properties



Operator

        SupportsAD;
    end

    properties

ExprLeft

ExprRight
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        BinaryExpressionImplVersion=3;
    end

    methods


        function obj=BinaryExpressionImpl(operator,obj1,obj2,skip)

            if nargin<4
                skip=false;
            end


            obj.ExprLeft=obj1;
            obj.ExprRight=obj2;
            obj.Operator=operator;

            if~skip


                obj.SupportsAD=supportsAD(operator)&&...
                obj1.SupportsAD&&obj2.SupportsAD;


                obj.Size=getOutputSize(operator,size(obj1),size(obj2));
            end
        end

    end

    methods(Hidden)
        function acceptVisitor(Node,visitor)
            visitBinaryExpressionImpl(visitor,Node);
        end
    end




































    methods(Static)
        function obj=loadobj(obj)


            if obj.BinaryExpressionImplVersion<2
                [obj,isSubsasgn]=reloadv1tov2(obj);




                if isSubsasgn
                    return
                end
            end


            if obj.BinaryExpressionImplVersion<3
                obj=reloadv2tov3(obj);
            end


            obj.BinaryExpressionImplVersion=3;

        end
    end

    methods(Hidden)
        [newNode,isSubsasgn]=reloadv1tov2(obj);
        newNode=reloadv2tov3(obj);
    end

end
