function createReshape(obj,expr,outSize)











    copy(obj,expr);
    obj.Size=outSize;



    if obj.SingleTreeSpansAllIndices&&~isequal(obj.Size,obj.TreeList{1}.Size)
        obj.ForestIndexList={1:numel(obj)};
        obj.TreeIndexList=obj.ForestIndexList;
        obj.SingleTreeSpansAllIndices=false;
    end