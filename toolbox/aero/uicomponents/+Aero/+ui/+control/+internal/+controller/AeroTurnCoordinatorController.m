classdef(Hidden)AeroTurnCoordinatorController<Aero.ui.control.internal.controller.AeroController





    methods
        function obj=AeroTurnCoordinatorController(varargin)
            obj=obj@Aero.ui.control.internal.controller.AeroController(varargin{:});
            obj.NumericProperties=[obj.NumericProperties,'Turn','Slip'];
        end
    end
end