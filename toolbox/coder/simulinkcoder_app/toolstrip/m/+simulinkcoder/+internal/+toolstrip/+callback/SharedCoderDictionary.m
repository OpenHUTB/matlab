function SharedCoderDictionary(userdata,cbinfo)


    mdl=cbinfo.editorModel.handle;
    ctx=simulinkcoder.internal.toolstrip.util.getCodeInterfaceContext(mdl);
    switch ctx
    case 'CodeInterface_ModelOwned'
        simulinkcoder.internal.app.ViewSDP('','ModelToLink',mdl);

    case{'CodeInterface_DataFunctions','CodeInterface_Services'}
        sldd=get_param(mdl,'EmbeddedCoderDictionary');
        simulinkcoder.internal.app.ViewSDP(sldd);
    end


