classdef TaskStatus<Simulink.IntEnumType

    enumeration
        Unassigned(1)
        Assigned(2)
        InProgress(3)
        Complete(4)
        Cancelled(5)
    end
end
