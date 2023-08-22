function[varargout]=deepNetwork(...
    inputs,...
    inputSizes,...
    inputTypes,...
    block,...
    networkToLoad,...
    useExtrinsic,...
    isDlNetwork,...
    miniBatchSize,...
    predictEnabled,...
    inputFormats,...
    activationLayers)%#codegen

    coder.inline('always');
    coder.allowpcode('plain');
    coder.extrinsic('deep.blocks.internal.getNetworkSizeInfo');
    coder.extrinsic('coder.internal.getFileInfo');
    coder.internal.errorIf(~coder.internal.isConst(inputSizes),'deep_blocks:common:VarsizeInputNotSupported');

    if coder.const(useExtrinsic)
        [predictOutputSizes,predictOutputTypes,activationSizes,activationTypes]=coder.const(...
        @deep.blocks.internal.getNetworkSizeInfo,...
        block,...
        networkToLoad,...
        inputSizes,...
        inputTypes,...
        false,...
        predictEnabled,...
        inputFormats,...
        activationLayers);
    end
    numOutputs=coder.const(nargout-numel(activationLayers));
    if coder.const(predictEnabled)
        startIndex=numOutputs;
    else
        startIndex=0;
    end
    fileName=coder.const(@coder.internal.getFileInfo,networkToLoad);
    coder.internal.addDependentFile(fileName);
    persistent network;
    if isempty(network)
        if coder.const(useExtrinsic)
            network=feval('coder.loadDeepLearningNetwork',coder.const(networkToLoad));
        else
            network=coder.loadDeepLearningNetwork(coder.const(networkToLoad));
        end
    end

    if coder.const(isDlNetwork)
        if coder.const(useExtrinsic)
            if coder.const(predictEnabled)
                coder.unroll();
                for i=1:coder.const(numOutputs)
                    varargout{i}=zeros(coder.const(predictOutputSizes{i}),predictOutputTypes{i});
                end
            end

            coder.unroll();
            for i=1:coder.const(length(activationSizes))
                varargout{startIndex+i}=zeros(coder.const(activationSizes{i}),activationTypes{i});
            end
            [varargout{:}]=feval('deep.blocks.internal.dlnetworkPredict',...
            network,inputs,inputFormats,predictEnabled,activationLayers);
        else
            [varargout{:}]=deep.blocks.internal.dlnetworkPredict(...
            network,inputs,inputFormats,predictEnabled,activationLayers);

        end
    else

        if coder.const(predictEnabled)
            if coder.const(useExtrinsic)

                coder.unroll();
                for i=1:coder.const(numOutputs)
                    varargout{i}=zeros(coder.const(predictOutputSizes{i}),predictOutputTypes{i});
                end
                [varargout{1:coder.const(numOutputs)}]=...
                feval('predict',network,inputs{:},'MiniBatchSize',coder.const(miniBatchSize));
            else
                [varargout{1:coder.const(numOutputs)}]=...
                predict(network,inputs{:},'MiniBatchSize',coder.const(miniBatchSize));
            end
        end

        coder.unroll();
        for i=1:coder.const(length(activationLayers))
            if coder.const(useExtrinsic)
                layerOutputSize=coder.const(activationSizes{i});
                varargout{startIndex+i}=zeros(coder.const(layerOutputSize),activationTypes{i});
                varargout{startIndex+i}=feval('deep.blocks.internal.activationsWrapper',...
                network,inputs,coder.const(activationLayers{i}));
            else
                varargout{startIndex+i}=activations(network,inputs{:},coder.const(activationLayers{i}));
            end
        end

    end

end
