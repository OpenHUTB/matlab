classdef Fluid<int32





    enumeration
        Water(1)
        R134a(2)
        R1234yf(3)
        R404a(4)
        R410a(5)
        R407c(6)
        R22(7)
        Ammonia(8)
        CarbonDioxide(9)
        Isobutane(10)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Water')='Water (R-718)';
            map('R134a')='R-134a';
            map('R1234yf')='R-1234yf';
            map('R404a')='R-404a';
            map('R410a')='R-410a';
            map('R407c')='R-407c';
            map('R22')='R-22';
            map('Ammonia')='Ammonia (R-717)';
            map('CarbonDioxide')='Carbon dioxide (R-744)';
            map('Isobutane')='Isobutane (R-600a)';
        end
    end
end