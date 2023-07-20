function[implSources,implHeaders]=getImplFiles(net,target,dlcfg)








    if nargin<3
        dlcfg=[];
    end



    versionField=[dltargets.internal.utils.getExternalTargetString(target),'Version'];
    libraryVersion='';
    if~isempty(dlcfg)&&isprop(dlcfg,versionField)
        libraryVersion=dlcfg.(versionField);
    end


    allLayerSources=dltargets.(target).SupportedLayerImpl.m_sourceFiles;
    allLayerHeaders=dltargets.(target).SupportedLayerImpl.m_headerFiles;


    [implSources,implHeaders]=...
    dltargets.internal.getLayerImplFiles(...
    net,allLayerSources,allLayerHeaders,target,libraryVersion);


    [allAdditionalSources,allAdditionalHeaders]=dltargets.(target).getAdditionalFiles();


    [additionalSources,additionalHeaders]=...
    iSelectVersionedImplFiles(...
    allAdditionalSources,allAdditionalHeaders,libraryVersion);


    implSources=[implSources,additionalSources];
    implHeaders=[implHeaders,additionalHeaders];
end

function[versionedSources,versionedHeaders]=iSelectVersionedImplFiles(sources,headers,libraryVersion)
    versionedSources=iSelectVersionedFiles(sources,libraryVersion);
    versionedHeaders=iSelectVersionedFiles(headers,libraryVersion);
end







function versionedFiles=iSelectVersionedFiles(files,libraryVersion)
    versionedFiles={};
    for i=1:numel(files)
        cellEntry=files{i};
        if isa(cellEntry,'containers.Map')
            assert(isKey(cellEntry,libraryVersion),'Unexpected target library version');
            file=cellEntry(libraryVersion);
        else
            file=cellEntry;
        end
        versionedFiles=[versionedFiles,file];%#ok
    end
end
