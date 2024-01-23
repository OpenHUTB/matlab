function[outputPortIndex,outputValueMax,outputValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)%#ok

    blkPath=regexprep(blkObj.getFullName,'\n',' ');

    y=slResolve(blkObj.SigCon,blkPath);

    reY=real(y);
    imY=imag(y);
    reYmin=min(reY);
    imYmin=min(imY);
    reYmax=max(reY);
    imYmax=max(imY);

    outputPortIndex=1;
    outputValueMin=min(reYmin,imYmin);
    outputValueMax=max(reYmax,imYmax);


