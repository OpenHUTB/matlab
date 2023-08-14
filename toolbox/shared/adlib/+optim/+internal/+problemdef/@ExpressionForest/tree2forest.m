function tree2forest(obj,tree)









    obj.TreeList={tree};
    obj.ForestIndexList={};
    obj.TreeIndexList={};
    obj.NumTrees=1;
    obj.Size=tree.Size;
    obj.SingleTreeSpansAllIndices=true;
    obj.Variables=tree.Variables;

end
