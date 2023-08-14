




classdef TargetStatus<uint8
    enumeration
        RESET(0)
        INITIALIZED(1)
        WAITING_TO_START(2)
        READY_TO_RUN(3)
        RUNNING(4)
        PAUSED(5)
        RESETTING(6)
    end
end

