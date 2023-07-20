function dataOut=dnnfpgaDatamemlibZWDataAdapter(dataIn,active,threadNumLimit,binSize)
%#codegen

    coder.allowpcode('plain');

    if(active)
        dataInT=reshape(dataIn,[binSize,threadNumLimit]);
        dataOutT=dataInT;
        for ibx=1:binSize
            dataOutT(ibx,1:floor(threadNumLimit/2))=dataInT(ibx,1:floor(threadNumLimit/2));
            dataOutT(ibx,floor(threadNumLimit/2)+1:floor(threadNumLimit/2)*2)=dataInT(ibx,1:floor(threadNumLimit/2));
        end
        dataOut=reshape(dataOutT,[binSize*threadNumLimit,1]);
    else
        dataOut=dataIn;
    end
end
