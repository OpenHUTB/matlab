function yesno=isLinkingForFaultObjAllowed(obj)
    yesno=false;
    if isa(obj,'Simulink.fault.Fault')||isa(obj,'faultinfo.Fault')
        yesno=true;
    elseif isa(obj,'Simulink.fault.Conditional')||isa(obj,'faultinfo.conditional.Conditional')
        yesno=true;
    end
end