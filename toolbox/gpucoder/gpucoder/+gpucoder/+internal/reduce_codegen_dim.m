function varargout=reduce_codegen_dim(inputArray,funcArray,reduceDim,preProcessingFcn)




%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    ONE=coder.internal.indexInt(1);
    numFunctions=coder.const(coder.internal.indexInt(length(funcArray)));
    numDims=coder.internal.ndims(inputArray);
    [outputType,reduceIOType]=gpucoder.internal.getReductionInputOutputType(inputArray,preProcessingFcn);


    if isempty(inputArray)
        for k=ONE:numFunctions
            varargout{k}=zeros(0,outputType);
        end

    elseif isscalar(inputArray)
        for k=ONE:numFunctions
            varargout{k}=preProcessingFcn(inputArray);
        end


    else
        inDim=coder.internal.indexInt(size(inputArray));
        reduceSize=inDim(reduceDim)-1;
        outDim=coder.internal.indexInt(getOutDim(inDim,reduceDim));

        for l=ONE:numFunctions
            varargout{l}=coder.nullcopy(zeros(outDim,outputType));
        end


        if reduceSize==0
            coder.gpu.kernel();
            for l=ONE:numFunctions
                coder.gpu.kernel();
                for m=ONE:numel(inputArray)
                    varargout{l}(m)=preProcessingFcn(inputArray(m));
                end
            end
            return;
        end

        nPages=coder.internal.prodsize(inputArray,'above',reduceDim);
        inStride=coder.internal.prodsize(inputArray,'below',reduceDim);
        useShuffleReduce=getUseShuffleReduce(numel(inputArray),reduceSize);

        if~useShuffleReduce
            reduceOutputs=cell(numFunctions,1);
            for l=ONE:numFunctions
                reduceOutputs{l}=coder.nullcopy(zeros(outDim,reduceIOType));
            end
            strideFactor=coder.internal.indexInt(coder.const(@feval,'gpufeature','ReduceStrideFactor'));
            reduceOutput=coder.nullcopy(zeros(outDim,reduceIOType));
            if(strideFactor>=reduceSize+1||~(isa(inputArray,'int32')||isa(inputArray,'uint32')||isa(inputArray,'uint64')))
                [reduceOutputs{:}]=reduction_loop_dim_single_stride(funcArray,reduceSize,reduceOutput,inputArray,inStride,preProcessingFcn);
            else
                [reduceOutputs{:}]=reduction_loop_dim_atomics(funcArray,reduceSize,reduceOutput,inputArray,inStride,preProcessingFcn,strideFactor);
            end
            for l=ONE:numFunctions
                varargout{l}=cast(reduceOutputs{l},outputType);
            end
        else
            if isequal(reduceDim,ONE)
                succDist=inDim(reduceDim);
            else
                succDist=ONE;
            end

            if coder.isRowMajor()
                [nPages,inStride,succDist,reduceDim,inDim]=adjustForRowMajor(nPages,inStride,succDist,reduceDim,numDims,inDim);
            end

            coder.unroll();
            for l=ONE:numFunctions
                reduceOutput=coder.nullcopy(zeros(outDim,reduceIOType));
                reduceOutput(ONE)=reduction_wrapper_dim(funcArray{l},reduceSize,nPages,inStride,succDist,reduceDim,numDims,preProcessingFcn,reduceIOType,inDim,inputArray);
                varargout{l}=cast(reduceOutput,outputType);
            end
        end
    end
end


function[nPagesNew,inStrideNew,succDistNew,reduceDimNew,inDimNew]=adjustForRowMajor(nPages,inStride,succDist,reduceDim,numDims,inDim)



    nPagesNew=inStride;
    inStrideNew=nPages;
    reduceDimNew=numDims-reduceDim+1;
    ONE=coder.internal.indexInt(1);
    if isequal(reduceDimNew,ONE)
        succDistNew=succDist;
    else
        succDistNew=ONE;
    end
    inDimNew=inDim(end:-1:1);
end

function tmp=reduction_wrapper_dim(func,redSize,nPages,inStride,succDist,redDim,numDims,preProcessingFcn,outputType,inDim,inputArray)






    coder.inline('never');
    coder.internal.cfunctionname('#__gpu_reduction_wrapper');

    preprocessOutEg=gpucoder.internal.reduceCallPreAnchor(preProcessingFcn,zeros(like=inputArray));
    coder.ceval('-pure','#__gpu_reduction_input_keeper',coder.rref(redSize),...
    coder.rref(inputArray),...
    coder.rref(nPages),...
    coder.rref(inStride),...
    coder.rref(succDist),...
    coder.rref(redDim),...
    coder.rref(numDims),...
    coder.rref(inDim),...
    coder.ref(preprocessOutEg));

    inputEg=zeros(outputType);
    tmp=cast(gpucoder.internal.reduceCallFcn(func,inputEg,inputEg),outputType);

