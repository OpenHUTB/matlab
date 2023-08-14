%#codegen












function outSample=prepareImageOutSampleForActivations(obj,outMiniBatch,sampleIdx,~)




    coder.allowpcode('plain');




    outSample=permute(outMiniBatch(:,:,:,sampleIdx,:),[1,2,3,5,4]);

end

