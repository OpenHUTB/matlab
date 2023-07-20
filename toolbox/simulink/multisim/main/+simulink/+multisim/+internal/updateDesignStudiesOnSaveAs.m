function updateDesignStudiesOnSaveAs(modelHandle,oldModelName)





    currentModelName=get_param(modelHandle,"Name");
    allElements=getAllElementsOfDesignSuite(modelHandle);
    updateModelNameInSpecifications(allElements,oldModelName,currentModelName);

    dvStageName=message("multisim:SetupGUI:DVMultiSimStageName").getString();
    dvStage=sldiagviewer.createStage(dvStageName,"ModelName",currentModelName);
    sldiagviewer.reportInfo(message("multisim:SetupGUI:DVModelNameUpdatedOnSaveAs").getString());
    dvStageCleanup=onCleanup(@()delete(dvStage));

    Simulink.removeBlockDiagramCallback(modelHandle,"PostNameChange","UpdateDesignStudies");
    Simulink.addBlockDiagramCallback(modelHandle,"PostNameChange","UpdateDesignStudies",...
    @()simulink.multisim.internal.updateDesignStudiesOnSaveAs(modelHandle,currentModelName));
end

function allElements=getAllElementsOfDesignSuite(modelHandle)
    bdAssociatedDataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    designSession=Simulink.BlockDiagramAssociatedData.get(modelHandle,bdAssociatedDataId).Session;
    designSuiteMap=Simulink.BlockDiagramAssociatedData.get(modelHandle,bdAssociatedDataId).DesignSuiteMap;
    designSuiteInfo=designSuiteMap(designSession.ActiveDesignSuiteUUID);
    allElements=designSuiteInfo.DataModel.allElements();
end

function updateModelNameInSpecifications(allElements,oldModelName,currentModelName)
    for index=1:length(allElements)
        element=allElements(index);
        switch element.StaticMetaClass.name
        case "BlockParameter"
            blockPath=element.BlockPath;
            if startsWith(blockPath,strcat(oldModelName,"/"))
                element.BlockPath=replaceBetween(blockPath,1,strlength(oldModelName),currentModelName);
            end

        case "Variable"
            if strcmp(element.Workspace,oldModelName)
                element.Workspace=currentModelName;
            end
        end
    end
end