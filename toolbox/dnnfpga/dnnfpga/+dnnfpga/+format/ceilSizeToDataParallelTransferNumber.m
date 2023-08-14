function prodInputSize3D=ceilSizeToDataParallelTransferNumber(inputSize,dataTransNum)














    inputSize3D=inputSize;

    if length(inputSize3D)==2
        inputSize3D=[inputSize3D,1];
    end


    if(dataTransNum>1)
        inputSize3D(3)=ceil(inputSize3D(3)/dataTransNum)*dataTransNum;
    end
    prodInputSize3D=prod(inputSize3D);

end

