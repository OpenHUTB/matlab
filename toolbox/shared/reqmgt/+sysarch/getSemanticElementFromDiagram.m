function semanticElem=getSemanticElementFromDiagram(modelName,diagElemUUID)






    appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(get_param(modelName,'handle'));
    syntaxModels=sysarch.getSyntaxes(modelName);
    for i=1:numel(syntaxModels)
        elem=syntaxModels(i).getModel.findElement(diagElemUUID);
        if~isempty(elem)
            break;
        end
    end

    compMFModel=appMgr.getCompositionArchitectureModel;
    viewMFModel=appMgr.getArchViewsAppMgr.getModel;

    semanticElem=viewMFModel.findElement(elem.semanticElement);
    if isempty(semanticElem)
        semanticElem=compMFModel.findElement(elem.semanticElement);
    end

end