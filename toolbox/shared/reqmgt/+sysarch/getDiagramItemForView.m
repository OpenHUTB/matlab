function diagItem=getDiagramItemForView(mdlName,semanticItem)

    bdH=sysarch.getBDHandle(mdlName);
    diagItem=[];

    if~isempty(bdH)
        sysarchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
        syntax=sysarchApp.getArchViewsAppMgr.getSyntax();
        diagramElems=syntax.getSyntaxElementsForSemanticElement(semanticItem);
        for i=1:numel(diagramElems)
            if isa(diagramElems(i),'sysarch.syntax.architecture.SystemBox')
                diagItem=diagramElems(i);
                return;
            end
        end
    end