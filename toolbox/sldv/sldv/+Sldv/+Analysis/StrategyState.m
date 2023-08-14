





classdef StrategyState<uint32
    enumeration
        None(0)
        Failed(1)
        AsyncRunning(2)
        AsyncDone(3)
        SyncDone(4)
        Done(5)
        Terminated(6)
    end
end
