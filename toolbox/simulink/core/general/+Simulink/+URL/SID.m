




classdef SID<Simulink.URL.Hilitable
    methods
        function h=SID(id)

            h=h@Simulink.URL.Hilitable(id,[],[]);
        end
        function out=isHilitable(h)%#ok<MANU>
            out=true;
        end
        function out=getHandle(h)
            out=Simulink.ID.getHandle(h.URLstr);
        end
        function out=eval(h)
            load_system(h.Model);
            out=Simulink.ID.getHandle(h.URLstr);
        end
    end
    methods(Access=protected)
        function hiliteImpl(h)
            Simulink.ID.hilite(h.URLstr);
        end
    end
end
