








function computeRescaleNormScaleAndOffset(this,layer)




    Min=layer.Min;
    Max=layer.Max;

    codegenInputSizeForLayer=this.CodegenInfo.NetworkInfo.InputLayerNameToInputSizeMap(layer.Name);

    if this.isImageInput
        isInputImageSizeSameAsTrainingSize=isequal(codegenInputSizeForLayer(1:2),layer.InputSize(1:2));
        if(~isInputImageSizeSameAsTrainingSize)


            Min=iComputeMinPerChannel(layer.Min);
            Max=iComputeMaxPerChannel(layer.Max);
        end

    elseif this.isFeatureInput
        assert(numel(layer.InputSize)==1);

        Min=reshape(Min,[1,1,size(Min,2)]);
        Max=reshape(Max,[1,1,size(Max,2)]);

    elseif this.isSequenceInput
        if numel(layer.InputSize)<2

            Min=reshape(Min,[1,1,size(Min,1)]);
            Max=reshape(Max,[1,1,size(Max,1)]);
        end

    end


    if strcmpi(layer.Normalization,'rescale-symmetric')
        a=-1;
        b=1;
    else
        a=0;
        b=1;
    end

    [this.scale,this.offset]=getScaleAndOffsetForRescaleNormalization(Min,Max,a,b);

end



function out=iComputeMinPerChannel(minValue)
    out=iReduce(minValue,@min,1:2);
end

function out=iComputeMaxPerChannel(maxValue)
    out=iReduce(maxValue,@max,1:2);
end


function reducedValue=iReduce(value,fcn,spatialDims)

    reducedValue=fcn(value,[],spatialDims);
end

function[scaleFactor,offset]=getScaleAndOffsetForRescaleNormalization(Min,Max,a,b)

    range=Max-Min;


    range(range==0)=1;

    scaleFactor=(b-a)./range;

    offset=a+((a-b).*Min)./range;

end
