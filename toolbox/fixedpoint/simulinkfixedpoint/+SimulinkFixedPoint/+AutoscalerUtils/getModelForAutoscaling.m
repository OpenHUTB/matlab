function mdl=getModelForAutoscaling(bd)

    if isa(bd,'Simulink.SubSystem')
        mdl=bdroot(bd.getFullName);
    else
        mdl=bd.getFullName;
    end
end