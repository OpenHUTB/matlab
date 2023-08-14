function fpMode=isTargetFloatingPointMode(obj)





    if obj.isMLHDLC
        fpMode=isTargetFloatingPointMode;
    else
        fpMode=~isempty(hdlget_param(obj.getModelName,'FloatingPointTargetConfiguration'));
    end

end