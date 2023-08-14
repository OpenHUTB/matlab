classdef ColorOrderMixin<matlab.graphics.chartcontainer.mixin.Mixin


    properties(AffectsObject,Access=protected)
        ColorOrderInternal matlab.internal.datatype.matlab.graphics.datatype.ColorOrder=get(groot,'FactoryAxesColorOrder');
    end

    methods(Abstract,Access=protected)
        c=setColorOrderInternal(obj,colors)
    end

    methods(Hidden)
        function validateAndSetColorOrderInternal(obj,colors)
            if strcmp(colors,'default')
                colors=get(groot,'DefaultAxesColorOrder');
            elseif strcmp(colors,'factory')
                colors=get(groot,'FactoryAxesColorOrder');
            end
            classes={'numeric'};
            attribute={'ncols',3,'real','nonsparse','2d'};
            validateattributes(colors,classes,attribute);
            obj.ColorOrderInternal=colors;
            obj.setColorOrderInternal(colors);
        end

        function c=getColorOrder(obj)
            c=obj.ColorOrderInternal;
        end
    end
end
