





classdef ActiveContourSpeed




    methods(Abstract=true)

        speed=calculateSpeed(obj,I,phi,pixIdx)

    end







    methods

        function obj=initalizeSpeed(obj,~,~)

        end

        function obj=updateSpeed(obj,~,~,~)

        end

    end

end