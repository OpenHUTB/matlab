classdef FlowGeometryTL<int32




    enumeration
        InsideTubes(1)
        AcrossTubeBank(2)
        Generic(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('InsideTubes')='Flow inside one or more tubes';
            map('AcrossTubeBank')='Flow perpendicular to bank of circular tubes';
            map('Generic')='Generic';
        end
    end
end