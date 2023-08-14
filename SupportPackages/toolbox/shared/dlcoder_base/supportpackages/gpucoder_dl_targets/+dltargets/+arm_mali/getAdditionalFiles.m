












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
    mangledrelpath=fullfile('mangled','arm_mali');
    mangledDir=fullfile(dltargets.arm_mali.SupportedLayerImpl.componentRootDir,mangledrelpath);

    sources={};
    headers={};

    sources{end+1}=fullfile(mangledDir,'MWArmmaliCNNLayerImpl.cpp');
    headers{end+1}=fullfile(mangledDir,'MWArmmaliCNNLayerImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWArmmaliTargetNetworkImpl.cpp');
    headers{end+1}=fullfile(mangledDir,'MWArmmaliTargetNetworkImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWArmmaliLayerImplFactory.cpp');
    headers{end+1}=fullfile(mangledDir,'MWArmmaliLayerImplFactory.hpp');
end
