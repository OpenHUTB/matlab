classdef Cyclone10GX<eda.fpga.Cyclone5
    methods
        function this=Cyclone10GX(varargin)
            this=this@eda.fpga.Cyclone5(varargin{:});
            this.FPGAFamily='Cyclone 10 GX';
        end
    end
end
