


classdef(Abstract)AXI4MasterSoftware<hdlturnkey.swinterface.SoftwareInterfaceBase


    properties
        hFPGAInterface=[];
    end

    properties(Access=protected)

        IIOReadDeviceBaseName string="mm2s";
        IIOWriteDeviceBaseName string="s2mm";
        IIOReadDeviceName string
        IIOWriteDeviceName string

        IIODeviceNode='mwipcore0';
        IIOWriteDevice='mm2s0';
        IIOReadDevice='s2mm0';
    end


    properties(Abstract,Constant,Access=protected)
DriverBlockLibrary
AXI4MastermWriteBlock
AXI4MasterReadBlock
    end


    properties(Access=protected)
        AddInterfaceMethod='addMemoryInterface';
    end


    methods(Static)
        function hSoftwareInterface=getInstance(hFGPAInterface,hTurnkey)

            if hTurnkey.hD.isXilinxIP
                hSoftwareInterface=hdlturnkey.swinterface.AXI4MasterSoftwareZynq(hFGPAInterface);
            elseif hTurnkey.hD.isAlteraIP
                hSoftwareInterface=hdlturnkey.swinterface.AXI4MasterSoftwareAlteraSoC(hFGPAInterface);
            else
                hSoftwareInterface=hdlturnkey.swinterface.SoftwareInterfaceEmpty(hFGPAInterface.InterfaceID);
            end
        end
    end

    methods(Access=protected)
        function obj=AXI4MasterSoftware(hFGPAInterface)

            obj=obj@hdlturnkey.swinterface.SoftwareInterfaceBase(hFGPAInterface.InterfaceID);


            obj.hFPGAInterface=hFGPAInterface;
        end
    end


    methods
        function validateCell=generateDeviceTreeNodes(obj,hIPCoreNode)
            validateCell={};


            hMem=devicetreeNode("sharedmem","UnitAddress",0);
            hMem.addProperty("#address-cells",{1});
            hMem.addProperty("#size-cells",{0});
            hMem.addProperty("compatible","mathworks,sharedmem-v1.00");
            hMem.addProperty("memory-region",{obj.hFPGAInterface.MemoryRegionNode});
            hMem.addProperty("mathworks,dev-name",obj.IIOMemoryDeviceName);
            hMem.addProperty("mathworks,rd-base-reg",{obj.hFPGAInterface.ReadBaseRegisterAddress});
            hMem.addProperty("mathworks,wr-base-reg",{obj.hFPGAInterface.WriteBaseRegisterAddress});


            hReadChannel=hMem.addNode("read-channel","UnitAddress",0);
            hReadChannel.addProperty("compatible","mathworks,sharedmem-read-channel-v1.00");
            hReadChannel.addProperty("mathworks,dev-name",obj.IIOReadDeviceName);


            hWriteChannel=hMem.addNode("write-channel","UnitAddress",1);
            hWriteChannel.addProperty("compatible","mathworks,sharedmem-write-channel-v1.00");
            hWriteChannel.addProperty("mathworks,dev-name",obj.IIOWriteDeviceName);



            hIPCoreNode.addProperty("compatible","mathworks,mwipcore-v3.00");
            hIPCoreNode.addProperty("#address-cells",hMem.RequiredAddressCells);
            hIPCoreNode.addProperty("#size-cells",hMem.RequiredSizeCells);


            hIPCoreNode.addNode(hMem);
        end
    end



    methods
        function validateCell=generateModelDriver(obj,hModelGen)
            validateCell={};
            obj.stubAllPorts(hModelGen);
        end
    end


    methods
        function validateCell=generateScriptDriver(obj,hScriptGen)


            validateCell={};
        end

        function validateCell=generateInterfaceAccessCommand(obj,hScriptGen)


            validateCell={};
        end
    end
end