classdef(ConstructOnLoad=true)DCM<eda.internal.component.WhiteBox








    properties

ClkIn
Reset
ClkOut
reset_in



    end

    properties(SetAccess=protected)
compDeclNotNeeded
    end

    methods
        function this=DCM(varargin)
            this.flatten=true;
            this.ClkIn=eda.internal.component.ClockPort;
            this.Reset=eda.internal.component.ResetPort;
            this.ClkOut=eda.internal.component.Outport('FiType','boolean');
            this.reset_in=eda.internal.component.Outport('FiType','boolean');





        end

        function implement(this)

            ibufg_o=this.signal('Name','ibufg_o',...
            'FiType','boolean');

            dcm_clk0=this.signal('Name','dcm_clk0',...
            'FiType','boolean');

            bufg_o=this.signal('Name','bufg_clko',...
            'FiType','boolean');

            this.component(...
            'Name','ibufg',...
            'Component',eda.xilinx.IBUFG,...
            'I',this.ClkIn,...
            'O',ibufg_o);

            this.component(...
            'Name','dcm_sp',...
            'Component',eda.xilinx.DCMSP,...
            'CLKIN',ibufg_o,...
            'RST',this.Reset,...
            'CLK0',dcm_clk0,...
            'CLKFB',bufg_o,...
            'LOCKED',this.reset_in);

            this.component(...
            'Name','bufg',...
            'Component',eda.xilinx.BUFG,...
            'I',dcm_clk0,...
            'O',bufg_o);

            this.assign(bufg_o,this.ClkOut);

        end


    end
end

