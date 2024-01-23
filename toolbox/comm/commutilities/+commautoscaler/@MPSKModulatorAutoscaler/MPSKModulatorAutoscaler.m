classdef MPSKModulatorAutoscaler<commautoscaler.ModulatorAutoscaler

    methods(Hidden)
        [outputPortIndex,outputValueMax,outputValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)
    end

end

