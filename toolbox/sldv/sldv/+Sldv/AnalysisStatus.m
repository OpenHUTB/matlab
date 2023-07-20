





classdef AnalysisStatus<uint32
    enumeration
        None(0)
        WaitingForInit(1)
        Init(2)
        LaunchFailed(3)
        Running(4)
        Success(5)
        Terminated(6)
        Timeout(7)
        OutOfMemory(8)
        ContradictoryModel(9)
        Failure(10)
    end
end
