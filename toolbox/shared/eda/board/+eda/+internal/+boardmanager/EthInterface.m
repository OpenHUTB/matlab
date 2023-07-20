



classdef EthInterface<eda.internal.boardmanager.FILCommInterface
    properties(Constant,Abstract)
        isGigaEthInterface;
    end
    properties
        ConnectionDispName='Ethernet';
        RTIOStreamLibName='mwrtiostreamtcpip';
        RTIOStreamParams='';
    end
    methods
        function obj=EthInterface
            obj.addParameterDefinition('GenerateMDIOModule','No');
            obj.addParameterDefinition('PhyAddr','0');
            obj.ProtocolParams='NumHWBuf=22';
        end

        function r=getFormInstruction(obj)
            r=DAStudio.message('EDALink:boardmanagergui:Ethernet_Table_Instruction',obj.Name);
        end
        function setGenerateMDIOModule(obj,enable)
            if enable
                obj.setParam('GenerateMDIOModule','Yes');
            else
                obj.setParam('GenerateMDIOModule','No');
            end
        end

        function r=isMDIOModuleEnabled(obj)
            tmp=obj.getParam('GenerateMDIOModule');
            r=strcmp(tmp,'Yes');
        end

        function r=getPhyAddr(obj)
            r=obj.getParam('PhyAddr');
        end

        function setPhyAddr(obj,phyAddrStr)
            phyAddr=str2double(phyAddrStr);
            if isnan(phyAddr)||mod(phyAddr,1)~=0||phyAddr>31||phyAddr<0
                error(message('EDALink:boardmanager:InvalidPhyAddr'));
            end
            obj.setParam('PhyAddr',phyAddrStr);
        end
    end
end


