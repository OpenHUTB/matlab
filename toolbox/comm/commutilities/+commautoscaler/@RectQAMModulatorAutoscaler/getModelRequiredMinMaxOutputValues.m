function[outputPortIndex,outputValueMax,outputValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)%#ok





    blkPath=regexprep(blkObj.getFullName,'\n',' ');

    M=slResolve(blkObj.M,blkPath);
    Ph=slResolve(blkObj.Ph,blkPath);
    PowType=blkObj.PowType;


    switch PowType
    case 'Average Power'
        AvgPowVal=slResolve(blkObj.AvgPow,blkPath);
        g=0.5*sqrt((6*AvgPowVal)/(M-1));

    case 'Peak Power'
        PeakPowVal=slResolve(blkObj.PeakPow,blkPath);
        g=sqrt(PeakPowVal/2)/(sqrt(M)-1);

    otherwise

        MinDistVal=slResolve(blkObj.MinDist,blkPath);
        g=0.5*MinDistVal;
    end


    u=0:(M-1);
    y=g.*exp(1i*Ph).*qammod(u,M,'Bin');


    reY=real(y);
    imY=imag(y);
    reYmin=min(reY);
    imYmin=min(imY);
    reYmax=max(reY);
    imYmax=max(imY);

    outputPortIndex=1;
    outputValueMin=min(reYmin,imYmin);
    outputValueMax=max(reYmax,imYmax);


