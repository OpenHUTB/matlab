classdef GenQAMModulatorAutoscaler<dvautoscaler.SPCBlocksetAutoscaler








    methods
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end


    methods(Hidden)
        [outputPortIndex,outputValueMax,outputValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)
    end

end

