

function origBlockPath=i_convertRedBlockNameToOrig(blockPath,redmodelNameModelNameMap)



    origBlockPath=blockPath;
    [modelName,restOfBlkPath]=strtok(blockPath,'/');
    if redmodelNameModelNameMap.isKey(modelName)
        origBlockPath=[redmodelNameModelNameMap(modelName),restOfBlkPath];
    end
end
