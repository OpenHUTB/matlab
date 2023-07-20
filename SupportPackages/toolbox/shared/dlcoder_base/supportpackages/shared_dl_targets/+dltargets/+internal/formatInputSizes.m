











function inputSizesFormatted=formatInputSizes(inputSizes,batchSize)
    if nargin<2
        batchSize=1;
    end

    for i=1:numel(inputSizes)
        isVectorInput=numel(inputSizes{i})==1;
        is2DImageInput=numel(inputSizes{i})==3;
        if isVectorInput
            inputSizes{i}=[1,1,inputSizes{i}(1),batchSize];
        elseif is2DImageInput
            inputSizes{i}=[inputSizes{i}(1:3),batchSize];
        else

            assert(numel(inputSizes{i})==4,'InputSize property of input layer is neither a vector, 2d image, or 3d image');
            inputSizes{i}=[inputSizes{i}(1:4),batchSize];
        end
    end
    inputSizesFormatted=inputSizes;
end