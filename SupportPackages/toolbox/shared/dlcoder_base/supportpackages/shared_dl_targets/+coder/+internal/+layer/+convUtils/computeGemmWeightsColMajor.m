function weights2D=computeGemmWeightsColMajor(weights4D)






    [filterHeight,filterWidth,filterChannel,filterBatch]=size(weights4D);
    filterMatrixWidth=filterHeight*filterWidth*filterChannel;

    weights2D=zeros(filterBatch,filterMatrixWidth,'like',weights4D);


    for idxRow=1:filterBatch
        weights2D(idxRow,:)=reshape(weights4D(:,:,:,idxRow),1,filterMatrixWidth);
    end

end