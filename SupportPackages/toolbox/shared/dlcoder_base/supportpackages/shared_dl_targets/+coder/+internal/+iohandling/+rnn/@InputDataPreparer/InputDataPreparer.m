%#codegen




classdef InputDataPreparer


    methods(Hidden=true)
        function obj=InputDataPreparer()
            coder.allowpcode('plain');
        end
    end

    methods(Static)



        [height,width,channels,batchSize]=parseInputSize(in,isCellInput,isImageInput);



        checkInputSize(inputSize,net_insize,callerFunction,isImageInput);



        [miniBatch,sampleSequenceLengths,maxSequenceLength]=prepareColumnMajorImageInput(indata,inputSize,...
        miniBatchSize,sequencePaddingValue,sequencePaddingDirection,isCellInput,miniBatchIdx,permutationDims);
        [miniBatch,sampleSequenceLengths,maxSequenceLength]=prepareColumnMajorVectorInput(indata,inputSize,...
        miniBatchSize,sequencePaddingValue,sequencePaddingDirection,isCellInput,miniBatchIdx,permutationDims);
        [miniBatch,sampleSequenceLengths,maxSequenceLength]=prepareRowMajorImageInput(indata,featureDim,...
        miniBatchSize,sequencePaddingValue,sequencePaddingDirection,isCellInput,miniBatchIdx,permutationDims);
        [miniBatch,sampleSequenceLengths,maxSequenceLength]=prepareRowMajorVectorInput(indata,featureDim,...
        miniBatchSize,sequencePaddingValue,sequencePaddingDirection,isCellInput,miniBatchIdx,permutationDims);
    end
end