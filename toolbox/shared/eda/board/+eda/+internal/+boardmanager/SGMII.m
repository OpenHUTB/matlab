classdef SGMII<eda.internal.boardmanager.EthInterface

    properties(Constant)
        Name='Gigabit Ethernet - SGMII';
        Communication_Channel='SGMII';
        isGigaEthInterface=true;
    end

    methods
        function defineInterface(obj)
            obj.addSignalDefinition('ETH_TXP','Transmit data','out',1,'LVDS');
            obj.addSignalDefinition('ETH_RXP','Receive data','in',1,'LVDS');
            obj.addSignalDefinition('ETH_MDC','Management interface clock','out',1);
            obj.addSignalDefinition('ETH_MDIO','Management interface I/O bidirectional pin','inout',1);
            obj.addSignalDefinition('ETH_RESET_n','PHY reset signal','out',1);
        end
    end

end


