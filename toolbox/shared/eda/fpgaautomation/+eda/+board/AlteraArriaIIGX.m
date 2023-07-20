classdef(ConstructOnLoad)AlteraArriaIIGX<eda.board.FPGABoard






    properties


    end
    methods
        function this=AlteraArriaIIGX
            this.Name='Altera Arria II GX FPGA development kit';

            this.Component.PartInfo=eda.fpga.Arria2(...
            'FPGAFamily','Arria II GX',...
            'Device','EP2AGX125EF35C4');

            this.Component.SYSCLK.Frequency=125;
            this.Component.SYSCLK.Type='DIFF';
            this.Component.SYSRST.Polarity='ACTIVE_LOW';
            this.Component.ScanChain=2;
            this.Component.DCMLocation='';
            this.Component.Communication_Channel='RGMII';
            this.Component.PhyAddr=0;
        end


        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk_p='F18';
            this.Component(CompIndex).PINOUT.sysclk_n='F17';
            this.Component(CompIndex).PINOUT.sysrst='N10';
            this.Component(CompIndex).PINOUT.LED='G1';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='M20';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='V6';
            this.Component(CompIndex).PINOUT.ETH_RXD={'E21','E24','E22','F24'};
            this.Component(CompIndex).PINOUT.ETH_RX_CTL='D17';
            this.Component(CompIndex).PINOUT.ETH_TXD={'J20','C25','G22','G21'};
            this.Component(CompIndex).PINOUT.ETH_TXCLK='D25';
            this.Component(CompIndex).PINOUT.ETH_TX_CTL='G20';
            this.Component(CompIndex).PINOUT.ETH_MDC='K20';
            this.Component(CompIndex).PINOUT.ETH_MDIO='N20';
        end
    end
end
