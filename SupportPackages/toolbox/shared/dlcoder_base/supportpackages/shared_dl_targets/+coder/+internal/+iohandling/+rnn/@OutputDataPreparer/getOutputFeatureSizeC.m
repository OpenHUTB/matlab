%#codegen






function outputFeatureSizeC=getOutputFeatureSizeC(outputFeatureSize,isImageOutput,isRowMajor)
    if coder.const(isImageOutput)
        if coder.const(isRowMajor)




            outputFeatureSizeC=outputFeatureSize([3,1,2]);
        else


            outputFeatureSizeC=outputFeatureSize([2,1,3]);
        end
    else
        outputFeatureSizeC=outputFeatureSize;
    end
end