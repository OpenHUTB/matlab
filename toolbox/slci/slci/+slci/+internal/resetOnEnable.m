function reset=resetOnEnable(obj)


    reset=0;
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    blocks=obj.getCompiledBlockList;
    for i=1:numel(blocks)
        if strcmpi(get_param(blocks(i),'BlockType'),'EnablePort')||...
            strcmpi(get_param(blocks(i),'BlockType'),'TriggerPort')
            if strcmpi(get_param(blocks(i),'StatesWhenEnabling'),'reset')
                reset=1;
            end
            break;
        elseif strcmpi(get_param(blocks(i),'BlockType'),'ActionPort')
            if strcmpi(get_param(blocks(i),'InitializeStates'),'reset')
                reset=1;
            end
            break;
        elseif strcmpi(get_param(blocks(i),'BlockType'),'ForIterator')
            if strcmpi(get_param(blocks(i),'ResetStates'),'reset')
                reset=1;
            end
        elseif strcmpi(get_param(blocks(i),'BlockType'),'ForEach')
            if strcmpi(get_param(blocks(i),'StateReset'),'reset')
                reset=1;
            end
        elseif strcmpi(get_param(blocks(i),'BlockType'),'WhileIterator')
            if strcmpi(get_param(blocks(i),'ResetStates'),'reset')
                reset=1;
            end
        end
    end
end
