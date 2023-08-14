classdef(Hidden)AeroRPMIndicatorController<Aero.ui.control.internal.controller.AeroController





    methods
        function obj=AeroRPMIndicatorController(varargin)
            obj=obj@Aero.ui.control.internal.controller.AeroController(varargin{:});
            obj.NumericProperties=[obj.NumericProperties,'RPM'];
        end
    end
end