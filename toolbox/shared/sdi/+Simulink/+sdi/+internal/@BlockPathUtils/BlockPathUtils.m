






classdef BlockPathUtils<Simulink.SimulationData.BlockPath


    methods(Static)


        function bpath=createSignalPath(path)


            bpath=Simulink.SimulationData.BlockPath;
            bpath.path=path;
        end

    end

end
