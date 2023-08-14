classdef(ConstructOnLoad)XUPAtlys<eda.board.FPGABoard






    properties


    end
    methods
        function this=XUPAtlys
            this.Name='XUP Atlys Spartan-6 development board';
            this.Component.PartInfo=eda.fpga.Spartan6(...
            'Device','xc6slx45',...
            'Speed','-2',...
            'Package','csg324');

            this.Component.SYSCLK.Frequency=100;
            this.Component.SYSCLK.Type='SINGLE_ENDED';
            this.Component.SYSRST.Polarity='ACTIVE_LOW';
            this.Component.ScanChain=1;
            this.Component.DCMLocation='DCM_X0Y2';
            this.Component.Communication_Channel='GMII';
            this.Component.UseDigilentPlugin=true;
        end


        function setPIN(this,CompIndex)
            this.Component(CompIndex).PINOUT.sysclk='L15';
            this.Component(CompIndex).PINOUT.sysrst='T15';
            this.Component(CompIndex).PINOUT.ETH_RESET_n='G13';
            this.Component(CompIndex).PINOUT.ETH_RXCLK='K15';
            this.Component(CompIndex).PINOUT.ETH_RXD={'G16','H14','E16','F15','F14','E18','D18','D17'};
            this.Component(CompIndex).PINOUT.ETH_RXDV='F17';
            this.Component(CompIndex).PINOUT.ETH_RXER='F18';
            this.Component(CompIndex).PINOUT.ETH_TXD={'H16','H13','K14','K13','J13','G14','H12','K12'};
            this.Component(CompIndex).PINOUT.ETH_GTXCLK='L12';
            this.Component(CompIndex).PINOUT.ETH_TXEN='H15';
            this.Component(CompIndex).PINOUT.ETH_TXER='G18';
            this.Component(CompIndex).PINOUT.ETH_COL='C17';
            this.Component(CompIndex).PINOUT.ETH_CRS='C18';
            this.Component(CompIndex).PINOUT.ETH_MDC='F16';
            this.Component(CompIndex).PINOUT.ETH_MDIO='N17';
            this.Component(CompIndex).PINOUT.LED='U18';
        end
    end
end
