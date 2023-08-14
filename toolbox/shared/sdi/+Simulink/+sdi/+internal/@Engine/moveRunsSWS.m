function moveRunsSWS(this,target,runArray)
    try
        Simulink.sdi.internal.flushStreamingBackend();
        Simulink.sdi.internalSWSMoveRuns(target,runArray);
    catch me
        me.throwAsCaller();
    end
end
