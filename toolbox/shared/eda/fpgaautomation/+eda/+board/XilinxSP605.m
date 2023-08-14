classdef(ConstructOnLoad)XilinxSP605<eda.board.FPGABoard






    properties


    end
    methods
        function this=XilinxSP605
            this.Name='Xilinx Spartan-6 SP605 development board';
            this.Component.PartInfo=eda.fpga.Spartan6(...
            'Device','xc6slx45t',...
            'Speed','-3',...
            'Package','fgg484',...
            'Frequency','25MHz');

            this.Component.SYSCLK.Frequency=200;
            this.Component.SYSCLK.Type='DIFF';
            this.Component.SYSRST.Polarity='ACTIVE_HIGH';
            this.Component.ScanChain=2;
            this.Component.DCMLocation='DCM_X0Y4';
            this.Component.Communication_Channel='GMII';
            this.Component.PhyAddr=7;
        end


        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk_p='K21';
            this.Component(CompIndex).PINOUT.sysclk_n='K22';
            this.Component(CompIndex).PINOUT.sysrst='H8';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='J22';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='P20';
            this.Component(CompIndex).PINOUT.ETH_RXD={'P19','Y22','Y21','W22','W20','V22','V21','U22'};
            this.Component(CompIndex).PINOUT.ETH_RXDV='T22';
            this.Component(CompIndex).PINOUT.ETH_RXER='U20';
            this.Component(CompIndex).PINOUT.ETH_TXD={'U10','T10','AB8','AA8','AB9','Y9','Y12','W12'};
            this.Component(CompIndex).PINOUT.ETH_GTXCLK='AB7';
            this.Component(CompIndex).PINOUT.ETH_TXEN='T8';
            this.Component(CompIndex).PINOUT.ETH_TXER='U8';
            this.Component(CompIndex).PINOUT.ETH_COL='M16';
            this.Component(CompIndex).PINOUT.ETH_CRS='N15';
            this.Component(CompIndex).PINOUT.ETH_MDC='R19';
            this.Component(CompIndex).PINOUT.ETH_MDIO='V20';
            this.Component(CompIndex).PINOUT.LED='D17';
        end
    end
end
