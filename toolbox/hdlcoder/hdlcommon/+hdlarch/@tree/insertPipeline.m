function structSignalsOut=insertPipeline(hN,structSignalsOut,opName,minmaxOutMode,stageNum,numStages)



    if~((strcmpi(opName,'min')||strcmpi(opName,'max'))&&...
        strcmpi(minmaxOutMode,'Index')&&stageNum==numStages)

        tSignalsOut=insertPipelineRegister(hN,structSignalsOut.tSignals);
        structSignalsOut.tSignals=tSignalsOut;
    end

    if(strcmpi(opName,'min')||strcmpi(opName,'max'))&&...
        ~strcmpi(minmaxOutMode,'Value')

        tSignalsOut=insertPipelineRegister(hN,structSignalsOut.tIndex);
        structSignalsOut.tIndex=tSignalsOut;
    end

end


function tSignalsOut=insertPipelineRegister(hN,tSignalsOut)

    tSignalsOutPipe=tSignalsOut;
    for jj=1:length(tSignalsOut)
        tSignalsOutPipe(jj)=hN.addSignal(tSignalsOut(jj).Type,...
        [tSignalsOut(jj).Name,'_reg']);
        pirelab.getUnitDelayComp(hN,tSignalsOut(jj),tSignalsOutPipe(jj),...
        tSignalsOut(jj).Name);
    end

    tSignalsOut=tSignalsOutPipe;

end

