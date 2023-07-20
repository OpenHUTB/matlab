


classdef SampleTimeType<Simulink.IntEnumType

    enumeration
        UNKNOWN(0)
        ASYNC(1)
        CONSTANT(2)
        CONTINUOUS(3)
        DISCRETE(4)
        FIXED_IN_MINOR_STEP(5)
        INHERIT(6)
        PARAMETER(7)
        TRIGGERED(8)
    end
end