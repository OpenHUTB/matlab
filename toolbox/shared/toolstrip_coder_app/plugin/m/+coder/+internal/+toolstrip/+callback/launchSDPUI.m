function launchSDPUI(cbinfo)

    mdl=cbinfo.editorModel.handle;
    sldd=get_param(mdl,'DataDictionary');
    if~isempty(sldd)
        simulinkcoder.internal.app.ViewSDP(sldd);
    end
