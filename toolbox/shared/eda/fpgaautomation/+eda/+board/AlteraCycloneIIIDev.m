classdef(ConstructOnLoad)AlteraCycloneIIIDev<eda.board.FPGABoard







    properties


    end
    methods
        function this=AlteraCycloneIIIDev
            this.Name='Altera Cyclone III FPGA development kit';

            this.Component.PartInfo=eda.fpga.Cyclone3(...
            'Device','EP3C120F780C7');


            this.Component.SYSCLK.Frequency=50;
            this.Component.SYSCLK.Type='SINGLE_ENDED';
            this.Component.SYSRST.Polarity='ACTIVE_LOW';
            this.Component.ScanChain=2;
            this.Component.DCMLocation='';
            this.Component.Communication_Channel='RGMII';
            this.Component.PhyAddr=18;
        end


        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk='AH15';
            this.Component(CompIndex).PINOUT.sysrst='T21';
            this.Component(CompIndex).PINOUT.LED='AD15';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='AD2';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='B14';
            this.Component(CompIndex).PINOUT.ETH_RXD={'W8','AA6','W7','Y6'};
            this.Component(CompIndex).PINOUT.ETH_RX_CTL='AB4';
            this.Component(CompIndex).PINOUT.ETH_TXD={'W4','AA5','Y5','W3'};
            this.Component(CompIndex).PINOUT.ETH_TXCLK='T8';
            this.Component(CompIndex).PINOUT.ETH_TX_CTL='AA7';
            this.Component(CompIndex).PINOUT.ETH_MDC='N8';
            this.Component(CompIndex).PINOUT.ETH_MDIO='L5';
        end
    end
end
