function SharedCoderDictionary(cbinfo,action)




    mdl=cbinfo.editorModel.handle;
    ctx=simulinkcoder.internal.toolstrip.util.getCodeInterfaceContext(mdl);
    switch ctx
    case 'CodeInterface_ModelOwned'
        action.text=message('SimulinkCoderApp:toolstrip:CreateSharedCoderDictionaryText').getString;
        action.description=message('SimulinkCoderApp:toolstrip:CreateSharedCoderDictionaryDescription').getString;
        action.icon='CoderDictionaryCreate';

    case 'CodeInterface_DataFunctions'
        action.text=message('SimulinkCoderApp:toolstrip:SharedCoderDictionaryText').getString;
        action.description=message('SimulinkCoderApp:toolstrip:SharedCoderDictionaryDescription').getString;
        action.icon='CoderDictionaryDataAndFunctions';

    case 'CodeInterface_Services'
        action.text=message('SimulinkCoderApp:toolstrip:SharedCoderDictionaryText').getString;
        action.description=message('SimulinkCoderApp:toolstrip:SharedCoderDictionaryServiceDescription').getString;
        action.icon='CoderDictionaryServices';

    end




