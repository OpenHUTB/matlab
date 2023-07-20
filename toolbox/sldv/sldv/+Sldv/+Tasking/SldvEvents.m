





classdef SldvEvents<uint32
    enumeration
        AnalysisInit(100)
        AsyncAnalysisLaunched(101)
        AsyncAnalysisUpdate(102)
        AsyncAnalysisDone(103)
        TerminateAsyncAnalysis(104)
        SyncAnalysisDone(105)
        AnalysisWrap(106)
        CheckForMatlabTask(107)
        ResultsPoll(108)
    end
end
