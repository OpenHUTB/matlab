function rebuildInfo=getDataflowRebuildInfo(modelName,mdlRefTgtType)




    rebuildInfo=[];


    if~(strcmpi(mdlRefTgtType,'SIM')&&strcmp(get_param(modelName,'MulticoreDesignerActive'),'on'))
        return;
    end


    hModel=get_param(modelName,'handle');
    ui=get_param(hModel,'DataflowUI');
    if isempty(ui)
        return;
    end


    allMappingData=ui.MappingData;
    if isempty(allMappingData)
        return;
    end



    isPartitioned=true;


    isProfiling=false;


    numThreads=zeros(1,numel(allMappingData));

    for i=1:numel(allMappingData)
        mappingData=allMappingData(i);
        isPartitioned=isPartitioned&&bitget(mappingData.Attributes,11);
        isProfiling=isProfiling||bitget(mappingData.Attributes,9);
        numThreads(i)=mappingData.NumberOfThreads;
    end

    rebuildInfo.isPartitioned=isPartitioned;
    rebuildInfo.isProfiling=isProfiling;
    rebuildInfo.numThreads=max(numThreads);



    rebuildInfo.cacheFolder=Simulink.fileGenControl('getinternalvalue','CacheFolder');

end


