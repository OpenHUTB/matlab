function intelProcessors=getIntelProcessors()
    processors=target.internal.get('Processor');
    intelProcessors={};
    idx=0;
    for i=1:length(processors)
        if contains(processors(i).Name,'Intel','IgnoreCase',true)||...
            strcmpi(processors(i).Manufacturer,'Intel')
            idx=idx+1;
            intelProcessors{idx}=processors(i);
        end
    end
end