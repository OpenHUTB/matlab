function out=getDisplayString(faultInfoObj)
    if isa(faultInfoObj,'Simulink.fault.Fault')
        out=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',faultInfoObj.Name,faultInfoObj.ModelElement));
    else
        out=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:ConditionalFullDisplayLabel',faultInfoObj.getTopModelName(),faultInfoObj.Name));
    end
end