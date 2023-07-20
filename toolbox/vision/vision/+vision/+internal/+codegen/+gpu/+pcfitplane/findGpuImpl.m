
function[outMat,outSize]=findGpuImpl(inpMat,predMatInp)



















%#codegen



    coder.gpu.kernelfun;
    coder.inline('never');
    coder.allowpcode('plain');

    [inpRows,inpCols]=size(inpMat);
    predLength=length(predMatInp);

    if isempty(predMatInp)||isempty(inpMat)
        outMat=zeros(size(inpMat));
        outSize=uint32(0);
        return;
    end

    if~(isvector(predMatInp)&&(inpRows==size(predMatInp,1)||inpCols==size(predMatInp,2)))

        outMat=zeros(size(inpMat));
        outSize=uint32(0);
        return;
    end


    if~islogical(predMatInp)
        predMat=(predMatInp>0);
    else
        predMat=predMatInp;
    end


    idxMat=predMat;
    idxMat=cumsum(idxMat);



    outSize=uint32(0);
    coder.gpu.kernel;
    for i=1:1
        outSize=uint32(idxMat(predLength));
    end



    if isrow(predMat)
        outMat=coder.nullcopy(zeros(inpRows,outSize));
        coder.gpu.kernel;
        for i=1:size(inpMat,2)
            for j=1:size(inpMat,1)
                if predMat(i)
                    outMat(j,idxMat(i))=inpMat(j,i);
                end
            end
        end
    else


        outMat=coder.nullcopy(zeros(outSize,inpCols));
        coder.gpu.kernel;
        for i=1:size(inpMat,2)
            for j=1:size(inpMat,1)
                if predMat(j)
                    outMat(idxMat(j),i)=inpMat(j,i);
                end
            end
        end
    end
end