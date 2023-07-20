classdef Mf0Data<handle




    properties(Hidden)

        ConstellationMap containers.Map
    end

    methods(Access=?evolutions.internal.session.SessionManager)
        function obj=Mf0Data
            obj.ConstellationMap=containers.Map;
        end
    end

    methods
        output=getConstellation(obj,evolutionTree);
        addConstellation(obj,evolutionTree,constellation);
        removeConstellation(obj,evolutionTree);
        output=hasConstellation(obj,evolutionTree);
    end

    methods(Static=true,Access=private)
        validateConstellationMapInput(evolutionTree);
    end
end


