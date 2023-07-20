


function sendSimOutInfoToDataQueue(dataQ,runId,simOut)
    simOutInfo.runId=runId;
    simOutInfo.simOut=simOut;
    dataQ.send(simOutInfo);
end