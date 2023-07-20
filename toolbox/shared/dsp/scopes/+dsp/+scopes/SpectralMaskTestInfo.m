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
                data.IsCurrentlyPassing=maskStatus.IsCurrentlyPassing;
                data.NumPassedTests=maskStatus.NumPassedTests;
                data.NumTotalTests=maskStatus.NumTotalTests;
                data.SuccessRate=maskStatus.SuccessRate;
                data.FailingMasks=maskStatus.FailingMasks;
                data.FailingChannels=maskStatus.FailingChannels;
                data.SimulationTime=maskStatus.SimulationTime;
            end
        end
    end
end