function dataOut=dnnfpgaDatamemlibZDataAdapter(dataIn,zSelIn,threadNumLimit,binSize)
%#codegen

    coder.allowpcode('plain');

    dataInT=reshape(dataIn,[binSize,threadNumLimit]);
    selT=reshape(zSelIn,[1,binSize]);
    dataOutT=dataInT;
    for ibx=1:binSize
        if(selT(ibx))
            dataOutT(ibx,1:floor(threadNumLimit/2))=dataInT(ibx,floor(threadNumLimit/2)+1:floor(threadNumLimit/2)*2);
        else
            dataOutT(ibx,1:floor(threadNumLimit/2))=dataInT(ibx,1:floor(threadNumLimit/2));
        end
        dataOutT(ibx,floor(threadNumLimit/2)+1:end)=dataInT(ibx,floor(threadNumLimit/2)+1:end);
    end
    dataOut=reshape(dataOutT,[binSize*threadNumLimit,1]);
end
