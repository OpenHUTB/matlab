












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
    mangledrelpath=fullfile('mangled','cudnn');
    mangledDir=fullfile(dltargets.cudnn.SupportedLayerImpl.componentRootDir,mangledrelpath);

    sources={};
    headers={};

    sources{end+1}=fullfile(mangledDir,'MWCudnnCNNLayerImpl.cu');
    headers{end+1}=fullfile(mangledDir,'MWCudnnCNNLayerImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWCudnnTargetNetworkImpl.cu');
    headers{end+1}=fullfile(mangledDir,'MWCudnnTargetNetworkImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWCudnnLayerImplFactory.cu');
    headers{end+1}=fullfile(mangledDir,'MWCudnnLayerImplFactory.hpp');
    sources{end+1}=fullfile(mangledDir,'MWCudnnCustomLayerBase.cu');
    headers{end+1}=fullfile(mangledDir,'MWCudnnCustomLayerBase.hpp');
    headers{end+1}=fullfile(mangledDir,'MWCudnnCommonHeaders.hpp');
end
