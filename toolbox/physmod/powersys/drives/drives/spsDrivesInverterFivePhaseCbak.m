function[]=spsDrivesInverterFivePhaseCbak(block,cbakMode)

    detailLevel=get_param(block,'detailLevel');

    maskObj=Simulink.Mask.get(block);
    machineGroup=maskObj.getDialogControl('machineGroup');
    inverterGroup=maskObj.getDialogControl('inverterGroup');

    switch detailLevel
    case 'Detailed'
        if~isequal(get_param(block,'LabelModeActiveChoice'),detailLevel)
            set_param(block,'LabelModeActiveChoice',detailLevel);
        end

        deviceType=get_param(block,'Device');
        internalBlock=[block,'/Detailed'];


        inverterGroup.Visible='on';


        machineGroup.Visible='off';

        switch cbakMode
        case 'init'


            for k=1:5
                internalBlock2=[internalBlock,'/Universal Bridge',num2str(k)];
                set_param(internalBlock2,'Device',deviceType);
                set_param(internalBlock2,'Measurements',get_param(block,'Measurements'));
            end
        end

        switch deviceType
        case 'MOSFET / Diodes'
            forwardVoltages='off';
            fallTailTimeGto='off';
            fallTailTimeIgbt='off';
        case 'GTO / Diodes'
            forwardVoltages='on';
            fallTailTimeGto='on';
            fallTailTimeIgbt='off';
            switch cbakMode
            case 'init'


                set_param(block,'ForwardVoltages',get_param(block,'ForwardVoltages'));
                set_param(block,'GTOparameters',get_param(block,'GTOparameters'));
            end
        case 'IGBT / Diodes'
            forwardVoltages='on';
            fallTailTimeGto='off';
            fallTailTimeIgbt='on';
            switch cbakMode
            case 'init'


                set_param(block,'ForwardVoltages',get_param(block,'ForwardVoltages'));
                set_param(block,'IGBTparameters',get_param(block,'IGBTparameters'));
            end
        otherwise
            error(message('physmod:powersys:common:InvalidParameter',block,deviceType,'Power electronic device'));
        end

        maskEnables={...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        forwardVoltages,...
        fallTailTimeGto,...
        fallTailTimeIgbt,...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        };
        maskVisibilities=maskEnables;

    case 'Average'
        if~isequal(get_param(block,'LabelModeActiveChoice'),detailLevel)
            set_param(block,'LabelModeActiveChoice',detailLevel);
        end


        inverterGroup.Visible='on';


        machineGroup.Visible='on';

        maskEnables={...
        'on',...
        'on',...
        'off',...
        'off',...
        'off',...
        'on',...
        'off',...
        'off',...
        'off',...
        'off',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        };
        maskVisibilities=maskEnables;

    otherwise
        error(message('physmod:powersys:common:InvalidParameter',block,detailLevel,'Model detail level'));
    end
    if sps_Authoring(bdroot(block))
        set_param(block,'MaskEnables',maskEnables);
    end
    set_param(block,'MaskVisibilities',maskVisibilities);