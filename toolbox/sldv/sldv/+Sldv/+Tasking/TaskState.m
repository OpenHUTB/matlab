





classdef TaskState<uint32
    enumeration
        None(0)
        Created(1)
        Ready(2)
        Running(3)
        Completed(4)
        Failed(5)
        Done(6)
        Cancelled(7)
    end
end
