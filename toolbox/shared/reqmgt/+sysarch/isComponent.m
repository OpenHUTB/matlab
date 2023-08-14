function tf=isComponent(hdlOrSid)

    tf=false;
    try
        obj=get_param(hdlOrSid,'Object');
        isArchDomain=Simulink.internal.isArchitectureModel(bdroot(obj.Handle));
        if isArchDomain
            if isa(obj,'Simulink.SubSystem')&&strcmp(obj.SimulinkSubDomain,'ArchitectureAdapter')

                tf=false;
            elseif isa(obj,'Simulink.Annotation')

                tf=false;
            elseif isa(obj,'Simulink.Port')
                tf=false;
            else
                tf=true;
            end
        end
    catch ex %#ok<NASGU>
        tf=false;
    end
end
