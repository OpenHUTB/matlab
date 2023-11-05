classdef XlnxSGMII<eda.internal.boardmanager.EthInterface

    properties(Constant)
        Name='Gigabit Ethernet - Xilinx SGMII';
        Communication_Channel='XlnxSGMII';
        isGigaEthInterface=true;
    end

    methods
        function defineInterface(obj)
            obj.addSignalDefinition('ETH_TXP','Transmit data','out',1,'LVDS');
            obj.addSignalDefinition('ETH_RXP','Receive data','in',1,'LVDS');
            obj.addSignalDefinition('ETH_MDC','Management interface clock','out',1);
            obj.addSignalDefinition('ETH_MDIO','Management interface I/O bidirectional pin','inout',1);
            obj.addSignalDefinition('ETH_RESET_n','PHY reset signal','out',1);
            obj.addSignalDefinition('ETH_GTREFCLK_P','125MHz differential reference clock','in',1,'');
            obj.addSignalDefinition('ETH_GTREFCLK_N','125MHz differential reference clock','in',1,'');
        end
    end

end


