




classdef tree<handle

    methods(Static)




        hC=getTreeArch(hN,hInSignals,hOutSignals,opName,rndMode,satMode,...
        compName,minmaxIdxBase,pipeline,useDetailedElab,minmaxISDSP,minmaxOutMode,dspMode,nfpOptions,prodWordLenMode)




        hC=getSimpleElabTreeArch(hN,hInSignals,hOutSignals,opName,...
        rndMode,satMode,compName,minmaxIdxBase,pipeline,minmaxISDSP,minmaxOutMode)
        hC=getDetailedElabTreeArch(hN,hInSignals,hOutSignals,opName,...
        rndMode,satMode,compName,minmaxIdxBase,pipeline,minmaxISDSP,minmaxOutMode,dspMode,nfpOptions,prodWordLenMode)




        tOutType=getStageOutputType(hInputType,opName,stageInputSignalsType,hOutputType,signs);
        structSignalsOut=insertPipeline(hN,structSignalsOut,opName,minmaxOutMode,stageNum,numStages)

    end
end


