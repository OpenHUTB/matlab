function label=getDisplayLabel(h)






    label='';

    if isa(h.daobject,'DAStudio.Object')||...
        isa(h.daobject,'Simulink.DABaseObject')||...
        isa(h.daobject,'Simulink.ModelReference')
        label=h.daobject.getDisplayLabel;
    end

end
