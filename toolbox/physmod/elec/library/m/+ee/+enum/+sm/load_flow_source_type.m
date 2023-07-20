classdef load_flow_source_type<int32




    enumeration
        Swing(1)
        PV(2)
        PQ(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Swing')='physmod:ee:library:comments:enum:sm:load_flow_source_type:map_SwingBus';
            map('PV')='physmod:ee:library:comments:enum:sm:load_flow_source_type:map_PVbus';
            map('PQ')='physmod:ee:library:comments:enum:sm:load_flow_source_type:map_PQbus';
        end
    end
end