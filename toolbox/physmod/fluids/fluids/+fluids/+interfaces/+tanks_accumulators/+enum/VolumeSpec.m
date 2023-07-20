classdef VolumeSpec<int32




    enumeration
        Constant(1)
        Tabulated(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Constant')='Constant cross-sectional area';
            map('Tabulated')='Tabulated data - Volume vs. level';
        end
    end
end