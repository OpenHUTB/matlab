



function h=getConfigSet(this)
    obj=get_param(this.model,'Object');

    if isa(obj,'Simulink.SubSystem')
        obj=bdroot(obj.getFullName);
    end
    h=getActiveConfigSet(obj);
end
