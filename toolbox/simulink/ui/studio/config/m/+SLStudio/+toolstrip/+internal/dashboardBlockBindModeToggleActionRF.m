

function dashboardBlockBindModeToggleActionRF(cbinfo,action)
    if SLStudio.Utils.isLockedSystem(cbinfo)
        action.enabled=false;
    end

    action.icon="connectModeNotConnected";
    selection=cbinfo.selection;
    if selection.size==1
        element=selection.at(1);


        if SLM3I.Util.isValidDiagramElement(element)

            if isa(element,'SLM3I.Block')&&...
                strcmp(get_param(element.handle,'BlockType'),'CallbackButton')
                action.enabled=false;
            end

            if isa(element,'SLM3I.Block')||isa(element,'SLM3I.Segment')
                model=cbinfo.model.handle;
                if(Simulink.HMI.getParentLayerBoundElem(model,element.handle)~=-1||...
                    Simulink.HMI.getDefaultBoundElement(model,element.handle)~=-1)
                    action.icon="connectMode";
                    action.text="simulink_ui:studio:resources:bindModeReconnectElementActionLabel";
                end
            end
        end
    end

    if(BindMode.utils.isBindModeEnabled(cbinfo.model.name))
        action.text="simulink_ui:studio:resources:bindModeExitActionLabel";
        action.description="simulink_ui:studio:resources:bindModeExitActionDescription";
    end
end
