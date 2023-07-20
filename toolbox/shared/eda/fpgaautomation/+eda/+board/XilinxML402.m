classdef(ConstructOnLoad)XilinxML402<eda.board.XilinxML40x





    methods
        function this=XilinxML402
            this.Name='Xilinx Virtex-4 ML402 development board';
            this.Component.PartInfo=eda.fpga.Virtex4(...
            'Device','xc4vsx35',...
            'Speed','-10',...
            'Package','ff668');

            this.Component.DCMLocation='DCM_ADV_X0Y0';
            this.Component.Communication_Channel='GMII';
        end

    end
end
