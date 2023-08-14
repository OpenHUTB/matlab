%#codegen


classdef InputLayer<nnet.layer.Layer




    properties
InputSize
InputFormat
Normalization
Mean
StandardDeviation
Min
Max
Slope
Bias
    end

    properties(Constant)
        IsInputLayer=true
    end

    methods
        function layer=InputLayer(name,inputSize,inputFormat,normalization,mean,standardDeviation,min,max)
            layer.Name=name;
            layer.InputSize=inputSize;
            layer.InputFormat=inputFormat;
            layer.Normalization=normalization;
            layer.Mean=mean;
            layer.Min=min;
            layer.Max=max;



            standardDeviation(standardDeviation==0)=1;
            layer.StandardDeviation=standardDeviation;

            if strcmp(layer.Normalization,'rescale-symmetric')
                [layer.Slope,layer.Bias]=...
                coder.internal.layer.inputLayerUtils.getParamsForRescale(layer.Min,layer.Max,-1,1);
            elseif strcmp(layer.Normalization,'rescale-zero-one')
                [layer.Slope,layer.Bias]=...
                coder.internal.layer.inputLayerUtils.getParamsForRescale(layer.Min,layer.Max,0,1);
            end
        end

        function X1=predict(layer,X1)
            coder.allowpcode('plain');
            coder.inline('always');

            if coder.const(strcmp(layer.Normalization,'zerocenter'))
                X1=iComputeZeroCenterNormalization(layer,X1);
            elseif coder.const(strcmp(layer.Normalization,'zscore'))
                X1=iComputeZscoreNormalization(layer,X1);
            elseif coder.const(strcmp(layer.Normalization,'rescale-symmetric'))
                X1=iComputeRescaleSymmetricNormalization(layer,X1);
            elseif coder.const(strcmp(layer.Normalization,'rescale-zero-one'))
                X1=iComputeRescaleZeroOneNormalization(layer,X1);
            elseif coder.const(strcmp(layer.Normalization,'none'))
                X1=X1;%#ok
            end
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'InputSize','InputFormat','Normalization'};
        end
    end
end


function X1=iComputeZeroCenterNormalization(layer,X1)
    coder.inline('always');
    spatialSizes=coder.const(coder.internal.layer.utils.getFormatSizeAndDimension(X1,layer.InputFormat{1},"S"));
    if coder.const(iIsOversizedImageInput(spatialSizes,layer.InputSize))


        mean=coder.const(@feval,...
        'nnet.internal.cnn.layer.util.computeMeanOfMeans',layer.Mean,1:2);
        X1=X1-mean;
    else
        X1=X1-layer.Mean;
    end
end

function X1=iComputeZscoreNormalization(layer,X1)
    coder.inline('always');
    spatialSizes=coder.const(coder.internal.layer.utils.getFormatSizeAndDimension(X1,layer.InputFormat{1},"S"));
    if coder.const(iIsOversizedImageInput(spatialSizes,layer.InputSize))


        mean=coder.const(@feval,...
        'nnet.internal.cnn.layer.util.computeMeanOfMeans',layer.Mean,1:2);
        stdDev=coder.const(@feval,...
        'nnet.internal.cnn.layer.util.computeMeanOfStds',...
        layer.StandardDeviation,layer.Mean,1:2);
        X1=(X1-mean)./stdDev;
    else
        X1=(X1-layer.Mean)./layer.StandardDeviation;
    end
end

function X1=iComputeRescaleSymmetricNormalization(layer,X1)
    coder.inline('always');
    spatialSizes=coder.const(coder.internal.layer.utils.getFormatSizeAndDimension(X1,layer.InputFormat{1},"S"));
    if coder.const(iIsOversizedImageInput(spatialSizes,layer.InputSize))


        [slope,bias]=coder.const(@feval,...
        'coder.internal.layer.inputLayerUtils.getParamsForRescaleForOversizedInput',...
        layer.Min,layer.Max,-1,1);
        X1=(X1.*slope)+bias;
    else
        X1=(X1.*layer.Slope)+layer.Bias;
    end

    X1=coder.internal.layer.inputLayerUtils.clipData(X1,-1,1);
end

function X1=iComputeRescaleZeroOneNormalization(layer,X1)
    coder.inline('always');
    spatialSizes=coder.const(coder.internal.layer.utils.getFormatSizeAndDimension(X1,layer.InputFormat{1},"S"));
    if coder.const(iIsOversizedImageInput(spatialSizes,layer.InputSize))


        [slope,bias]=coder.const(@feval,...
        'coder.internal.layer.inputLayerUtils.getParamsForRescaleForOversizedInput',...
        layer.Min,layer.Max,0,1);
        X1=(X1.*slope)+bias;
    else
        X1=(X1.*layer.Slope)+layer.Bias;
    end

    X1=coder.internal.layer.inputLayerUtils.clipData(X1,0,1);
end

function tf=iIsOversizedImageInput(inputSpatialSize,layerInputSize)
    coder.inline('always');
    coder.internal.prefer_const(inputSpatialSize,layerInputSize);
    tf=numel(inputSpatialSize)==2&&any(gt(inputSpatialSize,layerInputSize(1:2)));


end
