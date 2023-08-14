



classdef(ConstructOnLoad)BackgroundColorChangeEventData<event.EventData
    properties
Color
GradientColor
UseGradient
    end

    methods
        function data=BackgroundColorChangeEventData(c,gradColor,useGrad)
            data.Color=c;
            data.GradientColor=gradColor;
            data.UseGradient=useGrad;
        end
    end
end
