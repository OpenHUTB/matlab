classdef BuildState<uint32

    enumeration
        IDLE(1)
        BUILDING(2)
        CANCELING(3)
        CANCELED(4)
        FINISHED(5)
        ERROR(6)
    end

end

