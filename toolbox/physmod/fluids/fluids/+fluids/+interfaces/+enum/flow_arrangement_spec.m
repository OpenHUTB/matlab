classdef flow_arrangement_spec<int32




    enumeration
        parallel_counter(1)
        shell_tube(2)
        cross_flow(3)
        effectiveness_table(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('parallel_counter')='Parallel or counter flow';
            map('shell_tube')='Shell and tube';
            map('cross_flow')='Cross flow';
            map('effectiveness_table')='Generic - effectiveness table';
        end
    end
end