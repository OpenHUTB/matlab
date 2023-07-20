function doS=doSubsasgn(numTrees,forestIndexList,forestSize)







    if numTrees>1

        doS=true;
    elseif numTrees==0


        doS=false;
    else




        forestIndex=forestIndexList{1};
        doS=~isequal(forestIndex(:)',1:prod(forestSize));
    end
end
