


classdef(ConstructOnLoad=true)USRPFilterRX<eda.internal.component.BlackBox



    properties
clk
reset
clk_enable
filter_in_re
filter_in_im
rate
load_rate

filter_out_re
filter_out_im
ce_out
    end

    methods
        function this=USRPFilterRX(varargin)
            this.clk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.clk_enable=eda.internal.component.ClockEnablePort;

            this.filter_in_re=eda.internal.component.Inport('FiType','sfix24');
            this.filter_in_im=eda.internal.component.Inport('FiType','sfix24');
            this.rate=eda.internal.component.Inport('FiType','ufix8');
            this.load_rate=eda.internal.component.Inport('FiType','boolean');

            this.filter_out_re=eda.internal.component.Outport('FiType','sfix18');
            this.filter_out_im=eda.internal.component.Outport('FiType','sfix18');
            this.ce_out=eda.internal.component.Outport('FiType','boolean');

            this.addprop('NoHDLFiles');
        end
    end

end

