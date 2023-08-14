function weOut=dnnfpgaDatamemlibZWeAdapter(weIn,zSelIn,active,threadNumLimit,binSize)
%#codegen

    coder.allowpcode('plain');

    weInT=weIn;
    selT=reshape(zSelIn,[1,binSize]);
    weOutT=false(binSize,threadNumLimit);
    for ibx=1:binSize
        if(active)
            if(selT(ibx))
                weOutT(ibx,1:floor(threadNumLimit/2))=false(1,floor(threadNumLimit/2));
                weOutT(ibx,floor(threadNumLimit/2)+1:floor(threadNumLimit/2)*2)=logical(ones(1,floor(threadNumLimit/2))*weInT(ibx));
            else
                weOutT(ibx,1:floor(threadNumLimit/2))=logical(ones(1,floor(threadNumLimit/2))*weInT(ibx));
                weOutT(ibx,floor(threadNumLimit/2)+1:floor(threadNumLimit/2)*2)=false(1,floor(threadNumLimit/2));
            end
        else
            weOutT(ibx,:)=logical(ones(1,floor(threadNumLimit))*weInT(ibx));
        end
    end
    weOut=reshape(weOutT,[binSize*threadNumLimit,1]);
end
