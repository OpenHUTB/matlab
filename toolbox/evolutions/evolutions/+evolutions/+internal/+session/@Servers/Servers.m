classdef Servers<handle





    properties(Hidden)

        ServerMap containers.Map
    end

    methods(Access=?evolutions.internal.session.SessionManager)
        function obj=Servers
            obj.ServerMap=containers.Map;
        end
    end

    methods
        output=getServer(obj,evolutionTreeId);
        addServer(obj,evolutionTreeId,server);
        removeServer(obj,evolutionTreeId);
        output=hasServer(obj,evolutionTreeId);
    end
end
