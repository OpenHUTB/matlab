classdef ColorSpecToRGBConverter<matlab.graphics.mixin.internal.GraphicsDataTypeContainer

    properties(Access='private')
        colorSpecMap matlab.internal.datatype.matlab.graphics.datatype.ColorTable
    end

    methods

        function self=ColorSpecToRGBConverter

        end

        function rgb=convertColorSpec(self,colorSpec)

            if ischar(colorSpec)||isstring(colorSpec)
                colorSpec=validatestring(colorSpec,fields(self.colorSpecMap));
                rgb=self.colorSpecMap.(colorSpec);
            else
                validateattributes(colorSpec,{'single','double'},...
                {'real','vector','numel',3,'>=',0,'<=',1},mfilename,'Color');
                rgb=colorSpec;
            end

        end

    end

end
