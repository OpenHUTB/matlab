

classdef InterfacePCIe<hdlturnkey.interface.AXI4






    properties

    end

    methods

        function obj=InterfacePCIe(varargin)













            obj=obj@hdlturnkey.interface.AXI4('ShiftRegisterDecoder',true,'BitPacking',true,varargin{:});
        end

    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end


    methods

    end


    methods(Access=public,Hidden)
        function hSoftwareInterface=getDefaultSoftwareInterface(obj,hTurnkey)
            hRD=hTurnkey.hD.hIP.getReferenceDesignPlugin;
            hasMATLABAXIMasterConnection=hRD.getJTAGAXIParameterValue;
            writeDriverBlock=hTurnkey.hBoard.xPCPCIWriteBlkPath;
            readDriverBlock=hTurnkey.hBoard.xPCPCIReadBlkPath;
            isAXI4ReadbackEnabled=hTurnkey.hD.hIP.getAXI4ReadbackEnable;
            hSoftwareInterface=hdlturnkey.swinterface.AXI4SlaveSoftwareSLRT(obj,hTurnkey.isCoProcessorMode,hasMATLABAXIMasterConnection,isAXI4ReadbackEnabled,writeDriverBlock,readDriverBlock);
        end
    end
end



