classdef(Sealed,Hidden)HdlLinkInstance<hgsetget


    properties
        tnext;
        userdata;
    end
    properties(SetAccess='private')
        simstatus;
        instance;
        argument;
        portinfo;
        tscale;
        tnow;
        portvalues;
        linkmode;
    end
    methods(Hidden)
        function obj=HdlLinkInstance()
            obj.portvalues=HdlLinkPorts;
        end
        function disp(obj)
            disp(get(obj));
        end
        function delete(obj)
            delete(obj.portvalues);

        end
    end

end
