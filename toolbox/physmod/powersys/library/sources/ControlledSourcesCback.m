function ControlledSourcesCback(block)







    initsrc=get_param(block,'Initialize');
    if strcmp(initsrc,'on'),
        Source_Type=get_param(block,'Source_Type');
        initsrc=get_param(block,'Initialize');
        if strcmp(Source_Type,'AC')
            set_param(block,'MaskVisibilities',{'on','on','on','on','on','on'});
        else
            set_param(block,'MaskVisibilities',{'on','on','on','off','off','on'});
        end
    else
        set_param(block,'MaskVisibilities',{'on','off','off','off','off','on'});
    end