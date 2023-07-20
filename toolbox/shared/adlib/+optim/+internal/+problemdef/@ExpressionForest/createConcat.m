function createConcat(obj,ExprList,dim,outSize)













    numTrees=sum(cellfun(@(forest)forest.NumTrees,ExprList));

    treeList=cell(1,numTrees);
    forestIndexList=cell(1,numTrees);
    treeIndexList=cell(1,numTrees);


    nDims=numel(outSize);
    reorder=dim<nDims;


    totalShift=0;

    curTree=1;

    vars=struct;

    if reorder





        firstProd=prod(outSize(1:dim-1));
        lastProd=prod(outSize(dim+1:end));

        shiftSize=[ones(1,dim),outSize(dim+1:end)];

        for i=1:numel(ExprList)

            forest=ExprList{i};

            forestSize=size(forest);

            forestSize=[forestSize,ones(1,dim-numel(forestSize))];%#ok<AGROW>

            curTreeList=forest.TreeList;



            newLinIdx=totalShift+...
            optim.internal.problemdef.indexing.computeShiftedIdx(forestSize,outSize,dim,firstProd,lastProd,shiftSize);

            if forest.SingleTreeSpansAllIndices


                treeList{curTree}=curTreeList{1};
                treeIdx=1:numel(forest);
                treeIndexList{curTree}=treeIdx;
                forestIndexList{curTree}=newLinIdx(:);
                curTree=curTree+1;

            else

                curNumTrees=forest.NumTrees;

                curTreeIndexList=forest.TreeIndexList;

                curForestIndexList=forest.ForestIndexList;

                for j=1:curNumTrees
                    treeList{curTree}=curTreeList{j};
                    treeIndexList{curTree}=curTreeIndexList{j};
                    forestIndexList{curTree}=newLinIdx(curForestIndexList{j});
                    curTree=curTree+1;
                end
            end


            totalShift=totalShift+prod(forestSize(1:dim));

            vars=optim.internal.problemdef.HashMapFunctions.union(...
            vars,forest.Variables,'OptimizationExpression');
        end

    else



        for i=1:numel(ExprList)

            forest=ExprList{i};

            forestSize=size(forest);

            forestSize=[forestSize,ones(1,dim-numel(forestSize))];%#ok<AGROW>

            curTreeList=forest.TreeList;

            if forest.SingleTreeSpansAllIndices

                treeList{curTree}=curTreeList{1};
                treeIdx=1:numel(forest);
                treeIndexList{curTree}=treeIdx;
                forestIndexList{curTree}=totalShift+treeIdx;
                curTree=curTree+1;

            else

                curNumTrees=forest.NumTrees;

                curTreeIndexList=forest.TreeIndexList;

                curForestIndexList=forest.ForestIndexList;
                for j=1:curNumTrees
                    treeList{curTree}=curTreeList{j};
                    treeIndexList{curTree}=curTreeIndexList{j};
                    forestIndexList{curTree}=totalShift+curForestIndexList{j};
                    curTree=curTree+1;
                end
            end


            totalShift=totalShift+prod(forestSize(1:dim));

            vars=optim.internal.problemdef.HashMapFunctions.union(...
            vars,forest.Variables,'OptimizationExpression');
        end

    end

    obj.TreeList=treeList;
    obj.ForestIndexList=forestIndexList;
    obj.TreeIndexList=treeIndexList;
    obj.NumTrees=numTrees;
    obj.SingleTreeSpansAllIndices=false;
    obj.Size=outSize;
    obj.Variables=vars;
