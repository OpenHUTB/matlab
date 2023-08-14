


classdef AllPortInfo
    properties(Access=public)


        streamedInPorts(1,:)streamingmatrix.StreamedPortInfo
        streamedOutPorts(1,:)streamingmatrix.StreamedPortInfo


        nonStreamedInPorts(1,:)
        nonStreamedOutPorts(1,:)



        externalDelayPorts(1,:)streamingmatrix.ExternalDelayPortInfo
    end
end
