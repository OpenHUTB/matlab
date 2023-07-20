
function id=getSignalSourceId(fullBlkPath,portIdx,signalName)

    q=Simulink.AsyncQueue.Queue.find(...
    fullBlkPath,...
    portIdx,...
    signalName);
    if~isempty(q)
        id=q.SignalSourceID;
    else
        id=0;
    end
end

