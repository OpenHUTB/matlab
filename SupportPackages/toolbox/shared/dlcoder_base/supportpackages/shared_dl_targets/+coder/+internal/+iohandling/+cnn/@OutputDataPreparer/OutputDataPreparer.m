%#codegen




classdef OutputDataPreparer




    methods(Hidden=true)
        function obj=OutputDataPreparer()
            coder.allowpcode('plain');
        end
    end

    methods(Static)


        outputT=permuteImageOutput(output,targetLib);



        outsizeC=getCevalImageOutputSize(outsize,targetLib);



        outsizeC=getCevalVectorOutputSize(outsize,targetLib);



        outputSize=getOutputSize(outputFeatureSize,batchSize)


        outputSize=getOutputSizeForLayer(net,outputLayer,portId,inputSizes);


        [opMiniBatchSizes,opBatchSizes,opPaddedBatchSizes]=getOutputSizeForPredict(net,outputLayer,inputSize,miniBatchSize,batchSize,paddedBatchSize);
    end
end
