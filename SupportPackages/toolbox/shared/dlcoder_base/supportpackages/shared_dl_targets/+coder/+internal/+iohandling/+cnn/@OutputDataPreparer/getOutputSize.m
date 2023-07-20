%#codegen









function outputSize=getOutputSize(outputFeatureSize,batchSize)



    coder.inline('always');
    coder.allowpcode('plain');





    if numel(outputFeatureSize)==1

        outputSize=[batchSize,outputFeatureSize];
    else
        singletonHW=(outputFeatureSize(1)==1)&&(outputFeatureSize(2)==1);
        if singletonHW

            channels=outputFeatureSize(3);
            outputSize=[batchSize,channels];
        else

            outputSize=[outputFeatureSize,batchSize];
        end
    end
end