function diagItem=getDiagramItemInView(mdlName,semanticItem,iView)


    bdH=sysarch.getBDHandle(mdlName);
    diagItem=[];
    if~isempty(bdH)
        sysarchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
        syntax=sysarchApp.getArchViewsAppMgr.getSyntax();
        if isa(semanticItem,'systemcomposer.architecture.model.views.ElementGroup')
            compGroups=semanticItem.p_CompGroups.toArray;
            diagramElems=[];
            for compGroup=compGroups
                diagramElems=[diagramElems,syntax.getSyntaxElementsForSemanticElement(compGroup)];
            end
        elseif isa(semanticItem,'systemcomposer.architecture.model.design.BaseComponent')&&...
            iView.elementExistsInView(semanticItem)
            diagramElems=syntax.getSyntaxElementsForSemanticElement(iView.getComponentInArchitecture(semanticItem));
        else
            diagramElems=syntax.getSyntaxElementsForSemanticElement(semanticItem);
        end
        studioMgr=sysarchApp.getArchViewsAppMgr.getStudioMgr;
        if~isempty(studioMgr)
            for i=1:numel(diagramElems)

                diagElem=diagramElems(i);
                if studioMgr.isShowingHierarchyDiagramType&&isa(diagElem,'diagram.editor.model.Entity')&&...
                    ~isa(diagElem,'sysarch.syntax.architecture.Box')&&strcmp(diagElem.parent.type,'classdiagram.ClassDiagram')
                    diagItem=diagElem;
                    return;
                elseif~studioMgr.isShowingHierarchyDiagramType&&isa(diagElem,'sysarch.syntax.architecture.Box')
                    diagItem=diagElem;
                    return;
                end
            end
        end
    end
end