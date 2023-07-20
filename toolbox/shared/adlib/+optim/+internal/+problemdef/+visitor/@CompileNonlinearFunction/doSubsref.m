function doS=doSubsref(treeIndex,treeSize)







    if isequal(treeIndex(:)',1:prod(treeSize))


        doS=false;
    else

        doS=true;
    end

end