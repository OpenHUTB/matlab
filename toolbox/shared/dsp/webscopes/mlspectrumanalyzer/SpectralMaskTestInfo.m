classdef SpectralMaskTestInfo<event.EventData





    properties(SetAccess=protected)
        IsCurrentlyPassing;
        NumPassedTests;
        NumTotalTests;
        SuccessRate;
        FailingMasks;
        FailingChannels;
        SimulationTime;
    end

    methods
        function data=SpectralMaskTestInfo(maskStatus)
            if~isempty(maskStatus)&&isstruct(maskStatus)
                data.IsCurrentlyPassing=maskStatus.isCurrentlyPassing;
                data.NumPassedTests=str2double(maskStatus.numPassedTests);
                data.NumTotalTests=str2double(maskStatus.numTotalTests);
                data.SuccessRate=str2double(maskStatus.successRate);
                data.FailingMasks=maskStatus.failingMasks;
                data.FailingChannels=maskStatus.failingChannels+1;
                data.SimulationTime=maskStatus.simTime;
            end
        end
    end
end