function ret=getDisplayName(dd,ddEntry)



    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    ret=cell(size(ddEntry));
    for i=1:length(ddEntry)
        d=ddEntry(i);
        className=hlp.getClassName(d);
        if strcmp(className,'LegacyStorageClass')||...
            strcmp(className,'LegacyMemorySection')
            package=hlp.getProp(d,'Package');
            if strcmp(package,'SimulinkBuiltin')
                ret{i}=d.Name;
            else
                ret{i}=hlp.getProp(d,'DisplayName');
            end
        else
            ret{i}=d.Name;
        end
    end

    if length(ddEntry)==1
        ret=ret{1};
    else
        ret=ret';
    end
end
