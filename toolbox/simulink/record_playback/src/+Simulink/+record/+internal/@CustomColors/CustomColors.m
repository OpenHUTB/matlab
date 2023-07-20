classdef CustomColors



    properties

        XYLineColor;
        XYMarkerBorderColor;
        XYMarkerFillColor;

    end


    methods


        function obj=CustomColors()
            obj.XYLineColor=[0.3,0.5,0.7];
            obj.XYMarkerBorderColor=[0,0,0];
            obj.XYMarkerFillColor=[1,0.8,0.8];
        end

    end

end


