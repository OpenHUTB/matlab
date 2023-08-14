classdef load_flow_source_type<int32




    enumeration
        Time(1)
        Swing(2)
        PV(3)
        PQ(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Time')='physmod:ee:library:comments:enum:sources:load_flow_source_type:map_Time';
            map('Swing')='physmod:ee:library:comments:enum:sources:load_flow_source_type:map_SwingBus';
            map('PV')='physmod:ee:library:comments:enum:sources:load_flow_source_type:map_PVbus';
            map('PQ')='physmod:ee:library:comments:enum:sources:load_flow_source_type:map_PQbus';
        end
    end
end