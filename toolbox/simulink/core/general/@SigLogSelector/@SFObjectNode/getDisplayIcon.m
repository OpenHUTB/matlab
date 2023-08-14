function val=getDisplayIcon(h)




    val=h.userData.displayIcon;
    if isempty(val)&&(isa(h.daobject,'DAStudio.Object')||isa(h.daobject,'Simulink.DABaseObject'))
        val=h.daobject.getDisplayIcon;
        h.userData.displayIcon=val;
    end

end
