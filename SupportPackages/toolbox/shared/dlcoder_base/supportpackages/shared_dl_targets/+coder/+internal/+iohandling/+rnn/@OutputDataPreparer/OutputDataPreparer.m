%#codegen




classdef OutputDataPreparer


    methods(Hidden=true)
        function obj=OutputDataPreparer()
            coder.allowpcode('plain');
        end
    end

    methods(Static)



        out=prepareOutputForPredict(indata,outputFeatureSize,batchSize,isCellInput,isImageInput,isImageOutput,isSequenceOutput);
        out=prepareOutputForActivations(indata,outputFeatureSize,inBatchSize,miniBatchSize,numMiniBatches,remainder,sequenceLengthMode,isCellInput,isImageInput,isSequenceOutput,isSequenceFolded);



        outputFeatureSizeC=getOutputFeatureSizeC(outputFeatureSize,isImageOutput,isRowMajor);




        out=getOutput(dlTargetLib,outputFeatureSize,isSequenceOutput,isSequenceFolded,isCellInput,isImageInput,isImageOutput,miniBatchSize,sequenceLength,minibatch);
    end
end
