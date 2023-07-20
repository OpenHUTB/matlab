classdef SubsasgnExpressionImpl<optim.internal.problemdef.ExpressionImpl












































    properties(Hidden,Access=public)

RootList


ForestIndexList

TreeIndexList

NumTrees
SupportsAD
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        SubsasgnExpressionImplVersion=2;
    end

    methods


        function obj=SubsasgnExpressionImpl(sz,linIdx,expr,localIdx)

            obj.Size=sz;
            obj.ForestIndexList=linIdx;
            obj.RootList=expr;
            obj.TreeIndexList=localIdx;
            obj.NumTrees=numel(expr);



            obj.SupportsAD=all(cellfun(@(x)x.SupportsAD,expr));

        end

    end

    methods(Hidden)
        function acceptVisitor(Node,visitor)
            visitSubsasgnExpressionImpl(visitor,Node);
        end
    end

    methods(Static)

        function obj=loadobj(obj)


            if obj.SubsasgnExpressionImplVersion<2



                obj.SupportsAD=all(cellfun(@(x)x.SupportsAD,...
                obj.RootList));

            end


            obj.SubsasgnExpressionImplVersion=2;

        end

    end

end
