function[issqrt,c,a]=createExprIfSqrt(obj,expr)

























    if expr.SingleTreeSpansAllIndices

        [issqrt,tree,c,a]=createExprIfSqrt(expr.TreeList{1});


        if issqrt
            tree2forest(obj,tree);
        end
    else


        nTrees=expr.NumTrees;
        treeList=expr.TreeList;
        forestIndexList=expr.ForestIndexList;
        sz=size(expr);


        issqrt=true;
        c=zeros(sz);
        a=ones(sz);
        newTreeList=cell(nTrees,1);


        for i=1:nTrees

            treei=treeList{i};



            forestIndex=forestIndexList{i};


            [isTreesqrt,newTreeList{i},c(forestIndex),a(forestIndex)]=createExprIfSqrt(treei);

            if~isTreesqrt
                issqrt=false;
                c=0;
                a=1;
                return;
            end
        end


        obj.TreeList=newTreeList;
        obj.ForestIndexList=expr.ForestIndexList;
        obj.TreeIndexList=expr.TreeIndexList;
        obj.NumTrees=expr.NumTrees;
        obj.Size=expr.Size;
        obj.SingleTreeSpansAllIndices=expr.SingleTreeSpansAllIndices;
        obj.Variables=expr.Variables;
    end

end