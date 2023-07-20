function val=getDisplayIcon(h)





    val='';


    if isa(h.daobject,'DAStudio.Object')||isa(h.daobject,'Simulink.DABaseObject')
        val=h.daobject.getDisplayIcon;
    end

end
