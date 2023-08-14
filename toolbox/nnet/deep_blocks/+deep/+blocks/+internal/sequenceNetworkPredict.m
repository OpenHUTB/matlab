function[varargout]=sequenceNetworkPredict(...
    inputs,...
    inputSizes,...
    inputTypes,...
    block,...
    networkToLoad,...
    useExtrinsic,...
    isDlNetwork,...
    inputFormats)%#codegen





    coder.inline('always');
    coder.allowpcode('plain');
    coder.extrinsic('deep.blocks.internal.getNetworkSizeInfo');
    coder.extrinsic('coder.internal.getFileInfo');


    coder.internal.errorIf(~coder.internal.isConst(inputSizes),'deep_blocks:common:VarsizeInputNotSupported');
    if coder.const(useExtrinsic)
        [predictOutputSizes,predictOutputTypes]=coder.const(...
        @deep.blocks.internal.getNetworkSizeInfo,...
        block,...
        networkToLoad,...
        inputSizes,...
        inputTypes,...
        false,...
        true,...
        inputFormats,...
        {});
    end

    coder.internal.assert(useExtrinsic||~isDlNetwork,'deep_blocks:common:DlNetworkUpdateStateCodegenNotSupported');


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


        coder.unroll();
        for i=1:coder.const(nargout)
            varargout{i}=zeros(coder.const(predictOutputSizes{i}),predictOutputTypes{i});
        end


        [network,varargout{:}]=feval('deep.blocks.internal.dlnetworkPredictAndUpdateState',...
        network,inputs,inputFormats);
    else

        if coder.const(useExtrinsic)

            coder.unroll();
            for i=1:coder.const(nargout)
                varargout{i}=zeros(coder.const(predictOutputSizes{i}),predictOutputTypes{i});
            end


            [network,varargout{:}]=...
            feval('predictAndUpdateState',network,inputs{:});
        else

            [network,varargout{:}]=...
            predictAndUpdateState(network,inputs{:});
        end
    end

end
