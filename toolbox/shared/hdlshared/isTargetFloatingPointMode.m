function fpMode=isTargetFloatingPointMode()
    fpMode=~isempty(hdlgetparameter('FloatingPointTargetConfiguration'));
end

