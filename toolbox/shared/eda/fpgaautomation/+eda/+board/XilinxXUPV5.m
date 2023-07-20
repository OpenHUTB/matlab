classdef(ConstructOnLoad)XilinxXUPV5<eda.board.XilinxML50x





    methods
        function this=XilinxXUPV5
            this.Name='Xilinx Virtex-5 XUPV5-LX110T development board';this.Component.PartInfo=eda.fpga.Virtex5(...
            'Device','xc5vlx110t',...
            'Speed','-1',...
            'Package','ff1136');

            this.Component.DCMLocation='DCM_ADV_X0Y5';
            this.Component.Communication_Channel='GMII';
        end
    end
end
