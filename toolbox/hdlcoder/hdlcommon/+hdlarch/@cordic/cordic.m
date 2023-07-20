
classdef cordic<handle

    methods(Static)




        hC=getSinCosCordicComp(hN,hInSignals,hOutSignals,cordicInfo,usePipelines,customLatency,latencyStrategy)
        hC=getPol2CartCordicComp(hN,hInSignals,hOutSignals,cordicInfo)
        hC=getCordicKernelComp(hN,hInSignals,hOutSignals,lut_value,idx)
        hC=getCordicQuadCorrectionBeforeComp(hN,hInSignals,hOutSignals,opType)
        hC=getCordicQuadCorrectionAfterComp(hN,hInSignals,hOutSignals,negateMode)
        hc=getAtan2CordicComp(hN,hInSignals,hOutSignals,cordicInfo,usePipelines,customLatency,latencyStrategy)




        hNewNet=getSinCordicNetwork(hN,hInSignals,hOutSignals,cordicInfo,usePipelines,customLatency,latencyStrategy)
        hNewNet=getCosCordicNetwork(hN,hInSignals,hOutSignals,cordicInfo,usePipelines,customLatency,latencyStrategy)
        hNewNet=getSinCosCordicNetwork(hN,hInSignals,hOutSignals,cordicInfo,usePipelines,customLatency,latencyStrategy)
        hNewNet=getPol2CartCordicNetwork(hN,hInSignals,hOutSignals,cordicInfo,usePipelines)
        hNewNet=getAtan2CordicNetwork(topNet,hInSignals,hOutSignals,cordicInfo,usePipelines,customLatency,latencyStrategy)

    end
end
