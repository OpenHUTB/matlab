

function gw=createSSRefInstancesForSubsystemBlockPopup(cbinfo)

    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if(~isempty(block))
        blockHandle=block.handle;
        block_type=get_param(blockHandle,'BlockType');
        if(~strcmp(block_type,'SubSystem'))
            return;
        end
        child_model=get_param(blockHandle,'ReferencedSubsystem');
        eventDataNamespace=cbinfo.EventData.namespace;
        eventDataType=cbinfo.EventData.type;

        if(isvarname(child_model)&&bdIsLoaded(child_model)&&bdIsSubsystem(child_model))
            gw=SLStudio.toolstrip.internal.createSubsystemReferenceInstancesPopup(blockHandle,eventDataNamespace,eventDataType,'subsystemBlock');
        else
            gw=dig.GeneratedWidget(eventDataNamespace,eventDataType);
        end
    end
end