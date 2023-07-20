function[outputPortIndices,outputInitValueMax,outputInitValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)%#ok





    blkPath=regexprep(blkObj.getFullName,'\n',' ');

    outputPortIndices=1;
    outputAmplitude=slResolve(blkObj.Amplitude,blkPath);
    outputInitValueMax=abs(outputAmplitude);
    outputInitValueMin=-outputInitValueMax;


