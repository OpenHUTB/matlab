function initialize(ad)





    ad.reset;

    ad.PreRunOpenModels;
    ad.Context='None';
    ad.FailedCompiledModelList.clear();
    ad.CompiledModelList.clear();


    trgm=find_system(...
    0,'SearchDepth',1,...
    'type','block_diagram',...
    'name',makeTempModel(rptgen_sl.propsrc_sl,'getModelName'));

    if~isempty(trgm)
        try %#ok
            bdclose(trgm);
        end
    end
