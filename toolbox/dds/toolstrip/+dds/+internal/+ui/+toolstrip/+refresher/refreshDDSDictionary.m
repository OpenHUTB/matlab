function refreshDDSDictionary(cbInfo,action)





    mdl=cbInfo.model.handle;
    action.enabled=~isempty(get_param(mdl,'DataDictionary'));

