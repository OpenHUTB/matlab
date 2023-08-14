classdef(Hidden)AeroClimbIndicatorController<Aero.ui.control.internal.controller.AeroController





    methods
        function obj=AeroClimbIndicatorController(varargin)
            obj=obj@Aero.ui.control.internal.controller.AeroController(varargin{:});
            obj.NumericProperties=[obj.NumericProperties,'ClimbRate','MaximumRate'];
        end
    end
end