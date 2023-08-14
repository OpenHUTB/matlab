classdef(ConstructOnLoad)Register<eda.internal.component.WhiteBox







    properties
clk
reset
clkenb
din
dout
    end

    methods
        function this=Register(varargin)
            this.clk=eda.internal.component.ClockPort;
            this.clkenb=eda.internal.component.ClockEnablePort;
            this.reset=eda.internal.component.ResetPort;
            this.din=eda.internal.component.Inport('FiType','inherit');
            this.dout=eda.internal.component.Outport('FiType','inherit');
            this.flatten=true;
        end

    end

end

