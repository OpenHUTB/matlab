classdef(Hidden)AeroAltimeterController<Aero.ui.control.internal.controller.AeroController





    methods
        function obj=AeroAltimeterController(varargin)
            obj=obj@Aero.ui.control.internal.controller.AeroController(varargin{:});
            obj.NumericProperties=[obj.NumericProperties,'Altitude'];
        end
    end
end