function priority=getDefaultRTOSRatePriority(h,supportedos)




    if any(cellfun(@(x)(strcmp(x.label,'DSP/BIOS')),supportedos))
        priority=7;
    else
        priority=40;
    end