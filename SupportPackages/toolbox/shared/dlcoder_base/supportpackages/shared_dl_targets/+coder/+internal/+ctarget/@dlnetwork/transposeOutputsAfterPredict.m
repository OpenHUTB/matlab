function outputDataT=transposeOutputsAfterPredict(obj,outputData,numOutputsRequested,outputFormats)















%#codegen



    coder.internal.prefer_const(numOutputsRequested,outputFormats);
    coder.allowpcode('plain');
    coder.inline('always');


    outputDataT=outputData;

end
