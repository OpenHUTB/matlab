classdef(Hidden)AeroHeadingIndicatorController<Aero.ui.control.internal.controller.AeroController





    methods
        function obj=AeroHeadingIndicatorController(varargin)
            obj=obj@Aero.ui.control.internal.controller.AeroController(varargin{:});
            obj.NumericProperties=[obj.NumericProperties,'Heading'];
        end
    end
end