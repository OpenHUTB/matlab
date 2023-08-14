




function inpArr=gpu_circshift(inpArr,shiftLen,dim)%#codegen




    coder.allowpcode('plain');
    coder.inline('always');
    coder.gpu.internal.kernelfunImpl(false);
    coder.internal.allowHalfInputs;


    inputSize=size(inpArr);
    vecLen=size(inpArr,dim);


    if dim>ndims(inpArr)
        dimVal=coder.internal.indexInt(0);
    else
        dimVal=coder.internal.indexInt(dim);
    end


    stride=1;
    numvectors=1;
    coder.gpu.nokernel;
    for i=1:dimVal-1
        stride=stride*inputSize(i);
    end
    coder.gpu.nokernel;
    for i=dimVal+1:ndims(inpArr)
        numvectors=numvectors*inputSize(i);
    end


    if abs(shiftLen)>vecLen
        shiftLen=shiftLen-floor(shiftLen/vecLen)*vecLen;
    end



    if shiftLen<0
        shiftLen=vecLen-abs(shiftLen);
    end



    pivotPoint=vecLen-shiftLen;


    if shiftLen>=pivotPoint
        coder.gpu.internal.kernelImpl(false);
        for iter=1:numvectors
            coder.gpu.internal.kernelImpl(false);
            for sIter=1:stride
                coder.gpu.internal.kernelImpl(false);
                for swapIter=1:floor(shiftLen/2)

                    p=(iter-1)*vecLen*stride+sIter;
                    startIdx=p+(pivotPoint+swapIter-1)*stride;
                    endIdx=p+(vecLen-swapIter)*stride;
                    [inpArr(startIdx),inpArr(endIdx)]=swap(inpArr(startIdx),inpArr(endIdx));

                    if swapIter<=floor(pivotPoint/2)
                        p=(iter-1)*vecLen*stride+sIter;
                        startIdx=p+(swapIter-1)*stride;
                        endIdx=p+(pivotPoint-swapIter)*stride;
                        [inpArr(startIdx),inpArr(endIdx)]=swap(inpArr(startIdx),inpArr(endIdx));
                    end
                end
            end
        end
    else
        coder.gpu.internal.kernelImpl(false);
        for iter=1:numvectors
            coder.gpu.internal.kernelImpl(false);
            for sIter=1:stride
                coder.gpu.internal.kernelImpl(false);
                for swapIter=1:floor(pivotPoint/2)

                    p=(iter-1)*vecLen*stride+sIter;
                    startIdx=p+(swapIter-1)*stride;
                    endIdx=p+(pivotPoint-swapIter)*stride;
                    [inpArr(startIdx),inpArr(endIdx)]=swap(inpArr(startIdx),inpArr(endIdx));

                    if swapIter<=floor(shiftLen/2)
                        p=(iter-1)*vecLen*stride+sIter;
                        startIdx=p+(pivotPoint+swapIter-1)*stride;
                        endIdx=p+(vecLen-swapIter)*stride;
                        [inpArr(startIdx),inpArr(endIdx)]=swap(inpArr(startIdx),inpArr(endIdx));
                    end
                end
            end
        end
    end


    coder.gpu.internal.kernelImpl(false);
    for iter=1:numvectors
        coder.gpu.internal.kernelImpl(false);
        for sIter=1:stride
            coder.gpu.internal.kernelImpl(false);
            for swapIter=1:floor(vecLen/2)
                p=(iter-1)*vecLen*stride+sIter;
                startIdx=p+(swapIter-1)*stride;
                endIdx=p+(vecLen-swapIter)*stride;
                [inpArr(startIdx),inpArr(endIdx)]=swap(inpArr(startIdx),inpArr(endIdx));
            end
        end
    end

end



function[b,a]=swap(a,b)
end
