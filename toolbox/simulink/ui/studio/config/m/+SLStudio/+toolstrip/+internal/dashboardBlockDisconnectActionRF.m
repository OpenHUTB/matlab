

function dashboardBlockDisconnectActionRF(cbinfo,action)
    action.enabled=false;
    if SLStudio.Utils.isLockedSystem(cbinfo)
        return;
    end

    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);


        if SLM3I.Util.isValidDiagramElement(element)&&...
            isa(element,'SLM3I.Block')&&...
            isfield(get_param(element.handle,'ObjectParameters'),'Binding')&&...
            ~isempty(get_param(element.handle,'Binding'))
            action.enabled=true;
        end
    end
end
