classdef LegendInfoChild<handle&matlab.mixin.SetGet



    properties
        ConstructorName;

        PVPairs;

        GlyphChildren matlab.graphics.illustration.legend.LegendInfoChild;
    end

    methods
        function hObj=LegendInfoChild(varargin)

            set(hObj,varargin{:});
        end
    end
end
