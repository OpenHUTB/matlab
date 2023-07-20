classdef(ConstructOnLoad)XilinxML605<eda.board.FPGABoard






    properties


    end
    methods
        function this=XilinxML605
            this.Name='Xilinx Virtex-6 ML605 development board';
            this.Component.PartInfo=eda.fpga.Virtex6(...
            'Device','xc6vlx240t',...
            'Speed','-1',...
            'Package','ff1156',...
            'Frequency','25MHz');

            this.Component.SYSCLK.Frequency=200;
            this.Component.SYSCLK.Type='DIFF';
            this.Component.SYSRST.Polarity='ACTIVE_HIGH';
            this.Component.ScanChain=2;
            this.Component.DCMLocation='MMCM_ADV_X0Y5';
            this.Component.Communication_Channel='GMII';
            this.Component.PhyAddr=7;
        end


        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk_p='J9';
            this.Component(CompIndex).PINOUT.sysclk_n='H9';
            this.Component(CompIndex).PINOUT.sysrst='H10';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='AH13';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='AP11';
            this.Component(CompIndex).PINOUT.ETH_RXD={'AN13','AF14','AE14','AN12','AM12','AD11','AC12','AC13'};
            this.Component(CompIndex).PINOUT.ETH_RXDV='AM13';
            this.Component(CompIndex).PINOUT.ETH_RXER='AG12';
            this.Component(CompIndex).PINOUT.ETH_TXD={'AM11','AL11','AG10','AG11','AL10','AM10','AE11','AF11'};
            this.Component(CompIndex).PINOUT.ETH_GTXCLK='AH12';
            this.Component(CompIndex).PINOUT.ETH_TXEN='AJ10';
            this.Component(CompIndex).PINOUT.ETH_TXER='AH10';
            this.Component(CompIndex).PINOUT.ETH_COL='AK13';
            this.Component(CompIndex).PINOUT.ETH_CRS='AL13';
            this.Component(CompIndex).PINOUT.ETH_MDC='AP14';
            this.Component(CompIndex).PINOUT.ETH_MDIO='AN14';
            this.Component(CompIndex).PINOUT.LED='AC22';
        end
    end
end
