function createInterfaceEditorComponent(studio,~,~)
































    bdH=studio.App.blockDiagramHandle;
    bdName=get_param(bdH,'Name');
    appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);

    if isempty(appMgr)

        msgObj=message('SystemArchitecture:InterfaceEditor:CannotOpenError',bdName);
        exception=MSLException([],msgObj);
        sldiagviewer.reportError(exception);
        return;
    end

    interfaceCatalogStorageContext=systemcomposer.architecture.model.interface.Context.MODEL;
    dd=get_param(bdH,'DataDictionary');
    try
        if~isempty(dd)
            interfaceCatalogStorageContext=systemcomposer.architecture.model.interface.Context.DICTIONARY;
            ddObj=Simulink.data.dictionary.open(dd);
            ddFilePath=ddObj.filepath();
            [~,bdName,~]=fileparts(ddFilePath);
        end
        appMgr.createInterfaceEditor(bdName,studio.getStudioTag(),interfaceCatalogStorageContext,get_param(bdH,'Name'));
        appMgr.toggleInterfaceEditor();
    catch




        interfaceEditorComponent=studio.getComponent('GLUE2:DDG Component','InterfaceEditor');
        if~isempty(interfaceEditorComponent)&&interfaceEditorComponent.isVisible
            appMgr.toggleInterfaceEditor();
        else
            ZCStudio.makeZcFixitNotification(bdName,'UnableToOpenInterfaceEditor',...
            'SystemArchitecture:zcFixitWorkflows:UnableToOpenInterfaceEditor',...
            'warn',dd);
        end
    end
end


