classdef(ConstructOnLoad)AlteraCycloneIVGX<eda.board.FPGABoard






    properties


    end
    methods
        function this=AlteraCycloneIVGX
            this.Name='Altera Cyclone IV GX FPGA development kit';
            this.Component.PartInfo=eda.fpga.Cyclone4(...
            'FPGAFamily','Cyclone IV GX',...
            'Device','EP4CGX150DF31C7');


            this.Component.PartInfo.RGMII_TX_PhaseShift=500;

            this.Component.SYSCLK.Frequency=50;
            this.Component.SYSCLK.Type='SINGLE_ENDED';
            this.Component.SYSRST.Polarity='ACTIVE_LOW';
            this.Component.ScanChain=2;
            this.Component.DCMLocation='';
            this.Component.Communication_Channel='RGMII';
            this.Component.PhyAddr=18;
        end


        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk='AK16';
            this.Component(CompIndex).PINOUT.sysrst='G20';
            this.Component(CompIndex).PINOUT.LED='E4';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='D6';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='B15';
            this.Component(CompIndex).PINOUT.ETH_RXD={'F5','B9','G14','E13'};
            this.Component(CompIndex).PINOUT.ETH_RX_CTL='E15';
            this.Component(CompIndex).PINOUT.ETH_TXD={'G10','E3','D10','B10'};
            this.Component(CompIndex).PINOUT.ETH_TXCLK='D9';
            this.Component(CompIndex).PINOUT.ETH_TX_CTL='A27';
            this.Component(CompIndex).PINOUT.ETH_MDC='K21';
            this.Component(CompIndex).PINOUT.ETH_MDIO='G7';
        end
    end
end
