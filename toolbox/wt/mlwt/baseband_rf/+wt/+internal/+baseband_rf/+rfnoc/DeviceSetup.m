classdef DeviceSetup<wt.internal.rfnoc.DeviceSetup





    properties(Constant)
        BitstreamFolder=fullfile(matlabroot,'toolbox','wt','bitstreams','baseband_rf','rfnoc','bitstreams')
        Application="baseband_rf";
    end

    methods
        function flag=canRadioRunApplication(obj,driver)
            flag=true;
            hasBlocks=canRadioRunApplication@wt.internal.rfnoc.DeviceSetup(obj,driver);
            if hasBlocks







                if strcmp(wt.internal.hardware.rfnoc.feature("MCOSDriver"),"off")
                    replayControl=driver.driverImpl.getControl("0/Replay#0");


                    numPorts=replayControl.get_num_input_ports;


                    clibRelease(replayControl);
                else


                    numPorts=driver.driverImpl.getBlock("0/Replay#0").getNumInputPorts;
                end

                if numPorts<4
                    flag=false;
                end
            else
                flag=false;
            end
        end
        function[names,ids]=getCompatibleBlocksAndIDs(obj)%#ok<MANU>
            names=["0/Radio#0","0/DDC#0","0/Replay#0","0/DUC#0","0/Radio#1","0/DDC#1","0/DUC#1"];
            ids=["0xD9FA7703"];%#ok<NBRAK2>
        end
    end
end

