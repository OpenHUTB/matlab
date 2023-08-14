

function highlightParameterInModel(model,blockHandleStr)
    blockHandle=str2double(blockHandleStr);
    fullBlockPath=getfullname(blockHandle);
    utils.highlightParameterInModel(model,fullBlockPath);
end