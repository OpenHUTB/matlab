classdef ProfileLogsConvpLayerbase<handle

    methods(Abstract)

        LayerCycle=getLayerCycle(this)
        LayerStart=getLayerStart(this)
        LayerEnd=getLayerEnd(this)
    end

end