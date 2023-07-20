


classdef RGMII<eda.internal.boardmanager.EthInterface

    properties(Constant)
        Name='Gigabit Ethernet - RGMII';
        Communication_Channel='RGMII';
        isGigaEthInterface=true;
    end

    methods
        function defineInterface(obj)
            obj.addSignalDefinition('ETH_TXCLK','Transmit reference clock','out',1);
            obj.addSignalDefinition('ETH_TXD','Transmit data','out',4);
            obj.addSignalDefinition('ETH_TX_CTL','Transmit control signal','out',1);
            obj.addSignalDefinition('ETH_RXCLK','Receive reference clock','in',1);
            obj.addSignalDefinition('ETH_RXD','Receive data','in',4);
            obj.addSignalDefinition('ETH_RX_CTL','Receive control signal','in',1);
            obj.addSignalDefinition('ETH_MDC','Management interface clock','out',1);
            obj.addSignalDefinition('ETH_MDIO','Management interface I/O bidirectional pin','inout',1);
            obj.addSignalDefinition('ETH_RESET_n','PHY reset signal','out',1);
        end
    end

end


