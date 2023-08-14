classdef(Hidden)AeroEGTIndicatorController<Aero.ui.control.internal.controller.AeroController





    methods
        function obj=AeroEGTIndicatorController(varargin)
            obj=obj@Aero.ui.control.internal.controller.AeroController(varargin{:});
            obj.NumericProperties=[obj.NumericProperties,'Temperature','Limits'];
        end
    end
end