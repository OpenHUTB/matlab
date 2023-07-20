classdef(ConstructOnLoad)XilinxML506<eda.board.XilinxML50x





    methods
        function this=XilinxML506
            this.Name='Xilinx Virtex-5 ML506 development board';
            this.Component.PartInfo=eda.fpga.Virtex5(...
            'Device','xc5vsx50t',...
            'Speed','-1',...
            'Package','ff1136');

            this.Component.DCMLocation='DCM_ADV_X0Y5';
            this.Component.Communication_Channel='GMII';
        end
    end
end
