function Z=flatteningOperation(X,inputFormat,numSpatialDims)




%#codegen

    coder.inline('always')
    coder.allowpcode('plain')




    nDims=coder.const(numel(inputFormat));

    if~coder.const(coder.internal.layer.utils.hasBatchDim(inputFormat))&&...
        ~coder.const(coder.internal.layer.utils.hasTimeDim(inputFormat))




        nDims=nDims+1;
    end

    reshapeSize=cell(1,nDims-numSpatialDims);

    reshapeSize{1}=coder.const(prod(size(X,1:numSpatialDims+1)));
    coder.unroll()
    for i=numSpatialDims+2:nDims

        if coder.internal.isConst(size(X,i))


            reshapeSize{i-numSpatialDims}=coder.const(size(X,i));
        else
            reshapeSize{i-numSpatialDims}=size(X,i);
        end
    end
    Z=reshape(X,reshapeSize{:});
end