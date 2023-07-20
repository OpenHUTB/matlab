function ThreePhaseHarmonicFilterCback(block)






    FilterType=get_param(block,'FilterType');
    if strcmp(FilterType,'Double-tuned');
        visible={'on','on','on','on','off','on','on','on'};
    else
        visible={'on','on','on','on','on','off','on','on'};
    end
    set_param(block,'MaskVisibilities',visible);

    WantYn=strcmp(get_param(block,'FilterConnection'),'Y (neutral)');
    ports=get_param(block,'ports');
    External=(ports(7)==1);
    if WantYn&~External
        set_param(block,'RConntags',{'n'});
    elseif~WantYn&External
        set_param(block,'RConntags',{});
    end