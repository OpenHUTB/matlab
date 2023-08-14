function modelName=getTopLevelModelName(blockPath)






    pathStrs=regexp(blockPath,'\/','split');
    modelName=pathStrs{1};

end

