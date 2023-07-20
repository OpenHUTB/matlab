classdef TIC2000TargetSimHardwarePlugin<codertarget.internal.TargetHardwarePlugin





    properties
        TgtHwID='tic2000soc'
        TgtName={'TIC2000SIM'};
        TgtHwFolder={'matlabshared.target.tic2000sim.getSpPkgRootDir'};
    end

    methods
        function out=getSupportedHwBoards(~)
            out={'TI Delfino F2837xD','TI Delfino F28379D LaunchPad','TI F2838xD (SoC)'};
        end
    end
end
