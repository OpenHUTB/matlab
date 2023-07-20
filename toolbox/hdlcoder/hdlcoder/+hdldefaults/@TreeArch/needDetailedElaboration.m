function needDetailedElab=needDetailedElaboration(this,hN,hInSignals,dspMode)%#ok<INUSL>



    if(nargin<4)
        dspMode=int8(0);
    end

    isPipeliningOn=hN.getDistributedPipelining;
    isSharingOn=hN.getSharingFactor>0;
    isDSPModeON=dspMode>int8(0);
    isCPEOn=hdlgetparameter('CriticalPathEstimation')||hdlgetparameter('OptimizationCompatibilityCheck');
    isStaticLatAnalysisOn=hdlgetparameter('StaticLatencyPathAnalysis');
    needDetailedElab=isPipeliningOn||isSharingOn||targetmapping.mode(hInSignals(1))||isDSPModeON||isCPEOn||isStaticLatAnalysisOn;

end

