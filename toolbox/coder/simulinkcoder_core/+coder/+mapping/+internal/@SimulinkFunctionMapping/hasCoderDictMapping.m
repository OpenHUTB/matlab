function out=hasCoderDictMapping(mdl)




    model=get_param(mdl,'Name');
    mmgr=get_param(model,'MappingManager');
    Simulink.CoderDictionary.ModelMapping;
    coderDictMapping=mmgr.getActiveMappingFor('CoderDictionary');
    out=~isempty(coderDictMapping);
end
