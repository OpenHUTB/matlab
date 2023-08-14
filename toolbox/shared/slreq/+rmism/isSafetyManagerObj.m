function yesno=isSafetyManagerObj(obj)
    if isa(obj,'sm.internal.SafetyManagerNode')
        yesno=true;
    else
        yesno=false;
    end
end
