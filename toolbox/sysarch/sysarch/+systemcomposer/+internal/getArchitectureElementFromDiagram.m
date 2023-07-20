function semanticElem=getArchitectureElementFromDiagram(modelName,diagElemUUID)





    semanticElem=[];
    bdHandle=get_param(bdroot(modelName),'Handle');
    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdHandle);

    syntaxModel=app.getSyntax.getModel;
    diagElem=syntaxModel.findElement(diagElemUUID);
    if isa(diagElem,'sysarch.syntax.architecture.SystemBox')
        diagElem=diagElem.system;
    end
    if~isempty(diagElem)&&~isempty(diagElem.semanticElement)
        semanticElem=app.getCompositionArchitectureModel.findElement(diagElem.semanticElement);
    end