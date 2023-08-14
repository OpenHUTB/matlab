function weights2D=computeGemmWeightsRowMajor(weights4D)






    [filterHeight,filterWidth,filterChannel,filterBatch]=size(weights4D);
    filterMatrixHeight=filterHeight*filterWidth*filterChannel;

    weights2D=zeros(filterMatrixHeight,filterBatch,'like',weights4D);


    weights4D=permute(weights4D,[2,1,3,4]);


    for idxCol=1:filterBatch
        weights2D(:,idxCol)=reshape(weights4D(:,:,:,idxCol),filterMatrixHeight,1);
    end


end