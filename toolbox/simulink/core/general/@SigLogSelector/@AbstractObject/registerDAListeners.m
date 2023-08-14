function registerDAListeners(h)
    obj=h.daobject;
    while~isempty(obj)&&~isa(obj,"Simulink.BlockDiagram")
        obj=obj.getParent;
    end
    if isa(obj,'Simulink.BlockDiagram')
        obj.registerDAListeners;
    end
end