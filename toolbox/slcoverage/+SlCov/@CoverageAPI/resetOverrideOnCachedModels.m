function resetOverrideOnCachedModels()





    allMdlRefs=cvi.ModelInfoCache.getAllCachedMdlRefs();
    for i=1:numel(allMdlRefs)
        mdlref=allMdlRefs{i};
        if bdIsLoaded(mdlref)
            clr=cvprivate('unlockModel',mdlref);%#ok<NASGU> 
            set_param(mdlref,'RecordCoverageOverride','LeaveAlone');
        end
    end
end