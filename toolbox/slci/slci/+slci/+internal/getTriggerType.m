

function triggerType=getTriggerType(obj)

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    blocks=obj.getCompiledBlockList;
    for i=1:numel(blocks)
        if strcmpi(get_param(blocks(i),'BlockType'),'TriggerPort')
            triggerType=get_param(blocks(i),'TriggerType');
            break;
        end
    end
end
