classdef(ConstructOnLoad)AlteraCycloneIIIStarter<eda.board.FPGABoard






    properties


    end
    methods
        function this=AlteraCycloneIIIStarter
            this.Name='Altera Cyclone III FPGA Starter Kit';
            this.Component.PartInfo=eda.fpga.Cyclone3(...
            'Device','??',...
            'Speed','',...
            'Package','');

            this.Component.SYSCLK.Frequency=50;
            this.Component.SYSCLK.Type='SINGLE_ENDED';
            this.Component.ScanChain=2;
            this.Component.DCMLocation='XY';
            this.Component.Communication_Channel='RGMII';
        end

        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk='';
            this.Component(CompIndex).PINOUT.reset='';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='';
            this.Component(CompIndex).PINOUT.ETH_RXD={'','','',''};
            this.Component(CompIndex).PINOUT.ETH_rx_ctl='';
            this.Component(CompIndex).PINOUT.ETH_TXD={'','','',''};
            this.Component(CompIndex).PINOUT.ETH_GTXCLK='';
            this.Component(CompIndex).PINOUT.ETH_tx_ctl='';
            this.Component(CompIndex).PINOUT.ETH_MDC='';
            this.Component(CompIndex).PINOUT.ETH_MDIO='';
        end
    end
end
