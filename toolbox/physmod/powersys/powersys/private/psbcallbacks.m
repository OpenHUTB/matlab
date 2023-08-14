function varargout=psbcallbacks(block,flag,~)





    if nargout==1
        varargout{1}=0;
    end

    system=bdroot(block);

    if strcmp(get_param(system,'BlockDiagramType'),'library')
        return
    end

    switch flag

    case 'Discrete Gamma Measurement'

        WantInterpol=strcmp(get_param(block,'Interpolation'),'on');
        if WantInterpol
            visible={'on','on','on','on','on','on'};
            set_param(block,'MaskVisibilities',visible)
        else
            visible={'on','on','on','on','off','on'};
            set_param(block,'MaskVisibilities',visible)
        end

    case 'Discrete PWM Generator'

        ports=get_param(block,'ports');
        External=(ports(1)==1);
        WantInternal=strcmp(get_param(block,'Internal'),'on');
        if WantInternal&&External
            visible={'on','on','on','on','on','on','on'};
            replace_block(block,'Followlinks','on','Name','Uref','BlockType','Inport','Ground','noprompt');
            set_param(block,'MaskVisibilities',visible)
        elseif~WantInternal&&~External
            visible={'on','on','on','on','off','off','off'};
            replace_block(block,'Followlinks','on','Name','Uref','BlockType','Ground','Inport','noprompt');
            set_param(block,'MaskVisibilities',visible)
        end

    case 'PWM Generator'

        ports=get_param(block,'ports');
        External=(ports(1)==1);
        WantInternal=strcmp(get_param(block,'Internal'),'on');
        if WantInternal&&External
            visible={'on','on','on','on','on','on'};
            replace_block(block,'Followlinks','on','Name','Signal(s)','BlockType','Inport','Ground','noprompt');
            set_param(block,'MaskVisibilities',visible)
        elseif~WantInternal&&~External
            visible={'on','on','on','off','off','off'};
            replace_block(block,'Followlinks','on','Name','Signal(s)','BlockType','Ground','Inport','noprompt');
            set_param(block,'MaskVisibilities',visible)
        end

    case 'Discrete 3-phase PWM Generator'

        WantInternal=strcmp('on',get_param(block,'ModulatingSignals'));
        WantSynchronized=strcmp('Synchronized',get_param(block,'ModulatorMode'));
        Uref_IsInport=strcmp('Inport',get_param([block,'/Uref'],'BlockType'));
        wt_IsInport=strcmp('Inport',get_param([block,'/wt'],'BlockType'));

        if WantInternal
            param6='on';
            param7='on';
            param8='on';
        else
            param6='off';
            param7='off';
            param8='off';
        end
        if WantSynchronized
            param3='on';
            param4='off';
            param5='off';
            param6='off';
            param7='off';
            param8='off';
        else
            param3='off';
            param4='on';
            param5='on';
        end
        visible={'on','on',param3,param4,param5,param6,param7,param8,'on'};
        set_param(block,'MaskVisibilities',visible);

        if WantSynchronized
            if~Uref_IsInport
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Uref','BlockType','Ground','Inport','noprompt');
            end
            if~wt_IsInport
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name','wt','BlockType','Ground','Inport','noprompt');
            end
        else
            if wt_IsInport
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name','wt','BlockType','Inport','Ground','noprompt');
            end
            if WantInternal
                if Uref_IsInport
                    replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Uref','BlockType','Inport','Ground','noprompt');
                end
            else
                if~Uref_IsInport
                    replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Uref','BlockType','Ground','Inport','noprompt');
                end
            end
        end

    case 'SteamTurbine'

        gentype=get_param(block,'gentype');

        switch gentype
        case 'Tandem-compound (single mass)'
            visib='on,on,on,on,on,on,on,off,off,off,on,off';
        case 'Tandem-compound (multi-mass)'
            visib='on,on,on,on,on,on,on,on,on,on,off,on';
        end
        set_param(block,'MaskVisibilityString',visib);

    end