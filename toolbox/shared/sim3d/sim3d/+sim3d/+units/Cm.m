classdef Cm<sim3d.units.One

    methods
        function value=get(~,variable)

            value=100*variable;
        end


        function value=set(~,variable)

            value=0.01*variable;
        end
    end
end

