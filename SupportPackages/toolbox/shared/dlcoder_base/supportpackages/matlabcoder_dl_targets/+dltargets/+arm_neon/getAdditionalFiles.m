












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
    mangledrelpath=fullfile('mangled','arm_neon');
    mangledDir=fullfile(dltargets.arm_neon.SupportedLayerImpl.componentRootDir,mangledrelpath);

    sources={};
    headers={};

    sources{end+1}=fullfile(mangledDir,'MWArmneonCNNLayerImpl.cpp');
    headers{end+1}=fullfile(mangledDir,'MWArmneonCNNLayerImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWArmneonTargetNetworkImpl.cpp');
    headers{end+1}=fullfile(mangledDir,'MWArmneonTargetNetworkImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWArmneonLayerImplFactory.cpp');
    headers{end+1}=fullfile(mangledDir,'MWArmneonLayerImplFactory.hpp');
    sources{end+1}=fullfile(mangledDir,'MWACLUtils.cpp');
    headers{end+1}=fullfile(mangledDir,'MWACLUtils.hpp');
    sources{end+1}=fullfile(mangledDir,'MWArmneonCustomLayerBase.cpp');
    headers{end+1}=fullfile(mangledDir,'MWArmneonCustomLayerBase.hpp');
end
