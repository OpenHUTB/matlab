classdef LegendInfo<handle&matlab.mixin.SetGet




    properties
        GObject matlab.graphics.Graphics;

        GlyphWidth;

        GlyphHeight;

        GlyphChildren matlab.graphics.illustration.legend.LegendInfoChild;
    end

    methods
        function hObj=LegendInfo(varargin)

            set(hObj,varargin{:});
        end
    end
    methods
        function set.GObject(obj,value)
            if isa(value,'double')
                obj.GObject=handle(value);
            else
                obj.GObject=value;
            end
        end
    end
end
