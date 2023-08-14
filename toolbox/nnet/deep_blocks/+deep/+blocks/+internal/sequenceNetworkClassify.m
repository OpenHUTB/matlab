function[varargout]=sequenceNetworkClassify(...
    input,...
    block,...
    networkToLoad,...
    hasSequenceOutput,...
    useExtrinsic,...
    classifyEnabled,...
    predictEnabled,...
    topkEnabled,...
    kValue)%#codegen





    coder.inline('always');
    coder.allowpcode('plain');
    coder.extrinsic('deep.blocks.internal.getNetworkSizeInfo');
    coder.extrinsic('coder.internal.getFileInfo');
    coder.internal.errorIf(~coder.internal.isConst(size(input)),'deep_blocks:common:VarsizeInputNotSupported');

    if useExtrinsic
        [predictOutputSizes,predictOutputTypes]=coder.const(...
        @deep.blocks.internal.getNetworkSizeInfo,...
        block,...
        networkToLoad,...
        {size(input)},...
        {class(input)},...
        false,...
        true,...
        {},...
        {});
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


    if coder.const(useExtrinsic)
        predictOut=zeros(coder.const(predictOutputSizes{1}),predictOutputTypes{1});%#ok<PREALL>
        [network,predictOut]=feval('predictAndUpdateState',network,input);
    else
        [network,predictOut]=predictAndUpdateState(network,input);
    end


    if coder.const(hasSequenceOutput)
        dim=1;
    else
        dim=2;
    end

    if coder.const(classifyEnabled&&~topkEnabled)


        [~,topIdx]=max(predictOut,[],dim);
    elseif coder.const(topkEnabled)

        if eml_option('EnableGPU')
            [predictOutSorted,idxs]=gpucoder.sort(predictOut,dim,'descend');
        else
            [predictOutSorted,idxs]=sort(predictOut,dim,'descend');
        end
        topIdx=idxs(1,:);
    end


    startIndex=0;
    if coder.const(classifyEnabled)
        startIndex=startIndex+1;
        varargout{coder.const(startIndex)}=topIdx;
    end


    if coder.const(predictEnabled)
        if coder.const(topkEnabled)
            if dim==1
                varargout{coder.const(startIndex+1)}=predictOutSorted(1:kValue,:);
                varargout{coder.const(startIndex+2)}=idxs(1:kValue,:);
            else
                varargout{coder.const(startIndex+1)}=predictOutSorted(:,1:kValue);
                varargout{coder.const(startIndex+2)}=idxs(:,1:kValue);
            end
        else
            varargout{coder.const(startIndex+1)}=predictOut;
            varargout{coder.const(startIndex+2)}=1:coder.const(size(predictOut,dim));
        end
    end

end
