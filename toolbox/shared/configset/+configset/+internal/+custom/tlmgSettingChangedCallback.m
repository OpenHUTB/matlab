function updateDeps=tlmgSettingChangedCallback(cs,msg)




    updateDeps=true;

    if~isempty(cs.get_param('tlmgTbExeDir'))
        hWarnDlg=warndlg(...
        ['Any changes to the TLM generator parameters will invalidate ',...
        'the generated testbench.',newline,newline,...
        'Click ''Cancel'' if you want to execute the testbench using the ''Verify TLM Component'' button.',newline,newline,...
        'Click ''Apply'' if you want to generate a new component and testbench.'],...
        'TLM Testbench Will Be Invalidated','modal');

        set(hWarnDlg,'tag','tlmg warning dialog');
        setappdata(hWarnDlg,'warnId','TLMGenerator:TLMTargetCC:AboutToInvalidateTb');

        cs.set_param('tlmgTbExeDir','');
    end

    if isa(cs,'Simulink.ConfigSet')
        rtw=cs.getComponent('Code Generation');
        hObj=rtw.getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        hObj=cs.getComponent('Target');
    else
        hObj=cs;
    end

    if strcmp(msg.data.Type,'boolean')&&~ischar(msg.value)
        if msg.value
            msg.value='on';
        else
            msg.value='off';
        end
    end

    chg=hObj.getDependentChanges(msg.name,msg.value);
    if(isfield(chg,'val'))
        for fnames=fieldnames(chg.val)'
            propName=fnames{:};
            cs.set_param(propName,chg.val.(propName));
        end
    end

