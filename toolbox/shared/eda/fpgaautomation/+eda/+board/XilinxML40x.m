classdef(ConstructOnLoad)XilinxML40x<eda.board.FPGABoard





    methods
        function this=XilinxML40x
            this.Component.SYSCLK.Frequency=100;
            this.Component.SYSCLK.Type='SINGLE_ENDED';
            this.Component.SYSRST.Polarity='ACTIVE_LOW';
            this.Component.ScanChain=3;
            this.Component.PhyAddr=0;
        end

        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk='AE14';
            this.Component(CompIndex).PINOUT.sysrst='D6';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='D10';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='B15';
            this.Component(CompIndex).PINOUT.ETH_RXD={'F1','E1','D4','C4','B4','A4','B3','A3'};
            this.Component(CompIndex).PINOUT.ETH_RXDV='A9';
            this.Component(CompIndex).PINOUT.ETH_RXER='B9';
            this.Component(CompIndex).PINOUT.ETH_TXD={'H1','H2','H3','G1','G2','H5','H6','G3'};
            this.Component(CompIndex).PINOUT.ETH_GTXCLK='G10';
            this.Component(CompIndex).PINOUT.ETH_TXEN='F4';
            this.Component(CompIndex).PINOUT.ETH_TXER='F3';
            this.Component(CompIndex).PINOUT.ETH_COL='E3';
            this.Component(CompIndex).PINOUT.ETH_CRS='D5';
            this.Component(CompIndex).PINOUT.ETH_MDC='D1';
            this.Component(CompIndex).PINOUT.ETH_MDIO='G4';
            this.Component(CompIndex).PINOUT.LED='G5';
        end
    end
end
