function output=reduce_codegen(inputArray,funcArray,preProcessingFcn)




%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    ONE=coder.internal.indexInt(1);
    [outputType,reduceIOType]=gpucoder.internal.getReductionInputOutputType(inputArray,preProcessingFcn);
    numFunctions=coder.const(coder.internal.indexInt(length(funcArray)));


    if isempty(inputArray)
        output=zeros(0,outputType);

    elseif isscalar(inputArray)
        output=coder.nullcopy(zeros(1,numFunctions,outputType));
        coder.gpu.internal.kernelImpl(false);
        for k=ONE:numFunctions
            output(k)=preProcessingFcn(inputArray);
        end

    else
        outputVar=coder.nullcopy(zeros(1,numFunctions,reduceIOType));
        numOfElements=coder.internal.indexInt(numel(inputArray)-1);
        reduceOutput=coder.nullcopy(zeros(1,numFunctions,reduceIOType));%#ok<NASGU>
        reduceOutput=reduction_wrapper(funcArray,numOfElements,outputVar,inputArray,preProcessingFcn);
        output=cast(reduceOutput,outputType);
    end
end

function reduceOutput=reduction_wrapper(funcArray,numOfElements,outputVar,inputArray,preProcessingFcn)
    coder.inline('never');
    coder.internal.cfunctionname('#__gpu_reduction_wrapper');

    ONE=coder.internal.indexInt(1);
    numFunctions=coder.const(coder.internal.indexInt(length(funcArray)));
    outputType=class(outputVar);
    reduceOutput=coder.nullcopy(zeros(1,numFunctions,outputType));

    preprocessOutEg=gpucoder.internal.reduceCallPreAnchor(preProcessingFcn,zeros(like=inputArray));
    coder.ceval('-pure','#__gpu_reduction_input_keeper',coder.rref(numOfElements),coder.rref(outputVar),...
    coder.rref(inputArray),coder.ref(preprocessOutEg));

    coder.unroll
    for l=ONE:numFunctions
        inputEg=zeros(outputType);
        reduceOutput(l)=cast(gpucoder.internal.reduceCallFcn(funcArray{l},inputEg,inputEg),outputType);
    end

end
