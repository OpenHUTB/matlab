












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
    mangledrelpath=fullfile('mangled','onednn');
    mangledDir=fullfile(dltargets.onednn.SupportedLayerImpl.componentRootDir,mangledrelpath);

    sources={};
    headers={};

    sources{end+1}=fullfile(mangledDir,'MWOnednnCNNLayerImpl.cpp');
    headers{end+1}=fullfile(mangledDir,'MWOnednnCNNLayerImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWOnednnTargetNetworkImpl.cpp');
    headers{end+1}=fullfile(mangledDir,'MWOnednnTargetNetworkImpl.hpp');
    sources{end+1}=fullfile(mangledDir,'MWOnednnLayerImplFactory.cpp');
    headers{end+1}=fullfile(mangledDir,'MWOnednnLayerImplFactory.hpp');
    sources{end+1}=fullfile(mangledDir,'MWOnednnUtils.cpp');
    headers{end+1}=fullfile(mangledDir,'MWOnednnUtils.hpp');
    sources{end+1}=fullfile(mangledDir,'MWOnednnCustomLayerBase.cpp');
    headers{end+1}=fullfile(mangledDir,'MWOnednnCustomLayerBase.hpp');
    headers{end+1}=fullfile(mangledDir,'MWOnednnCommonHeaders.hpp');
end
