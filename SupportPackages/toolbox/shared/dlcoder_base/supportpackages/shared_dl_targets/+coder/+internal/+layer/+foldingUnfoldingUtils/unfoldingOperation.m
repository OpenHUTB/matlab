function Z=unfoldingOperation(X,inputFormat,outputFormat,miniBatchSize)




%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(inputFormat,outputFormat)


    if coder.const(coder.internal.layer.utils.hasBatchDim(outputFormat))&&...
        coder.const(coder.internal.layer.utils.hasTimeDim(outputFormat))





        coder.internal.assert(coder.const(count(outputFormat,'T')==1),...
        'dlcoder_spkg:cnncodegen:DLCoderInternalError');

        Z=iComputeReshape(X,inputFormat,miniBatchSize);
    else

        Z=X;
    end
end

function Z=iComputeReshape(X,inputFormat,miniBatchSize)



    coder.inline('always')




    nDims=coder.const(numel(inputFormat));
    reshapeSize=cell(1,nDims+1);
    coder.unroll()
    for i=1:nDims+1
        if i==nDims+1

            reshapeSize{i}=size(X,i-1)/coder.const(miniBatchSize);
        elseif i==nDims

            reshapeSize{i}=coder.const(miniBatchSize);
        else

            reshapeSize{i}=coder.const(size(X,i));
        end
    end


    Z=reshape(X,reshapeSize{:});
end
