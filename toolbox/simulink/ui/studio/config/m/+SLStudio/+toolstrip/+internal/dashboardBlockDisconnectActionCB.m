

function dashboardBlockDisconnectActionCB(cbinfo)
    if SLStudio.Utils.isLockedSystem(cbinfo)
        return;
    end

    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);
        if SLM3I.Util.isValidDiagramElement(element)
            if isa(element,'SLM3I.Block')
                block=get_param(element.handle,'Object');
                if isprop(block,'Binding')
                    set_param(element.handle,'Binding',[]);
                end
            end
        end
    end
end
