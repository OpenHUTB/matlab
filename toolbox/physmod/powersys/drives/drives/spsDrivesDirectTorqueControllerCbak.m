

function[]=spsDrivesDirectTorqueControllerCbak(block)






    modulationType=get_param(block,'modulationType');

    switch modulationType

    case 'Hysteresis'


        variant='Detailed';
        if~isequal(get_param(block,'LabelModeActiveChoice'),variant)
            set_param(block,'LabelModeActiveChoice',variant);
        end

        maskEnables={...

        'on',...
        'on',...
        'off',...
        'off',...
        'on',...
        'off',...
        'off',...
        'on',...
        'on',...
        'on',...
        'off',...
        'off',...
        'on',...
        'on',...
        'on',...
        };
        maskVisibilities={...

        'on',...
        'on',...
        'off',...
        'off',...
        'on',...
        'off',...
        'off',...
        'on',...
        'on',...
        'on',...
        'off',...
        'off',...
        'on',...
        'on',...
        'on',...
        };
    case 'SVM'


        variant='Detailed_SVM';
        if~isequal(get_param(block,'LabelModeActiveChoice'),variant)
            set_param(block,'LabelModeActiveChoice',variant);
        end

        maskEnables={...

        'on',...
        'off',...
        'on',...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        };
        maskVisibilities={...

        'on',...
        'off',...
        'on',...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        'off',...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        };
    end




    if sps_Authoring(bdroot(block))
        set_param(block,'MaskEnables',maskEnables);
    end
    set_param(block,'MaskVisibilities',maskVisibilities);