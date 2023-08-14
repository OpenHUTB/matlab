classdef TankVolumeSpec<int32




    enumeration
        Constant(1)
        Table(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Constant')='Constant cross-section area';
            map('Table')='Tabulated data - volume vs. level';
        end
    end
end