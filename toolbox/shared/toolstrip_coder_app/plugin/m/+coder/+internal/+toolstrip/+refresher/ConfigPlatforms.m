function ConfigPlatforms(cbinfo,action)




    mdl=cbinfo.editorModel.handle;
    sldd=get_param(mdl,'DataDictionary');
    if isempty(sldd)
        action.enabled=false;
    else
        action.enabled=true;
    end