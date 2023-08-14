




classdef ParamURL<Simulink.URL.Base

    methods
        function h=ParamURL(parent,name)
            h=h@Simulink.URL.Base(parent,Simulink.URL.URLKind.param,name);
        end
        function out=eval(h)

            load_system(h.Model);
            out=get_param(h.Parent,h.ObjId);

            paramlist=get_param(h.Parent,'ObjectParameters');
            if~isfield(paramlist,h.ObjId)
                DAStudio.error('Simulink:utility:URLCaseSensitive',h.URLstr);
            end
        end
        function out=isHilitable(h)%#ok<MANU>
            out=false;
        end
    end
end
