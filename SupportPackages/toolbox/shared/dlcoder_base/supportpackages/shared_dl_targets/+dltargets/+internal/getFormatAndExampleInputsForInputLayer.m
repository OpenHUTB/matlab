function[inputLayerFormat,exampleInputData]=...
    getFormatAndExampleInputsForInputLayer(inputLayer,inputSize,inputLayerFormat,isLayerInDlnetwork,exampleSequenceLength)

























    if nargin<5
        exampleSequenceLength=[];
    end

    if isLayerInDlnetwork


        if~isempty(inputLayerFormat)
            inputSize=dltargets.internal.getInputSizeBasedOnFormat(inputSize,inputLayerFormat,exampleSequenceLength);
        else
            assert(dltargets.internal.checkIfInputLayer(inputLayer));
            [inputSize,inputLayerFormat]=iGetInputSizeAndFormatBasedOnLayer(inputLayer,inputSize,isLayerInDlnetwork);
        end
        exampleInputData=dlarray(ones(inputSize),inputLayerFormat);
    else
        assert(isempty(exampleSequenceLength));
        [inputSize,inputLayerFormat]=iGetInputSizeAndFormatBasedOnLayer(inputLayer,inputSize,isLayerInDlnetwork);
        exampleInputData=ones(inputSize);
    end

end


function[inputSize,inputLayerFormat]=iGetInputSizeAndFormatBasedOnLayer(inputLayer,inputSize,isLayerInDlnetwork)

    switch class(inputLayer)
    case 'nnet.cnn.layer.ImageInputLayer'
        inputLayerFormat='SSCB';
    case 'nnet.cnn.layer.Image3DInputLayer'
        inputLayerFormat='SSSCB';
    case 'nnet.cnn.layer.SequenceInputLayer'




        exampleSequenceLength=inputLayer.MinLength;

        if numel(inputLayer.InputSize)==1


            assert(inputSize(1)==1&&inputSize(2)==1);
            inputLayerFormat='CBT';
            inputSize=[inputSize(3:end),exampleSequenceLength];
        elseif numel(inputLayer.InputSize)==2
            inputLayerFormat='SCBT';




            inputSize=[inputSize(2:end),exampleSequenceLength];
        elseif numel(inputLayer.InputSize)==4
            inputLayerFormat='SSSCBT';
            inputSize=[inputSize,exampleSequenceLength];
        else
            assert(numel(inputLayer.InputSize)==3);
            inputLayerFormat='SSCBT';
            inputSize=[inputSize,exampleSequenceLength];
        end
    case 'nnet.cnn.layer.FeatureInputLayer'


        assert(inputSize(1)==1&&inputSize(2)==1);
        if isLayerInDlnetwork
            inputSize=inputSize(3:end);
            inputLayerFormat='CB';
        else
            inputSize=[inputSize(end),inputSize(3)];
            inputLayerFormat='BC';
        end

    case 'nnet.cnn.layer.PointCloudInputLayer'
        if numel(inputLayer.InputSize)==2
            inputLayerFormat='SCB';
        else
            inputLayerFormat='SSCB';
        end
    case 'nnet.internal.cnn.coder.layer.PointCloudInputLayer'
        if numel(inputLayer.InputSize)==2
            inputLayerFormat='SCB';
        else
            inputLayerFormat='SSCB';
        end
    otherwise
        assert(false,'layer is not an inputLayer supported for code generation.');
    end
end
