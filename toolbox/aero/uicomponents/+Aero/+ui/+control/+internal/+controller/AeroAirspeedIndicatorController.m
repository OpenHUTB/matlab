classdef(Hidden)AeroAirspeedIndicatorController<Aero.ui.control.internal.controller.AeroController





    methods
        function obj=AeroAirspeedIndicatorController(varargin)
            obj=obj@Aero.ui.control.internal.controller.AeroController(varargin{:});
            obj.NumericProperties=[obj.NumericProperties,'Airspeed','Limits'];
        end
    end
end