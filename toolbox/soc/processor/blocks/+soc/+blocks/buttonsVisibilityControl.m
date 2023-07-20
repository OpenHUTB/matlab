function buttonsVisibilityControl(CurrentBlock,ParameterName)



    if~ismember({'SimulationOutput','SendSimulationInputTo'},ParameterName)
        error('Invalid value for BlockType. Valid values can be, ''SourceSystem'',''SinkSystem''.');
    end

    PropNames=get_param(CurrentBlock,'MaskNames');
    if any(ismember(PropNames,'SimulationOutput'))
        ButtonsVisibility=isequal(get_param(CurrentBlock,'SimulationOutput'),'From recorded file');
    elseif any(ismember(PropNames,'SendSimulationInputTo'))
        ButtonsVisibility=isequal(get_param(CurrentBlock,'SendSimulationInputTo'),'Data file');
    else
        ButtonsVisibility=[];
    end

    if~isempty(ButtonsVisibility)
        mobj=Simulink.Mask.get(CurrentBlock);

        dlgbrowser=getDialogControl(mobj,'browser');
        dlgsourceselector=getDialogControl(mobj,'sourceSelector');

        if~isempty(dlgbrowser)
            if ButtonsVisibility
                dlgbrowser.Visible='on';
            else
                dlgbrowser.Visible='off';
            end
        end

        if~isempty(dlgsourceselector)
            if ButtonsVisibility
                dlgsourceselector.Visible='on';
            else
                dlgsourceselector.Visible='off';
            end
        end
    end

end

