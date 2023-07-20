classdef InteractionBase<handle&matlab.mixin.Heterogeneous


    properties
        Axes{mustBe_matlab_graphics_axis_AbstractAxes}
Figure
    end

    properties
        strategy=matlab.graphics.interaction.uiaxes.InteractionStrategy;
    end
end


function mustBe_matlab_graphics_axis_AbstractAxes(input)
    if~isa(input,'matlab.graphics.axis.AbstractAxes')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropSetClsMismatch','%s',message('MATLAB:type:PropSetClsMismatch','matlab.graphics.axis.AbstractAxes').getString));
    end
end
