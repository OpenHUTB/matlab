classdef FIFOState<int32
    enumeration
        FIFO_Empty(0),FIFO_Below25Percent(1),FIFO25PercentFull(2),FIFO50PercentFull(3),FIFO75PercentFull(4),FIFO_Full(5)
    end
end