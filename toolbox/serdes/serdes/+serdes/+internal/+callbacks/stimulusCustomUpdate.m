




function stimulusCustomUpdate(block)
    customStimulusEnable=get_param(block,'CustomStimulusEnable');
    if strcmp(customStimulusEnable,'on')

        set_param(block,'MaskVisibilities',[{'on'},'on','on','on','on',repmat({'off'},1,12)]);
        set_param(block,'MaskEnables',[{'off'},'on','on','on','on',repmat({'off'},1,12)]);
    else
        set_param(block,'MaskVisibilities',[{'on'},'on','on','off','on',repmat({'off'},1,12)]);
        set_param(block,'MaskEnables',[{'on'},'on','on','off','on',repmat({'off'},1,12)]);
    end
end