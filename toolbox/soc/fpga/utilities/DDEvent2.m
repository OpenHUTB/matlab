classdef DDEvent2<Simulink.IntEnumType
    enumeration
        UnknownEvent(0)
        BufIdle(1)
        BufRequest(2)
        BufGrant(3)
        BufExecuting(4)
        BufDone(5)
        BufAck(6)
        InflowIdle(7)
        InflowQueueChange(8)
        InflowQueueOverflow(9)
        ICDatapathIdle(10)
        FIFOEntries(11)
        FIFOOverflow(12)
        ICIdle(13)
        ICRequest(14)
        ICAccepted(15)
        ICExecuting(16)
        ICDone(17)
        BurstIdle(18)
        BurstRequest(19)
        BurstAccepted(20)
        BurstExecuting(21)
        BurstDone(22)
        BurstComplete(23)
        FrameIdle(24)
        FrameReady(25)
        FrameDone(26)
        NewTransaction(27)
    end
end
