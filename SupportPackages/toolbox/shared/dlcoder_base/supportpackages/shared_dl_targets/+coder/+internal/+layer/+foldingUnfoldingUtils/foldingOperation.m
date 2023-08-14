function Z=foldingOperation(X,inputFormat)




%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(inputFormat)

    if coder.const(coder.internal.layer.utils.hasTimeDim(inputFormat)&&...
        coder.internal.layer.utils.hasBatchDim(inputFormat))

        Z=iComputeReshape(X,inputFormat);
    else

        Z=X;
    end
end

function Z=iComputeReshape(X,inputFormat)


    coder.inline('always')




    nDims=coder.const(numel(inputFormat));

    reshapeSize=cell(1,nDims-1);
    coder.unroll()
    for i=1:nDims-1
        if i==nDims-1

            reshapeSize{i}=size(X,i)*size(X,i+1);
        else

            reshapeSize{i}=coder.const(size(X,i));
        end
    end


    Z=reshape(X,reshapeSize{:});
end