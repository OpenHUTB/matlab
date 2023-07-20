classdef(ConstructOnLoad)XilinxSP601<eda.board.FPGABoard





    methods
        function this=XilinxSP601
            this.Name='Xilinx Spartan-6 SP601 development board';
            this.Component.PartInfo=eda.fpga.Spartan6(...
            'Device','xc6slx16',...
            'Speed','-2',...
            'Package','csg324');

            this.Component.SYSCLK.Frequency=200;
            this.Component.SYSCLK.Type='DIFF';
            this.Component.SYSRST.Polarity='ACTIVE_HIGH';
            this.Component.DCMLocation='DCM_X0Y2';
            this.Component.ScanChain=1;
            this.Component.Communication_Channel='GMII';
            this.Component.PhyAddr=7;
        end
        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk_p='K15';
            this.Component(CompIndex).PINOUT.sysclk_n='K16';
            this.Component(CompIndex).PINOUT.sysrst='N4';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='L13';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='L16';
            this.Component(CompIndex).PINOUT.ETH_RXD={'M14','U18','U17','T18','T17','N16','N15','P18'};
            this.Component(CompIndex).PINOUT.ETH_RXDV='N18';
            this.Component(CompIndex).PINOUT.ETH_RXER='P17';
            this.Component(CompIndex).PINOUT.ETH_TXD={'F8','G8','A6','B6','E6','F7','A5','C5'};
            this.Component(CompIndex).PINOUT.ETH_GTXCLK='A9';
            this.Component(CompIndex).PINOUT.ETH_TXEN='B8';
            this.Component(CompIndex).PINOUT.ETH_TXER='A8';
            this.Component(CompIndex).PINOUT.ETH_COL='L14';
            this.Component(CompIndex).PINOUT.ETH_CRS='M13';
            this.Component(CompIndex).PINOUT.ETH_MDC='N14';
            this.Component(CompIndex).PINOUT.ETH_MDIO='P16';
            this.Component(CompIndex).PINOUT.LED='E13';
        end
    end
end
