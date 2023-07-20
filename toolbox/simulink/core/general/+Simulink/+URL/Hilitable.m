classdef Hilitable<Simulink.URL.Base




    properties(Access=protected)
        HiliteScheme='find'
    end
    methods
        function h=Hilitable(parent,objKind,objId)
            h=h@Simulink.URL.Base(parent,objKind,objId);
        end
        function hilite(h)
            if~h.isHilitable
                DAStudio.error('Simulink:utility:URLNotHilitable',char(h));
            end
            h.hiliteImpl;
            Simulink.URL.setHilited(h.URLstr);
        end
        function out=isHilitable(h)%#ok<MANU>
            out=true;
        end
    end
    methods(Access=protected)
        function hiliteImpl(h)
            hilite_system(h.getHandle,h.HiliteScheme);
        end
    end
end

