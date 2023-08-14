classdef SubsystemTypeCheckerRCB<Simulink.ModelReference.Conversion.SubsystemTypeChecker
    methods(Access=public)
        function this=SubsystemTypeCheckerRCB(varargin)
            this@Simulink.ModelReference.Conversion.SubsystemTypeChecker(varargin{:});
        end
    end

    methods(Access=protected)

        function throwIfResettableSubsystem(~,~)
        end
    end
end