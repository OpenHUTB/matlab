classdef EnableCreateForHarnessBD<handle







    properties(SetAccess='private',GetAccess='public',Transient)
        harnessSysH=-1;
        mainSysH=-1;
        harnessUUID='';
    end

    methods
        function h=EnableCreateForHarnessBD(mainSysH,harnessSysH)
            h.harnessSysH=harnessSysH;
            h.mainSysH=mainSysH;
            h.harnessUUID=...
            Simulink.harness.internal.convertFromHarnessBD(harnessSysH);
        end

        function delete(h)
            Simulink.harness.internal.convertToHarnessBD(h.mainSysH,...
            h.harnessSysH,h.harnessUUID);
        end
    end
end
