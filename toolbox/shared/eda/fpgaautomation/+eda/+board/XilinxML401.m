classdef(ConstructOnLoad)XilinxML401<eda.board.XilinxML40x






    methods
        function this=XilinxML401
            this.Name='Xilinx Virtex-4 ML401 development board';
            this.Component.PartInfo=eda.fpga.Virtex4(...
            'Device','xc4vlx25',...
            'Speed','-10',...
            'Package','ff668');

            this.Component.DCMLocation='DCM_ADV_X0Y0';
            this.Component.Communication_Channel='GMII';
        end
    end
end
