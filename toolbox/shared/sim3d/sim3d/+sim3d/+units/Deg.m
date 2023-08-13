classdef Deg<sim3d.units.One


    methods
        function value=get(~,variable)

            value=rad2deg(variable);
        end

        function value=set(~,variable)

            value=deg2rad(variable);
        end
    end
end