end


function varargout=reduction_loop_dim_atomics(funcArray,redSize,reduceOutput,inputArray,inStride,preProcessingFcn,strideFactor)






    coder.inline('always');

    ONE=coder.internal.indexInt(1);
    ZERO=coder.internal.indexInt(0);

    numFunctions=coder.const(coder.internal.indexInt(length(funcArray)));

    coder.unroll
    for l=ONE:numFunctions
        varargout{l}=coder.nullcopy(reduceOutput);
    end

    strideFactor=coder.internal.indexInt(strideFactor);
    strides=idivide(redSize,strideFactor,'ceil');
    numReds=coder.internal.indexInt(numel(reduceOutput));
    coder.gpu.kernel();
    for i=ONE:numel(reduceOutput)
        scale=idivide((i-1),inStride);
        offset=i-scale*inStride;
        for l=ONE:numFunctions
            varargout{l}(i)=cast(preProcessingFcn(inputArray(scale*inStride*(redSize+1)+inStride*redSize+offset)),'like',reduceOutput);
        end
    end

    coder.gpu.kernel();
    for k=ZERO:(numReds*strides-1)
        strideIndex=mod(k,numReds)+1;
        curStride=idivide(k,numReds);
        scale=idivide((strideIndex-1),inStride);
        offset=strideIndex-scale*inStride;
        coder.gpu.nokernel();
        for l=ONE:numFunctions
            loopEnd=min(redSize-1,((curStride+1)*strideFactor-1));
            loopStart=curStride*strideFactor;
            localAggregate=cast(preProcessingFcn(inputArray(scale*inStride*(redSize+1)+inStride*loopEnd+offset)),'like',reduceOutput);
            for j=loopStart:loopEnd-1
                localAggregate=funcArray{l}(localAggregate,...
                cast(preProcessingFcn(inputArray(scale*inStride*(redSize+1)+inStride*j+offset)),'like',reduceOutput));
            end
            updated=false;
            old=varargout{l}(strideIndex);
            while(~updated)
                assumed=old;
                newVal=funcArray{l}(localAggregate,assumed);
                [varargout{l}(strideIndex),old]=gpucoder.atomicCAS(varargout{l}(strideIndex),assumed,newVal);
                if(assumed==old)
                    updated=true;
                end
            end
        end
    end
end


function varargout=reduction_loop_dim_single_stride(funcArray,redSize,reduceOutput,inputArray,inStride,preProcessingFcn)







    coder.inline('always');
    ONE=coder.internal.indexInt(1);
    ZERO=coder.internal.indexInt(0);
    numFunctions=coder.const(coder.internal.indexInt(length(funcArray)));

    coder.unroll
    for l=ONE:numFunctions
        varargout{l}=coder.nullcopy(reduceOutput);
    end

    coder.gpu.kernel();
    for i=ONE:numel(reduceOutput)
        scale=idivide((i-1),inStride);
        offset=i-scale*inStride;
        coder.gpu.nokernel();
        for l=ONE:numFunctions
            varargout{l}(i)=cast(preProcessingFcn(inputArray(scale*inStride*(redSize+1)+inStride*redSize+offset)),'like',reduceOutput);
            for j=ZERO:redSize-1
                varargout{l}(i)=funcArray{l}(varargout{l}(i),...
                cast(preProcessingFcn(inputArray(scale*inStride*(redSize+1)+inStride*j+offset)),'like',reduceOutput));
            end
        end
    end
end

function outDim=getOutDim(inDim,redDim)
    coder.inline('always');
    ONE=coder.internal.indexInt(1);
    outDim=inDim;
    outDim(redDim)=ONE;
end

function[val,oldVal]=atomicOp(fcnHandle,val,a)
    coder.inline('always');
    updated=false;
    oldVal=val;
    while(~updated)
        assumed=oldVal;
        newVal=fcnHandle(a,assumed);
        [val,oldVal]=gpucoder.atomicCAS(val,assumed,newVal);
        if(assumed==oldVal)
            updated=true;
        end
    end
end

function useShuffleReduce=getUseShuffleReduce(inputSize,reduceSize)
    shuffleThreshold=coder.const(@feval,'gpufeature','ReduceShuffleThreshold');
    useShuffleReduce=(reduceSize*reduceSize>=shuffleThreshold*inputSize);
end
