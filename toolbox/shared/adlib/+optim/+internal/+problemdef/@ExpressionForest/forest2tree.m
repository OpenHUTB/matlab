function tree=forest2tree(obj)











    if obj.SingleTreeSpansAllIndices

        tree=obj.TreeList{1};
    else
        nTrees=obj.NumTrees;

        tree=optim.internal.problemdef.ExpressionTree;
        if nTrees==0



            createZeros(tree,obj.Size);
        else

            createSubsasgn(tree,obj.Size,obj.ForestIndexList,obj.TreeList,...
            obj.TreeIndexList,obj.Variables);
        end
    end

end
