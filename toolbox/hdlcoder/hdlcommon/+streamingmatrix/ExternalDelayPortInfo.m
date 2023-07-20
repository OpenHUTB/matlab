





classdef ExternalDelayPortInfo
    properties(Access=public)
        inPort(1,1)streamingmatrix.StreamedPortInfo
        outPort(1,1)streamingmatrix.StreamedPortInfo
        delayLength(1,1)double
    end
end
