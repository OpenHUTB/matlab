function item=getDiagramElement(model,semanticItem)


    bdH=get_param(model,'Handle');
    sysarchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
    if isa(semanticItem,'systemcomposer.arch.view.ViewComponent')
        parentArch=semanticItem.ParentArchitecture;
    elseif isa(semanticItem,'systemcomposer.arch.view.Connector')

        parentArch=semanticItem.Architecture;
    else
        error('sysarch.getDiagramElement does not support input of type %s',class(semanticItem));
    end
    parentSys=sysarchApp.getSyntaxSystemForArchitecture(parentArch);
    elements=[parentSys.boxes.toArray(),parentSys.ports,parentSys.pipes.toArray];
    for i=1:numel(elements)
        if strcmp(elements(i).semanticElement,semanticItem.UUID)
            item=elements(i);
            break;
        end
    end
end
