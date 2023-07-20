function[outMat,outSize]=findImpl(inpArr,predArr)%#codegen















    coder.allowpcode('plain');

    inpLen=length(inpArr);


    idxMat=predArr;
    idxMat=cumsum(idxMat);
    coder.gpu.kernel;
    for i=1:2
        outSize=idxMat(end);
    end


    outMat=coder.nullcopy(zeros(outSize,1));
    coder.gpu.kernel;
    for j=1:inpLen
        if predArr(j)
            outMat(idxMat(j))=inpArr(j);
        end
    end
end
