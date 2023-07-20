function status=getStatus(obj,cs,varargin)




    dep=obj.Dependency;
    if~isempty(dep)
        if~isa(cs,'Simulink.ConfigSet')
            if isa(cs,'Simulink.ConfigSetRef')
                cs=cs.LocalConfigSet;
            elseif~isempty(cs.getConfigSet)
                cs=cs.getConfigSet;
            end
        end
        if nargin>=3
            status=dep.getStatus(cs,obj.Name,varargin{1});
        else
            status=dep.getStatus(cs,obj.Name);
        end
    else
        status=0;
    end

