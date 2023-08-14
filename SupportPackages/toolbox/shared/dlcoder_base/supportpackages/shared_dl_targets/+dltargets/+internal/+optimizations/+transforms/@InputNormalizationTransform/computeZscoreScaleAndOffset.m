








function computeZscoreScaleAndOffset(this,layer)




    Mean=layer.Mean;
    Std=layer.StandardDeviation;

    codegenInputSizeForLayer=this.CodegenInfo.NetworkInfo.InputLayerNameToInputSizeMap(layer.Name);

    if this.isImageInput
        isInputImageSizeSameAsTrainingSize=isequal(codegenInputSizeForLayer(1:2),layer.InputSize(1:2));
        if(~isInputImageSizeSameAsTrainingSize)


            Mean=iComputeMeanPerChannel(layer.Mean);
            Std=iComputeStdPerChannel(layer.StandardDeviation,layer.Mean);
        end

    elseif this.isFeatureInput
        assert(numel(layer.InputSize)==1);

        Mean=reshape(Mean,[1,1,size(Mean,2)]);
        Std=reshape(Std,[1,1,size(Std,2)]);

    elseif this.isSequenceInput
        if numel(layer.InputSize)<2

            Mean=reshape(Mean,[1,1,size(Mean,1)]);
            Std=reshape(Std,[1,1,size(Std,1)]);
        end

    end


    Std(Std==0)=1;
    this.scale=1./Std;
    this.offset=-1.*(Mean./Std);

end

function out=iComputeMeanPerChannel(dataAvg)
    out=nnet.internal.cnn.layer.util.computeMeanOfMeans(dataAvg,1:2);
end

function out=iComputeStdPerChannel(dataStd,dataAvg)
    out=nnet.internal.cnn.layer.util.computeMeanOfStds(dataStd,dataAvg,1:2);
end
