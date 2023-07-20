function AppID=registerModel(modelName,mode)


    persistent connectorFolderObjs;




    switch(mode)
    case 'MA'
        maObj=Simulink.ModelAdvisor.getModelAdvisor(modelName);
        if isa(maObj,'Simulink.ModelAdvisor')
            maObj.displayExplorer('hide');
        end
        AppID=maObj.ApplicationID;
    case 'MF'


        appObj=Advisor.Manager.createApplication();
        if strcmp(modelName{1},bdroot(modelName{1}))
            rootType=Advisor.component.Types.Model;
        else
            rootType=Advisor.component.Types.SubSystem;
        end
        appObj.setAnalysisRoot('Root',modelName{1},'RootType',rootType);
        if numel(modelName)>1
            appObj.selectComponents('IDs',modelName(2:end));
        end
        appObj.getCheckInstanceIDs;
        AppID=appObj.ID;


    end


    for i=1:size(connectorFolderObjs,2)
        if connectorFolderObjs(i).clientId==AppID
            return;
        end
    end


    newFolderThread=ModelAdvisorWebUI.interface.FolderRunManager(AppID,modelName,mode);
    connectorFolderObjs=[connectorFolderObjs,newFolderThread];

end


