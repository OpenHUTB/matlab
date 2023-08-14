classdef(ConstructOnLoad)XilinxML50x<eda.board.FPGABoard






    methods
        function this=XilinxML50x
            this.Component.SYSCLK.Frequency=100;
            this.Component.SYSCLK.Type='SINGLE_ENDED';
            this.Component.SYSRST.Polarity='ACTIVE_LOW';
            this.Component.ScanChain=5;
            this.Component.PhyAddr=7;
        end

        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk='AH15';
            this.Component(CompIndex).PINOUT.sysrst='E9';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='J14';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='H17';
            this.Component(CompIndex).PINOUT.ETH_RXD={'A33','B33','C33','C32','D32','C34','D34','F33'};
            this.Component(CompIndex).PINOUT.ETH_RXDV='E32';
            this.Component(CompIndex).PINOUT.ETH_RXER='E33';
            this.Component(CompIndex).PINOUT.ETH_TXD={'AF11','AE11','AH9','AH10','AG8','AH8','AG10','AG11'};
            this.Component(CompIndex).PINOUT.ETH_GTXCLK='J16';
            this.Component(CompIndex).PINOUT.ETH_TXEN='AJ10';
            this.Component(CompIndex).PINOUT.ETH_TXER='AJ9';
            this.Component(CompIndex).PINOUT.ETH_COL='B32';
            this.Component(CompIndex).PINOUT.ETH_CRS='E34';
            this.Component(CompIndex).PINOUT.ETH_MDC='H19';
            this.Component(CompIndex).PINOUT.ETH_MDIO='H13';
            this.Component(CompIndex).PINOUT.LED='H18';

        end
    end
end
