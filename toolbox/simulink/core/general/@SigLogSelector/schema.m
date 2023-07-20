function schema




    schema.package('SigLogSelector');

    if isempty(findtype('SigLogSelectorTriStateEnum'))
        schema.EnumType('SigLogSelectorTriStateEnum',...
        {'checked','unchecked','partial'});
    end

    if isempty(findtype('SigLogHasLoggingEnum'))
        schema.EnumType('SigLogHasLoggingEnum',...
        {'yes','no','unknown'});
    end

end
