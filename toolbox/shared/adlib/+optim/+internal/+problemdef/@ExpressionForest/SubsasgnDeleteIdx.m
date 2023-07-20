function SubsasgnDeleteIdx(obj,linIdx)













    if obj.SingleTreeSpansAllIndices



        sz=obj.Size;
        newlinIdxloc=true(sz);
        newlinIdxloc(linIdx)=false;

        newIdx=find(newlinIdxloc);
        obj.ForestIndexList{1}=newIdx;
        obj.TreeIndexList{1}=newIdx;
        obj.SingleTreeSpansAllIndices=false;
    else

        nTrees=obj.NumTrees;

        sz=obj.Size;


        forestIndexList=obj.ForestIndexList;
        initializedIdx=false(sz);
        for i=1:nTrees
            initializedIdx(forestIndexList{i})=true;
        end

        if any(initializedIdx(linIdx))
            treeList=obj.TreeList;
            treeIndexList=obj.TreeIndexList;


            rmTree=false(nTrees,1);


            newlinIdxloc=false(sz);
            newlinIdxloc(linIdx)=true;
            for i=1:nTrees



                linIdxInTreei=newlinIdxloc(forestIndexList{i});
                if any(linIdxInTreei)


                    if all(linIdxInTreei)


                        rmTree(i)=true;
                    else


                        forestIndexList{i}(linIdxInTreei)=[];
                        treeIndexList{i}(linIdxInTreei)=[];
                    end
                end


            end



            forestIndexList(rmTree)=[];
            treeList(rmTree)=[];
            treeIndexList(rmTree)=[];


            obj.TreeList=treeList;
            obj.ForestIndexList=forestIndexList;
            obj.TreeIndexList=treeIndexList;
            obj.NumTrees=numel(treeList);
            obj.SingleTreeSpansAllIndices=false;


            if any(rmTree)
                obj.Variables=computeVariables(obj);
            end
        end


    end

end