%#codegen











function outSample=prepareVectorOutSampleForActivations(obj,outMiniBatch,sampleIdx,~)




    coder.allowpcode('plain');




    outSample=permute(outMiniBatch(:,sampleIdx,:),[1,3,2]);

end

