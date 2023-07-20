classdef(Hidden)AeroArtificialHorizonController<Aero.ui.control.internal.controller.AeroController





    methods
        function obj=AeroArtificialHorizonController(varargin)
            obj=obj@Aero.ui.control.internal.controller.AeroController(varargin{:});
            obj.NumericProperties=[obj.NumericProperties,'Pitch','Roll'];
        end
    end
end