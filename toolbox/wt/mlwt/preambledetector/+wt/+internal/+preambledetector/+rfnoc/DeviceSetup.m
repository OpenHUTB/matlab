classdef DeviceSetup<wt.internal.rfnoc.DeviceSetup





    properties(Constant)
        BitstreamFolder=fullfile(matlabroot,'toolbox','wt','bitstreams','preambledetector','rfnoc','bitstreams')
        Application="preambledetector";
    end
    methods
        function[names,ids]=getCompatibleBlocksAndIDs(obj)%#ok<MANU>
            names=["0/Radio#0","0/DDC#0","0/Replay#0","0/DUC#0","0/Radio#1","0/DDC#1","0/DUC#1"];
            ids=["0xD9FA7703","0xD8E2543F"];
        end
    end
end


