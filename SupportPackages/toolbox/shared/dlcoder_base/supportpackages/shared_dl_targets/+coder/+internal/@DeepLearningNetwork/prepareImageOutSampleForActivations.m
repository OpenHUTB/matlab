%#codegen

function outSample=prepareImageOutSampleForActivations(obj,outMiniBatch,sampleIdx,isCellInput)




    coder.allowpcode('plain');



    if coder.isRowMajor
        if coder.const(isCellInput)



            reshapedSample=...
            reshape(outMiniBatch(:,sampleIdx,:,:,:),...
            size(outMiniBatch,[1,3,4,5]));


            outSample=permute(reshapedSample,[3,4,2,1]);
        else



            outSample=permute(outMiniBatch,[3,4,2,1]);
        end
    else
        if coder.const(isCellInput)



            reshapedSample=reshape(outMiniBatch(:,:,:,sampleIdx,:),...
            size(outMiniBatch,[1,2,3,5]));


            outSample=permute(reshapedSample,[2,1,3,4]);
        else



            outSample=permute(outMiniBatch,[2,1,3,4]);
        end
    end
end

