function resourceUsage=generateResourceUsage(~,~,~)
    resourceUsage=[];
    if~hdlgetparameter('resourceReport')
        return;
    end

