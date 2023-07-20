classdef(Sealed=true)TwoPhaseFluidData










    properties(SetAccess=private,GetAccess=?fluids.internal.two_phase_fluid.utilities.TwoPhaseFluidPredefinedProperties,Hidden=true)
FluidTables
    end

    methods
        function obj=TwoPhaseFluidData(fluidTables)
            obj.FluidTables=fluidTables;
        end
    end

end