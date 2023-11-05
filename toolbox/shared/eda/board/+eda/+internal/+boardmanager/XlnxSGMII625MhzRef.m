classdef XlnxSGMII625MhzRef<eda.internal.boardmanager.EthInterface

    properties(Constant)
        Name='Gigabit Ethernet - Xilinx SGMII with 625MHz Reference Clock';
        Communication_Channel='XlnxSGMII625MhzRef';
        isGigaEthInterface=true;
    end

    methods
        function defineInterface(obj)
            obj.addSignalDefinition('ETH_TXP','Transmit data','out',1);
            obj.addSignalDefinition('ETH_RXP','Receive data','in',1);
            obj.addSignalDefinition('ETH_MDC','Management interface clock','out',1);
            obj.addSignalDefinition('ETH_MDIO','Management interface I/O bidirectional pin','inout',1);
            obj.addSignalDefinition('ETH_RESET_n','PHY reset signal','out',1);
            obj.addSignalDefinition('ETH_GTREFCLK_P','625MHz differential reference clock','in',1,'');
        end
    end

end
