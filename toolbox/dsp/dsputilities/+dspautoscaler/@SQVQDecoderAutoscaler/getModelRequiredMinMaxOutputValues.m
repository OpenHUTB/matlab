function[outputPortIndices,outputInitValueMax,outputInitValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)%#ok






    if strcmp(blkObj.CBsource,'Specify via dialog')
        blkPath=regexprep(blkObj.getFullName,'\n',' ');
        codebookVals=slResolve(blkObj.codebook,blkPath);
        allCBValsVct=codebookVals(:);
        outputPortIndices=1;
        outputInitValueMax=max(allCBValsVct);
        outputInitValueMin=min(allCBValsVct);
    else

        outputPortIndices=[];
        outputInitValueMax=[];
        outputInitValueMin=[];
    end
