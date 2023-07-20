


classdef MIIwith25MHzOut<eda.internal.boardmanager.EthInterface

    properties(Constant)
        Name='Ethernet - MII with 25MHz Output';
        Communication_Channel='MIIwith25MHzOut';
        isGigaEthInterface=false;
    end
    methods
        function defineInterface(obj)
            obj.addSignalDefinition('ETH_TXCLK','Transmitter clock','in',1);
            obj.addSignalDefinition('ETH_TXD','Data to be transmitted','out',4);
            obj.addSignalDefinition('ETH_TXEN','Transmitter enable','out',1);
            obj.addSignalDefinition('ETH_TXER','Transmitter error','out',1);
            obj.addSignalDefinition('ETH_RXCLK','Received clock signal','in',1);
            obj.addSignalDefinition('ETH_RXD','Received data','in',4);
            obj.addSignalDefinition('ETH_RXDV','Signifies data received is valid','in',1);
            obj.addSignalDefinition('ETH_RXER','Signifies data received has errors','in',1);
            obj.addSignalDefinition('ETH_COL','Collision detect','in',1);
            obj.addSignalDefinition('ETH_CRS','Carrier sense','in',1);
            obj.addSignalDefinition('ETH_MDC','Management interface clock','out',1);
            obj.addSignalDefinition('ETH_MDIO','Management interface I/O bidirectional pin','inout',1);
            obj.addSignalDefinition('ETH_RESET_n','PHY reset signal','out',1);
            obj.addSignalDefinition('ETH_CLK25','25Mhz clock to PHY','out',1);
        end
    end

end


