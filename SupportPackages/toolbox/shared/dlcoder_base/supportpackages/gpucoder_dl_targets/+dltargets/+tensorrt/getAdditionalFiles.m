












function[sourceFiles,headerFiles]=getAdditionalFiles()




    persistent sources;
    persistent headers;

    if isempty(sources)
        assert(isempty(headers),"Sources cell array is empty but headers cell array is not.");
        [sources,headers]=iPopulateSourcesAndHeaders();
    end

    sourceFiles=sources;
    headerFiles=headers;
end

function[sources,headers]=iPopulateSourcesAndHeaders()
    mangledrelpath=fullfile('mangled','tensorrt');
    mangledDir=fullfile(dltargets.tensorrt.SupportedLayerImpl.componentRootDir,mangledrelpath);

    sources={};
    headers={};

    sources{end+1}=fullfile(mangledDir,'MWTensorrtCNNLayerImpl.cu');
    headers{end+1}=fullfile(mangledDir,'MWTensorrtCNNLayerImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWTensorrtTargetNetworkImpl.cu');
    headers{end+1}=fullfile(mangledDir,'MWTensorrtTargetNetworkImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWTensorrtLayerImplFactory.cu');
    headers{end+1}=fullfile(mangledDir,'MWTensorrtLayerImplFactory.hpp');
    headers{end+1}=fullfile(mangledDir,'MWBatchStream.hpp');
    sources{end+1}=fullfile(mangledDir,'MWTensorrtCustomLayerBase.cu');
    headers{end+1}=fullfile(mangledDir,'MWTensorrtCustomLayerBase.hpp');
    headers{end+1}=fullfile(mangledDir,'MWTensorrtCommonHeaders.hpp');
    sources{end+1}=fullfile(mangledDir,'MWTensorrtUtils.cu');
    headers{end+1}=fullfile(mangledDir,'MWTensorrtUtils.hpp');
    sources{end+1}=fullfile(mangledDir,'MWTensorrtVersionSpecificImpl.cu');
    headers{end+1}=fullfile(mangledDir,'MWTensorrtVersionSpecificImpl.hpp');
end
