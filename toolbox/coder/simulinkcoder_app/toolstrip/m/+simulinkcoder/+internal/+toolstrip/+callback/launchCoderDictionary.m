function launchCoderDictionary(userdata,cbinfo)




    mdl=cbinfo.editorModel.handle;
    if strcmp(userdata,'model')

        simulinkcoder.internal.app.ViewSDP(mdl);
    elseif strcmp(userdata,'shared')

        sldd=get_param(mdl,'EmbeddedCoderDictionary');
        simulinkcoder.internal.app.ViewSDP(sldd);
    end


