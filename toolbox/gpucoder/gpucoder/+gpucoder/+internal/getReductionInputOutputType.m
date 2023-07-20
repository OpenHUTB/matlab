function[outputType,reduceIOType]=getReductionInputOutputType(inputArray,preProcessingFcn)










%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    reduceInputTmp=coder.nullcopy(preProcessingFcn(inputArray([])));
    outputType=class(reduceInputTmp);
    smallIntType=isa(reduceInputTmp,'int8')||isa(reduceInputTmp,'int16');
    smallUIntType=isa(reduceInputTmp,'uint8')||isa(reduceInputTmp,'uint16')||isa(reduceInputTmp,'logical');
    if coder.const(smallIntType)
        reduceIOType='int32';
    elseif coder.const(smallUIntType)
        reduceIOType='uint32';
    else
        reduceIOType=outputType;
    end
end
