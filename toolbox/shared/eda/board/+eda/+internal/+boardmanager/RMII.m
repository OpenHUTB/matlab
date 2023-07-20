


classdef RMII<eda.internal.boardmanager.EthInterface

    properties(Constant)
        Name='Ethernet - RMII';
        Communication_Channel='RMII';
        isGigaEthInterface=false;
    end

    methods
        function defineInterface(obj)
            obj.addSignalDefinition('ETH_RXD','Receive data','in',2);
            obj.addSignalDefinition('ETH_TXD','Transmit data','out',2);
            obj.addSignalDefinition('ETH_CRS','Carrier sense','in',1);
            obj.addSignalDefinition('ETH_RXER','Signifies data received has errors','in',1);
            obj.addSignalDefinition('ETH_TXEN','Transmitter enable','out',1);
            obj.addSignalDefinition('ETH_REFCLK','50MHz reference clock to PHY chip','out',1);
            obj.addSignalDefinition('ETH_MDC','Management interface clock','out',1);
            obj.addSignalDefinition('ETH_MDIO','Management interface I/O bidirectional pin','inout',1);
            obj.addSignalDefinition('ETH_RESET_n','PHY reset signal','out',1);
        end
    end

end


