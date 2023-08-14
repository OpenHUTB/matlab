function[processedOp,processedBias]=importOperator(op,bias,inputFeatureNum,outputFeatureNum,convSplitMode)




    processedBias=permute(bias,[4,1,2,3]);
    if(convSplitMode==2)
        if(isinteger(op))
            tempOp=int32(zeros(size(op).*[1,1,2,1]));

        else
            tempOp=zeros(size(op).*[1,1,2,1]);
        end
        tempOp(:,:,1:inputFeatureNum/2,1:outputFeatureNum/2)=op(:,:,:,1:outputFeatureNum/2);
        tempOp(:,:,inputFeatureNum/2+1:inputFeatureNum,outputFeatureNum/2+1:outputFeatureNum)=op(:,:,:,outputFeatureNum/2+1:outputFeatureNum);
        processedOp=permute(tempOp,[2,1,3,4]);
        processedOp=flip(processedOp,1);
        processedOp=flip(processedOp,2);

    elseif(convSplitMode>1)
        tempOp=op;
        processedOp=permute(tempOp,[2,1,4,3]);
        for j=1:outputFeatureNum
            processedOp(:,:,j,1)=flip(processedOp(:,:,j,1),1);
            processedOp(:,:,j,1)=flip(processedOp(:,:,j,1),2);
        end

    else
        tempOp=op;
        processedOp=permute(tempOp,[2,1,3,4]);
        processedOp=flip(processedOp,1);
        processedOp=flip(processedOp,2);
    end

end
