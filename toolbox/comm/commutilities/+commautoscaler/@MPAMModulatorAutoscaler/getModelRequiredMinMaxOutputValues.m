function[outputPortIndex,outputValueMax,outputValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)%#ok





    blkPath=regexprep(blkObj.getFullName,'\n',' ');

    M=slResolve(blkObj.M,blkPath);


    switch blkObj.PowType
    case 'Average Power'
        AvgPowVal=slResolve(blkObj.AvgPow,blkPath);
        minDist=sqrt(2*(6/(M*M-1))*AvgPowVal);

    case 'Peak Power'
        PeakPowVal=slResolve(blkObj.PeakPow,blkPath);
        minDist=2*sqrt(PeakPowVal)/(M-1);

    otherwise

        minDist=slResolve(blkObj.MinDist,blkPath);
    end


    outputPortIndex=1;
    outputValueMax=((M+1)*minDist)/2;
    outputValueMin=-outputValueMax;


