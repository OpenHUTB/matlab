function system=hilitedSystem(varargin)




    persistent last_system

    if nargin>0
        last_system=varargin{1};
    end

    if~isempty(last_system)
        system=last_system;
    else
        system={};
    end
