classdef(ConstructOnLoad)AlteraDE2_115<eda.board.FPGABoard






    properties

    end
    methods
        function this=AlteraDE2_115
            this.Name='Altera DE2-115 development and education board';
            this.Component.PartInfo=eda.fpga.Cyclone4(...
            'FPGAFamily','Cyclone IV E',...
            'Device','EP4CE115F29C7');

            this.Component.SYSCLK.Frequency=50;
            this.Component.SYSCLK.Type='SINGLE_ENDED';
            this.Component.SYSRST.Polarity='ACTIVE_LOW';
            this.Component.ScanChain=2;
            this.Component.DCMLocation='XY';
            this.Component.Communication_Channel='RGMII';
            this.Component.PhyAddr=16;
        end


        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk='Y2';
            this.Component(CompIndex).PINOUT.sysrst='M23';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='C19';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='A15';
            this.Component(CompIndex).PINOUT.ETH_RXD={'C16','D16','D17','C15'};
            this.Component(CompIndex).PINOUT.ETH_RX_CTL='C17';
            this.Component(CompIndex).PINOUT.ETH_TXD={'C18','D19','A19','B19'};
            this.Component(CompIndex).PINOUT.ETH_TXCLK='A17';
            this.Component(CompIndex).PINOUT.ETH_TX_CTL='A18';
            this.Component(CompIndex).PINOUT.ETH_MDC='C20';
            this.Component(CompIndex).PINOUT.ETH_MDIO='B21';
            this.Component(CompIndex).PINOUT.LED='E21';
        end
    end
end
