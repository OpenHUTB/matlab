function[iss,c,idx]=createExprIfSumSquares(obj,expr)






































    if expr.SingleTreeSpansAllIndices


        tree=expr.TreeList{1};

        if numel(tree)>1
            iss=false;
            c=0;
            idx={};
            return;
        end


        [iss,tree,c]=createExprIfSumSquares(tree);
        idx={1:numel(tree)};


        if iss
            tree2forest(obj,tree);
        end
    else


        nTrees=expr.NumTrees;
        treeList=expr.TreeList;
        forestIndexList=expr.ForestIndexList;
        sz=size(expr);


        iss=true;
        c=zeros(sz);
        newTreeList=cell(nTrees,1);
        newForestIndexList=cell(nTrees,1);
        newTreeIndexList=cell(nTrees,1);
        nElem=0;


        for i=1:nTrees

            treei=treeList{i};


            if numel(treei)>1
                iss=false;
                c=0;
                idx={};
                return;
            end



            forestIndex=forestIndexList{i};


            [isTreeSS,newTreeList{i},c(forestIndex)]=createExprIfSumSquares(treei);

            if~isTreeSS
                iss=false;
                c=0;
                idx={};
                return;
            end

            nElemTreei=numel(newTreeList{i});

            nElemPrev=nElem;
            nElem=nElem+nElemTreei;

            newTreeIndexList{i}=1:nElemTreei;

            newForestIndexList{i}=(1:nElemTreei)+nElemPrev;
        end


        obj.TreeList=newTreeList;
        obj.ForestIndexList=newForestIndexList;
        obj.TreeIndexList=newTreeIndexList;
        obj.NumTrees=expr.NumTrees;
        obj.Size=[nElem,1];
        obj.SingleTreeSpansAllIndices=expr.SingleTreeSpansAllIndices;
        obj.Variables=expr.Variables;
        idx=newForestIndexList;
    end

end
