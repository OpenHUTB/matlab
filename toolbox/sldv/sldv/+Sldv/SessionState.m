






classdef SessionState<uint32
    enumeration
        None(0)
        Initialized(1)
        CompatibilityRunning(2)
        MdlCompSuccess(3)
        MdlCompFailure(4)
        AsyncAnalysisRunning(5)
        AnalysisSuccess(6)
        AnalysisFailure(7)
        GeneratingResults(8)
        ResultsSuccess(9)
        ResultsFailure(10)
        Terminated(11)
    end
end

