function delay=addTimestampDeltaToQueue(h)



















    maxQueueLength=2;
    if isequal(size(h.timestampDeltaQueue,1),0)
        h.timestampDeltaQueue=0;
        delay=100;
        return;
    elseif size(h.timestampDeltaQueue,1)<maxQueueLength
        h.timestampDeltaQueue=...
        [h.timestampDeltaQueue;etime(clock,h.lastTimestamp)];
        delay=100;
        return;
    else




        assert(isequal(size(h.timestampDeltaQueue,1),maxQueueLength));
        h.timestampDeltaQueue(1)=[];
        h.timestampDeltaQueue=...
        [h.timestampDeltaQueue;etime(clock,h.lastTimestamp)];
        delay=sum(h.TimestampDeltaQueue);
    end


