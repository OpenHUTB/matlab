function dpiassertblkcb(block,action)




    Enabled=get_param(block,'Enabled');
    Severity=get_param(block,'DPIAssertSeverity');
    AssertMsg=get_param(block,'DPIAssertFailMessage');
    CustomCmd=get_param(block,'DPIAssertCustomCommand');

    Vals=get_param(block,'masknames');
    Vis=get_param(block,'maskvisibilities');
    En=get_param(block,'maskenables');

    NamesOfWidgetsOfInterest={'AssertionFailFcn','StopWhenAssertionFail','DPIAssertSeverity',...
    'DPIAssertFailMessage','DPIAssertCustomCommand'};
    switch action
    case 'init'

        n_init();
    case 'enablecb'

        n_DisableOrEnableBasedOnEnableCheckBox();
    case 'severitycb'

        n_setDPIAssertTxtBoxVisibility();
    case 'dpiassertmsgcb'
        n_VerifyMessageIsValid();
    case 'dpiassertcustomcmdcb'
        n_VerifyCommandIsValid();
    end

    set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);



    function n_init()

        n_VerifyMessageIsValid();
        n_VerifyCommandIsValid();



        n_setDPIAssertTxtBoxVisibility();

        n_DisableOrEnableBasedOnEnableCheckBox();
    end

    function n_DisableOrEnableBasedOnEnableCheckBox()
        if strcmp(Enabled,'off')

            for ParamNames=NamesOfWidgetsOfInterest
                ParamKey=ParamNames{1};
                index=find(ismember(Vals,ParamKey));
                if strcmp(Vis{index},'on')
                    En{index}='off';
                end
            end
        else

            for ParamNames=NamesOfWidgetsOfInterest
                ParamKey=ParamNames{1};
                index=find(ismember(Vals,ParamKey));
                if strcmp(Vis{index},'on')
                    En{index}='on';
                end
            end
        end
    end


    function n_setDPIAssertTxtBoxVisibility()
        if strcmp(Severity,'custom')

            index=find(ismember(Vals,'DPIAssertFailMessage'));
            En{index}='off';
            Vis{index}='off';

            index=find(ismember(Vals,'DPIAssertCustomCommand'));
            if strcmp(Enabled,'on')
                En{index}='on';
            end
            Vis{index}='on';
        else

            index=find(ismember(Vals,'DPIAssertCustomCommand'));
            En{index}='off';
            Vis{index}='off';

            index=find(ismember(Vals,'DPIAssertFailMessage'));
            if strcmp(Enabled,'on')
                En{index}='on';
            end
            Vis{index}='on';
        end

    end

    function n_VerifyMessageIsValid()
        l_verifyNoUnescapedDoubleQuotes(AssertMsg,block,'DPIAssertFailMessage');
        l_verifyAllCharacterAreASCII(AssertMsg,block,'DPIAssertFailMessage');
    end

    function n_VerifyCommandIsValid()
        l_verifyAllCharacterAreASCII(CustomCmd,block,'DPIAssertCustomCommand');
    end
end

function l_verifyNoUnescapedDoubleQuotes(str,Block,DPIParameter)
    if count(str,'"')~=count(str,'\"')
        set_param(Block,DPIParameter,'');
        error(message('HDLLink:DPIG:NeedToEscapeAllDoubleQuotes'));
    end
end

function l_verifyAllCharacterAreASCII(str,Block,DPIParameter)
    if any(double(str)>127)
        set_param(Block,DPIParameter,'');
        error(message('HDLLink:DPIG:AssertStringShouldOnlyContainASCII',DPIParameter));
    end
end
