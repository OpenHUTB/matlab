function stencil=CumulativeStencil(inputSize,opDim,opDirection,stencilScaling)






    nDim=numel(inputSize);
    inputSize(nDim+1:opDim)=1;


    preAugmentedSize=[1,inputSize];
    postAugmentedSize=[inputSize,1];





    numDiagonals=prod(preAugmentedSize(1:opDim));
    inputSizePattern=stencilScaling*numDiagonals;
    P=speye(inputSizePattern);



    reduceSize=inputSize(opDim);
    switch opDirection
    case "reverse"
        M=kron(tril(ones(reduceSize)),P);
    case "forward"
        M=kron(triu(ones(reduceSize)),P);
    end



    nBlocks=prod(postAugmentedSize(opDim+1:nDim+1));





    stencil=kron(speye(nBlocks),M);

end

