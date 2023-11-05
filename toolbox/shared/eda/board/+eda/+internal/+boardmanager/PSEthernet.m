classdef PSEthernet<eda.internal.boardmanager.FILCommInterface

    properties(Constant)
        Name='PSEthernet';
        ConnectionDispName='Ethernet';
        Communication_Channel='PSEthernet';
    end
    properties
        RTIOStreamLibName='matlab:getRtiostreamLibIIO';
        RTIOStreamParams='';
TclScript
ConstraintFile
DeviceTree
FILCoreInterface
        HasMWDMA=false
    end
    methods
        function this=PSEthernet
            this.ProtocolParams='MaxPktSize=16384;NumHWBuf=1;HWWordSize=4';
            this.GenerateOnlyChIf=false;
            this.PostCodeGenerationFcn='generateTclForPSEthFIL';
        end
        function defineInterface(~)
        end
    end
end

