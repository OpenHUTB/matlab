

function dashboardBlockJumpToConnectedElementActionRF(cbinfo,action)
    action.enabled=false;

    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);


        if SLM3I.Util.isValidDiagramElement(element)
            if isa(element,'SLM3I.Block')
                model=cbinfo.model.handle;
                if(Simulink.HMI.getParentLayerBoundElem(model,element.handle)~=-1||...
                    Simulink.HMI.getDefaultBoundElement(model,element.handle)~=-1)
                    action.enabled=true;
                end
            end
        end
    end
end
