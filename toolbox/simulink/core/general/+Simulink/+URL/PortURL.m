




classdef PortURL<Simulink.URL.Hilitable
    methods
        function h=PortURL(parent,portKind,portIdx)
            try
                portKind=eval(['Simulink.URL.URLKind.',portKind]);
            catch me
                if strcmp(me.identifier,'MATLAB:subscripting:classHasNoPropertyOrMethod')
                    DAStudio.error('Simulink:utility:URLInvalidKind',portKind);
                end
                rethrow(me);
            end
            if nargin<3
                portIdx=1;
            end
            if ischar(portIdx)
                portIdx=str2double(portIdx);
            end
            if~isscalar(portIdx)||isnan(portIdx)||...
                floor(portIdx)~=portIdx||portIdx<1
                DAStudio.error('Simulink:utility:URLInvalidPortIndex',...
                num2str(portIdx));
            end
            h=h@Simulink.URL.Hilitable(parent,portKind,num2str(portIdx));
            h.HiliteScheme='lineTrace';
        end
        function out=getHandle(h)
            portH=get_param(h.Parent,'PortHandles');
            portIdx=str2double(h.ObjId);
            switch h.ObjKind
            case Simulink.URL.URLKind.in
                out=portH.Inport(portIdx);
            case Simulink.URL.URLKind.out
                out=portH.Outport(portIdx);
            case Simulink.URL.URLKind.enable
                out=portH.Enable(portIdx);
            case Simulink.URL.URLKind.trigger
                out=portH.Trigger(portIdx);
            case Simulink.URL.URLKind.ifaction
                out=portH.Ifaction(portIdx);
            case Simulink.URL.URLKind.state
                out=portH.State(portIdx);
            case Simulink.URL.URLKind.lconn
                out=portH.LConn(portIdx);
            case Simulink.URL.URLKind.rconn
                out=portH.RConn(portIdx);
            end
        end
        function out=isHilitable(h)%#ok<MANU>
            out=true;
        end
        function out=eval(h)
            load_system(h.Model);
            out=h.getHandle;
        end
        function out=getIndex(h)
            out=str2double(h.ObjId);
        end
    end
    methods(Access=protected)
        function hiliteImpl(h)
            hilite_system(h.getHandle,h.HiliteScheme);
            hilite_system(get_param(h.Parent,'Handle'),h.HiliteScheme);
        end
    end
end
