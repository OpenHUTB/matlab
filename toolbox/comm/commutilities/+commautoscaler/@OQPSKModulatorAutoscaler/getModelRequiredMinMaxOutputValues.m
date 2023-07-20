function[outputPortIndex,outputValueMax,outputValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)%#ok





    blkPath=regexprep(blkObj.getFullName,'\n',' ');

    M=4;
    Ph=slResolve(blkObj.Ph,blkPath);



    u=0:(M-1);
    y=pskmod(u,M,Ph,'Bin');


    reY=real(y);
    imY=imag(y);
    reYmin=min(reY);
    imYmin=min(imY);
    reYmax=max(reY);
    imYmax=max(imY);

    outputPortIndex=1;
    outputValueMin=min(reYmin,imYmin);
    outputValueMax=max(reYmax,imYmax);


